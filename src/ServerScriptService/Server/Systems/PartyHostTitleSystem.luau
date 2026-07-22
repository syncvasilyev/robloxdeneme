--!strict
-- Grants party-hosting titles, shown only while the player is in Public Map / Disco (parts
-- tagged "CharZone" in Studio; see ZoneTracker):
--   PARTY HOST — hosted 20 parties (PartySystem increments party.hostCount when a host
--                closes/leaves their own party).
--   PARTY KING — a higher, more prestigious title: 200 cumulative guest joins across every
--                party this player has hosted (PartySystem increments party.totalGuestJoins
--                each time someone joins one of their parties). Takes precedence over PARTY
--                HOST when both are earned — a player only ever shows one title at a time.
--
-- Both titles are purely derived from PlayerDataStore counters — no separate "unlocked" flag.

local Players = game:GetService("Players")

local PlayerDataStore = require(script.Parent.Parent.Data.PlayerDataStore)
local ZoneTracker = require(script.Parent.Parent.Data.ZoneTracker)

local PartyHostTitleSystem = {}

local CHAR_ZONE_TAG = "CharZone"
local CHECK_INTERVAL_SECONDS = 2

local PARTY_HOST_THRESHOLD = 20
local PARTY_KING_THRESHOLD = 200

local function titleFor(data: { [any]: any }): string?
	if data.party.totalGuestJoins >= PARTY_KING_THRESHOLD then
		return "👑 PARTY KING"
	end
	if data.party.hostCount >= PARTY_HOST_THRESHOLD then
		return "👑 PARTY HOST"
	end
	return nil
end

local function updatePlayer(player: Player)
	local data = PlayerDataStore.get(player)
	if not data then
		return
	end

	local title = titleFor(data)
	if title and ZoneTracker.isPlayerInTag(player, CHAR_ZONE_TAG) then
		player:SetAttribute("PartyHostTitle", title)
	else
		player:SetAttribute("PartyHostTitle", nil)
	end
end

function PartyHostTitleSystem.init()
	task.spawn(function()
		while true do
			for _, player in ipairs(Players:GetPlayers()) do
				updatePlayer(player)
			end
			task.wait(CHECK_INTERVAL_SECONDS)
		end
	end)
end

return PartyHostTitleSystem
