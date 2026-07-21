--!strict
-- Combines the Mod gamepass and the hardcoded Admin UserId list into simple isMod/isAdmin
-- checks. Admins are a superset of Mods — anything a Mod can do, an Admin can too.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GamepassIds = require(ReplicatedStorage.Modules.GamepassIds)
local StaffIds = require(ReplicatedStorage.Modules.StaffIds)
local GamepassService = require(script.Parent.GamepassService)

local StaffService = {}

function StaffService.isAdmin(player: Player): boolean
	return table.find(StaffIds, player.UserId) ~= nil
end

function StaffService.isMod(player: Player): boolean
	return StaffService.isAdmin(player) or GamepassService.playerOwns(player, GamepassIds.Mod)
end

return StaffService
