--!strict
-- Server bootstrap. Each system's init() is isolated with pcall so one system's failure can't
-- silently prevent everything after it from starting — failures are printed as clear warnings
-- instead (check the Output window for "init.server: X failed" if something isn't working).

local PlayerDataStore = require(script.Data.PlayerDataStore)
local GamepassService = require(script.Data.GamepassService)
local PurchaseSystem = require(script.Systems.PurchaseSystem)
local OnboardingSystem = require(script.Systems.OnboardingSystem)
local ProfileSystem = require(script.Systems.ProfileSystem)
local GroupSystem = require(script.Systems.GroupSystem)
local PartySystem = require(script.Systems.PartySystem)
local SettingsSystem = require(script.Systems.SettingsSystem)
local CosmeticsSystem = require(script.Systems.CosmeticsSystem)
local CharSystem = require(script.Systems.CharSystem)
local ReportSystem = require(script.Systems.ReportSystem)
local PlaytimeSystem = require(script.Systems.PlaytimeSystem)
local SprintSystem = require(script.Systems.SprintSystem)
local ModRadioSystem = require(script.Systems.ModRadioSystem)
local ModAdminSystem = require(script.Systems.ModAdminSystem)
local PartyHostTitleSystem = require(script.Systems.PartyHostTitleSystem)
local DuoSystem = require(script.Systems.DuoSystem)

local systems = {
	{ name = "PlayerDataStore", module = PlayerDataStore },
	{ name = "GamepassService", module = GamepassService },
	{ name = "PurchaseSystem", module = PurchaseSystem },
	{ name = "OnboardingSystem", module = OnboardingSystem },
	{ name = "ProfileSystem", module = ProfileSystem },
	{ name = "GroupSystem", module = GroupSystem },
	{ name = "PartySystem", module = PartySystem },
	{ name = "SettingsSystem", module = SettingsSystem },
	{ name = "CosmeticsSystem", module = CosmeticsSystem },
	{ name = "CharSystem", module = CharSystem },
	{ name = "ReportSystem", module = ReportSystem },
	{ name = "PlaytimeSystem", module = PlaytimeSystem },
	{ name = "SprintSystem", module = SprintSystem },
	{ name = "ModRadioSystem", module = ModRadioSystem },
	{ name = "ModAdminSystem", module = ModAdminSystem },
	{ name = "PartyHostTitleSystem", module = PartyHostTitleSystem },
	{ name = "DuoSystem", module = DuoSystem },
}

for _, system in ipairs(systems) do
	local success, err = pcall(function()
		system.module.init()
	end)
	if not success then
		warn(("init.server: %s failed to initialize: %s"):format(system.name, tostring(err)))
	end
end
