--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Modules.Remotes)
local PlayerDataStore = require(script.Parent.Parent.Data.PlayerDataStore)

local SettingsSystem = {}

local getSettingsFunction = Remotes.getFunction("GetSettings")
local updateSettingsFunction = Remotes.getFunction("UpdateSettings")

local function onGetSettings(player: Player)
	local data = PlayerDataStore.get(player)
	return data and data.settings or nil
end

local function onUpdateSettings(player: Player, payload: any)
	local data = PlayerDataStore.get(player)
	if not data or type(payload) ~= "table" then
		return { success = false }
	end

	if type(payload.musicVolume) == "number" then
		data.settings.musicVolume = math.clamp(payload.musicVolume, 0, 1)
	end

	PlayerDataStore.save(player)
	return { success = true, settings = data.settings }
end

function SettingsSystem.init()
	getSettingsFunction.OnServerInvoke = onGetSettings
	updateSettingsFunction.OnServerInvoke = onUpdateSettings
end

return SettingsSystem
