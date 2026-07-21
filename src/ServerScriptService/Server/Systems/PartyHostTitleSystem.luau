--!strict
-- Grants a "PARTY HOST" title once a player has hosted 20 parties (see PartySystem, which
-- increments party.hostCount whenever a host closes/leaves their own party). The title is
-- purely derived from hostCount — no separate "unlocked" flag needed — and only shown while
-- the player is in Public Map / Disco (parts tagged "CharZone" in Studio; see ZoneTracker).
--
-- More thresholds (50/100/250/500 parties) can be added to TITLE_THRESHOLDS later once their
-- names are decided.

local Players = game:GetService("Players")

local PlayerDataStore = require(script.Parent.Parent.Data.PlayerDataStore)
local ZoneTracker = require(script.Parent.Parent.Data.ZoneTracker)

local PartyHostTitleSystem = {}

local CHAR_ZONE_TAG = "CharZone"
local CHECK_INTERVAL_SECONDS = 2

local TITLE_THRESHOLDS = {
	{ count = 20, name = "PARTY HOST" },
}

local function titleForHostCount(hostCount: number): string?
	local best: string? = nil
	for _, tier in ipairs(TITLE_THRESHOLDS) do
		if hostCount >= tier.count then
			best = tier.name
		end
	end
	return best
end

local function updatePlayer(player: Player)
	local data = PlayerDataStore.get(player)
	if not data then
		return
	end

	local title = titleForHostCount(data.party.hostCount)
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
