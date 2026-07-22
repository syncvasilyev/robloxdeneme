--!strict
-- Party hosting (gated behind the Party gamepass), join-by-code, friends-only toggle, a
-- track/custom-song DJ system shared by party members, and the physical Disco instance each
-- party gets teleported into. Every party clones its own DiscoBuilder instance far above the
-- main map (see INSTANCE_Y_BASE) so parties never see or hear each other — cheaper than real
-- Reserved Servers, and just as isolated within a single game server.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Modules.Remotes)
local GamepassIds = require(ReplicatedStorage.Modules.GamepassIds)
local PartyTracks = require(ReplicatedStorage.Modules.PartyTracks)
local GamepassService = require(script.Parent.Parent.Data.GamepassService)
local PlayerDataStore = require(script.Parent.Parent.Data.PlayerDataStore)
local DiscoBuilder = require(script.Parent.DiscoBuilder)

local PartySystem = {}

local MAX_PARTY_SIZE = 23
local CODE_CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
local INSTANCE_Y_BASE = 2000
local INSTANCE_Z_SPACING = 500

type MusicState = { trackId: string?, customAssetId: string?, startedAt: number, isPlaying: boolean }

type Party = {
	code: string,
	host: Player,
	maxSize: number,
	friendsOnly: boolean,
	members: { Player },
	djs: { [Player]: boolean },
	music: MusicState,
	discoInstance: Model,
	spawnPart: BasePart,
}

local partiesByCode: { [string]: Party } = {}
local partyByPlayer: { [Player]: Party } = {}
local nextInstanceIndex = 0

local createPartyEvent = Remotes.getEvent("CreateParty")
local joinPartyEvent = Remotes.getEvent("JoinParty")
local leavePartyEvent = Remotes.getEvent("LeaveParty")
local closePartyEvent = Remotes.getEvent("ClosePartyHost")
local setFriendsOnlyEvent = Remotes.getEvent("SetPartyFriendsOnly")
local grantDjEvent = Remotes.getEvent("GrantPartyDj")
local playTrackEvent = Remotes.getEvent("PlayPartyTrack")
local playCustomSongEvent = Remotes.getEvent("PlayPartyCustomSong")
local stopTrackEvent = Remotes.getEvent("StopPartyTrack")
local partyStateEvent = Remotes.getEvent("PartyStateChanged")
local rainbowStickOfferEvent = Remotes.getEvent("ShowRainbowStickOffer")

local function getPartyInstancesFolder(): Folder
	local existing = Workspace:FindFirstChild("PartyInstances")
	if existing then
		return existing :: Folder
	end
	local folder = Instance.new("Folder")
	folder.Name = "PartyInstances"
	folder.Parent = Workspace
	return folder
end

local function findPublicMapSpawn(): BasePart?
	local spawn = Workspace:FindFirstChild("PublicMapSpawn", true)
	if spawn and spawn:IsA("BasePart") then
		return spawn
	end
	return nil
end

local function teleportPlayerToPart(player: Player, part: BasePart)
	local character = player.Character
	if not character then
		return
	end
	local rootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if rootPart then
		rootPart.CFrame = part.CFrame + Vector3.new(0, 3, 0)
	end
end

local function teleportPlayerHome(player: Player)
	local spawn = findPublicMapSpawn()
	if spawn then
		teleportPlayerToPart(player, spawn)
	end
end

local RAINBOW_STICK_COLORS = {
	Color3.fromRGB(220, 30, 60),
	Color3.fromRGB(230, 150, 30),
	Color3.fromRGB(230, 220, 30),
	Color3.fromRGB(40, 210, 120),
	Color3.fromRGB(40, 120, 230),
	Color3.fromRGB(170, 40, 220),
}

-- Rainbow Stick: only handed out while inside a disco instance, and only if the player owns the
-- gamepass — removed the moment they leave (see teleportPlayerHome usages / endParty).
local function giveRainbowStick(player: Player)
	if not GamepassService.playerOwns(player, GamepassIds.RainbowStick) then
		return
	end
	local backpack = player:FindFirstChild("Backpack")
	if not backpack or backpack:FindFirstChild("Rainbow Stick") then
		return
	end

	local tool = Instance.new("Tool")
	tool.Name = "Rainbow Stick"
	tool.RequiresHandle = true

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.3, 3, 0.3)
	handle.Color = RAINBOW_STICK_COLORS[1]
	handle.Material = Enum.Material.Neon
	handle.Parent = tool

	local light = Instance.new("PointLight")
	light.Color = RAINBOW_STICK_COLORS[1]
	light.Brightness = 2
	light.Range = 10
	light.Parent = handle

	task.spawn(function()
		local colorIndex = 1
		while tool.Parent do
			colorIndex = (colorIndex % #RAINBOW_STICK_COLORS) + 1
			local color = RAINBOW_STICK_COLORS[colorIndex]
			handle.Color = color
			light.Color = color
			task.wait(0.4)
		end
	end)

	tool.Parent = backpack
end

local function removeRainbowStick(player: Player)
	local backpack = player:FindFirstChild("Backpack")
	if backpack then
		local tool = backpack:FindFirstChild("Rainbow Stick")
		if tool then
			tool:Destroy()
		end
	end
	local character = player.Character
	if character then
		local equipped = character:FindFirstChild("Rainbow Stick")
		if equipped then
			equipped:Destroy()
		end
	end
end

-- Shown once, the very first time a player ever steps into a party's disco instance.
local function maybeOfferRainbowStick(player: Player)
	local data = PlayerDataStore.get(player)
	if not data or data.party.rainbowStickOffered then
		return
	end
	data.party.rainbowStickOffered = true
	PlayerDataStore.save(player)
	rainbowStickOfferEvent:FireClient(player)
end

-- Host radio: a small decorative backpack-radio prop, visible only on whoever is actively
-- hosting a party, for as long as they're hosting.
local function attachHostRadio(player: Player)
	local character = player.Character
	if not character then
		return
	end
	local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
	if not torso or not torso:IsA("BasePart") then
		return
	end

	local existing = character:FindFirstChild("HostRadio")
	if existing then
		existing:Destroy()
	end

	local radio = Instance.new("Part")
	radio.Name = "HostRadio"
	radio.Size = Vector3.new(0.8, 1.1, 0.4)
	radio.Color = Color3.fromRGB(20, 18, 20)
	radio.Material = Enum.Material.Metal
	radio.CanCollide = false
	radio.Massless = true

	local antenna = Instance.new("Part")
	antenna.Name = "Antenna"
	antenna.Size = Vector3.new(0.06, 0.6, 0.06)
	antenna.Color = Color3.fromRGB(40, 40, 44)
	antenna.Material = Enum.Material.Metal
	antenna.CanCollide = false
	antenna.Massless = true
	antenna.Parent = radio

	local speakerGrille = Instance.new("Part")
	speakerGrille.Name = "SpeakerGrille"
	speakerGrille.Size = Vector3.new(0.5, 0.5, 0.05)
	speakerGrille.Color = Color3.fromRGB(220, 40, 160)
	speakerGrille.Material = Enum.Material.Neon
	speakerGrille.CanCollide = false
	speakerGrille.Massless = true
	speakerGrille.Parent = radio

	local weld = Instance.new("Weld")
	weld.Part0 = torso
	weld.Part1 = radio
	weld.C0 = CFrame.new(0.7, 0.3, 0.4) * CFrame.Angles(0, math.rad(30), 0)
	weld.Parent = radio

	local antennaWeld = Instance.new("Weld")
	antennaWeld.Part0 = radio
	antennaWeld.Part1 = antenna
	antennaWeld.C0 = CFrame.new(0.3, 0.75, 0)
	antennaWeld.Parent = antenna

	local grilleWeld = Instance.new("Weld")
	grilleWeld.Part0 = radio
	grilleWeld.Part1 = speakerGrille
	grilleWeld.C0 = CFrame.new(0, 0, 0.23)
	grilleWeld.Parent = speakerGrille

	radio.Parent = character
end

local function removeHostRadio(player: Player)
	local character = player.Character
	if not character then
		return
	end
	local existing = character:FindFirstChild("HostRadio")
	if existing then
		existing:Destroy()
	end
end

local function createDiscoInstance(): (Model, BasePart)
	nextInstanceIndex += 1
	local clone = DiscoBuilder.cloneInstance()
	clone.Name = "Party_" .. tostring(nextInstanceIndex)
	local offset = CFrame.new(0, INSTANCE_Y_BASE, nextInstanceIndex * INSTANCE_Z_SPACING)
	clone:PivotTo(offset * clone:GetPivot())
	clone.Parent = getPartyInstancesFolder()
	local spawnPart = clone:FindFirstChild("InstanceSpawn", true) :: BasePart
	return clone, spawnPart
end

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

local function endParty(party: Party)
	for _, member in ipairs(party.members) do
		partyByPlayer[member] = nil
		partyStateEvent:FireClient(member, nil)
		teleportPlayerHome(member)
		removeRainbowStick(member)
	end
	removeHostRadio(party.host)
	partiesByCode[party.code] = nil
	party.discoInstance:Destroy()
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
	teleportPlayerHome(player)
	removeRainbowStick(player)

	if player == party.host then
		-- Host leaving/closing ends the party for everyone and counts as a completed hosting.
		local data = PlayerDataStore.get(player)
		if data then
			data.party.hostCount += 1
			PlayerDataStore.save(player)
		end
		endParty(party)
	elseif #party.members == 0 then
		partiesByCode[party.code] = nil
		party.discoInstance:Destroy()
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

	local discoInstance, spawnPart = createDiscoInstance()

	local party: Party = {
		code = generateCode(),
		host = player,
		maxSize = maxSize,
		friendsOnly = false,
		members = { player },
		djs = {},
		music = { trackId = nil, customAssetId = nil, startedAt = 0, isPlaying = false },
		discoInstance = discoInstance,
		spawnPart = spawnPart,
	}
	party.djs[player] = true
	partiesByCode[party.code] = party
	partyByPlayer[player] = party
	broadcastPartyState(party)
	teleportPlayerToPart(player, spawnPart)
	attachHostRadio(player)
	giveRainbowStick(player)
	maybeOfferRainbowStick(player)
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
	teleportPlayerToPart(player, party.spawnPart)
	giveRainbowStick(player)
	maybeOfferRainbowStick(player)

	-- Counts toward the host's cumulative "guests welcomed" total (see PARTY KING title).
	local hostData = PlayerDataStore.get(party.host)
	if hostData then
		hostData.party.totalGuestJoins += 1
	end
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

	party.music = { trackId = trackId, customAssetId = nil, startedAt = os.time(), isPlaying = true }
	broadcastPartyState(party)
end

--- DJ-permitted members can paste a raw Roblox audio ID/URL; digits are extracted so
--- "rbxassetid://123", a full roblox.com asset link, or a bare numeric ID all work.
local function onPlayCustomSong(player: Player, rawId: any)
	local party = partyByPlayer[player]
	if not (party and party.djs[player] and type(rawId) == "string") then
		return
	end

	local digits = rawId:match("(%d+)")
	if not digits or #digits == 0 then
		return
	end

	party.music = { trackId = nil, customAssetId = "rbxassetid://" .. digits, startedAt = os.time(), isPlaying = true }
	broadcastPartyState(party)
end

local function onStopTrack(player: Player)
	local party = partyByPlayer[player]
	if not (party and party.djs[player]) then
		return
	end
	party.music = { trackId = nil, customAssetId = nil, startedAt = 0, isPlaying = false }
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
	playCustomSongEvent.OnServerEvent:Connect(onPlayCustomSong)
	stopTrackEvent.OnServerEvent:Connect(onStopTrack)

	Players.PlayerRemoving:Connect(removePlayerFromParty)

	-- Re-attach the host radio/Rainbow Stick and reposition after a respawn (character reset
	-- clears welds and the backpack).
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function()
			local party = partyByPlayer[player]
			if not party then
				return
			end
			task.wait(0.5)
			teleportPlayerToPart(player, party.spawnPart)
			giveRainbowStick(player)
			if party.host == player then
				attachHostRadio(player)
			end
		end)
	end)
end

return PartySystem
