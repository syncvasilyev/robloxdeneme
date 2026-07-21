--!strict
-- Party hosting (gated behind the Party gamepass), join-by-code, friends-only toggle, and a
-- simple track-based DJ system shared by party members. Used for the Disco area's music once
-- the 3D map exists in Studio — for now playback is broadcast to party members globally rather
-- than positioned at a physical Disco location.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Modules.Remotes)
local GamepassIds = require(ReplicatedStorage.Modules.GamepassIds)
local PartyTracks = require(ReplicatedStorage.Modules.PartyTracks)
local GamepassService = require(script.Parent.Parent.Data.GamepassService)
local PlayerDataStore = require(script.Parent.Parent.Data.PlayerDataStore)

local PartySystem = {}

local MAX_PARTY_SIZE = 23
local CODE_CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"

type MusicState = { trackId: string?, startedAt: number, isPlaying: boolean }

type Party = {
	code: string,
	host: Player,
	maxSize: number,
	friendsOnly: boolean,
	members: { Player },
	djs: { [Player]: boolean },
	music: MusicState,
}

local partiesByCode: { [string]: Party } = {}
local partyByPlayer: { [Player]: Party } = {}

local createPartyEvent = Remotes.getEvent("CreateParty")
local joinPartyEvent = Remotes.getEvent("JoinParty")
local leavePartyEvent = Remotes.getEvent("LeaveParty")
local closePartyEvent = Remotes.getEvent("ClosePartyHost")
local setFriendsOnlyEvent = Remotes.getEvent("SetPartyFriendsOnly")
local grantDjEvent = Remotes.getEvent("GrantPartyDj")
local playTrackEvent = Remotes.getEvent("PlayPartyTrack")
local stopTrackEvent = Remotes.getEvent("StopPartyTrack")
local partyStateEvent = Remotes.getEvent("PartyStateChanged")

local function generateCode(): string
	local code
	repeat
		local parts = {}
		for _ = 1, 5 do
			local index = math.random(1, #CODE_CHARS)
			table.insert(parts, CODE_CHARS:sub(index, index))
		end
		code = table.concat(parts)
	until not partiesByCode[code]
	return code
end

local function serializeParty(party: Party)
	local memberNames = {}
	for _, member in ipairs(party.members) do
		table.insert(memberNames, member.Name)
	end
	local djNames = {}
	for member, isDj in pairs(party.djs) do
		if isDj then
			table.insert(djNames, member.Name)
		end
	end
	return {
		code = party.code,
		host = party.host.Name,
		maxSize = party.maxSize,
		friendsOnly = party.friendsOnly,
		members = memberNames,
		djs = djNames,
		music = party.music,
	}
end

local function broadcastPartyState(party: Party)
	local state = serializeParty(party)
	for _, member in ipairs(party.members) do
		partyStateEvent:FireClient(member, state)
	end
end

local function removePlayerFromParty(player: Player)
	local party = partyByPlayer[player]
	if not party then
		return
	end

	for i, member in ipairs(party.members) do
		if member == player then
			table.remove(party.members, i)
			break
		end
	end
	partyByPlayer[player] = nil
	party.djs[player] = nil
	partyStateEvent:FireClient(player, nil)

	if player == party.host then
		-- Host leaving/closing ends the party for everyone and counts as a completed hosting.
		local data = PlayerDataStore.get(player)
		if data then
			data.party.hostCount += 1
			PlayerDataStore.save(player)
		end
		for _, member in ipairs(party.members) do
			partyByPlayer[member] = nil
			partyStateEvent:FireClient(member, nil)
		end
		partiesByCode[party.code] = nil
	elseif #party.members == 0 then
		partiesByCode[party.code] = nil
	else
		broadcastPartyState(party)
	end
end

local function onCreateParty(player: Player, payload: any)
	if not GamepassService.playerOwns(player, GamepassIds.Party) then
		partyStateEvent:FireClient(player, { error = "Parti kurmak için Party Gamepass gerekiyor." })
		return
	end
	if partyByPlayer[player] then
		removePlayerFromParty(player)
	end

	local maxSize = MAX_PARTY_SIZE
	if type(payload) == "table" and type(payload.maxSize) == "number" then
		maxSize = math.clamp(math.floor(payload.maxSize), 2, MAX_PARTY_SIZE)
	end

	local party: Party = {
		code = generateCode(),
		host = player,
		maxSize = maxSize,
		friendsOnly = false,
		members = { player },
		djs = {},
		music = { trackId = nil, startedAt = 0, isPlaying = false },
	}
	party.djs[player] = true
	partiesByCode[party.code] = party
	partyByPlayer[player] = party
	broadcastPartyState(party)
end

local function onJoinParty(player: Player, code: any)
	if type(code) ~= "string" then
		return
	end
	local party = partiesByCode[code:upper()]
	if not party then
		partyStateEvent:FireClient(player, { error = "Kod bulunamadı." })
		return
	end
	if #party.members >= party.maxSize then
		partyStateEvent:FireClient(player, { error = "Parti dolu." })
		return
	end
	if party.friendsOnly then
		local success, isFriend = pcall(function()
			return player:IsFriendsWith(party.host.UserId)
		end)
		if not (success and isFriend) then
			partyStateEvent:FireClient(player, { error = "Bu parti sadece arkadaşlara açık." })
			return
		end
	end
	if partyByPlayer[player] then
		removePlayerFromParty(player)
	end

	table.insert(party.members, player)
	partyByPlayer[player] = party
	broadcastPartyState(party)
end

local function onLeaveParty(player: Player)
	removePlayerFromParty(player)
end

local function onCloseParty(player: Player)
	local party = partyByPlayer[player]
	if party and party.host == player then
		removePlayerFromParty(player)
	end
end

local function onSetFriendsOnly(player: Player, value: any)
	local party = partyByPlayer[player]
	if party and party.host == player and type(value) == "boolean" then
		party.friendsOnly = value
		broadcastPartyState(party)
	end
end

local function onGrantDj(player: Player, targetName: any)
	local party = partyByPlayer[player]
	if not (party and party.host == player and type(targetName) == "string") then
		return
	end
	for _, member in ipairs(party.members) do
		if member.Name == targetName then
			party.djs[member] = true
			broadcastPartyState(party)
			return
		end
	end
end

local function onPlayTrack(player: Player, trackId: any)
	local party = partyByPlayer[player]
	if not (party and party.djs[player] and type(trackId) == "string") then
		return
	end

	local trackExists = false
	for _, track in ipairs(PartyTracks) do
		if track.id == trackId then
			trackExists = true
			break
		end
	end
	if not trackExists then
		return
	end

	party.music = { trackId = trackId, startedAt = os.time(), isPlaying = true }
	broadcastPartyState(party)
end

local function onStopTrack(player: Player)
	local party = partyByPlayer[player]
	if not (party and party.djs[player]) then
		return
	end
	party.music = { trackId = nil, startedAt = 0, isPlaying = false }
	broadcastPartyState(party)
end

function PartySystem.init()
	createPartyEvent.OnServerEvent:Connect(onCreateParty)
	joinPartyEvent.OnServerEvent:Connect(onJoinParty)
	leavePartyEvent.OnServerEvent:Connect(onLeaveParty)
	closePartyEvent.OnServerEvent:Connect(onCloseParty)
	setFriendsOnlyEvent.OnServerEvent:Connect(onSetFriendsOnly)
	grantDjEvent.OnServerEvent:Connect(onGrantDj)
	playTrackEvent.OnServerEvent:Connect(onPlayTrack)
	stopTrackEvent.OnServerEvent:Connect(onStopTrack)

	Players.PlayerRemoving:Connect(removePlayerFromParty)
end

return PartySystem
