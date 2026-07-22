--!strict
-- Server bootstrap. Each system's require() AND init() are individually wrapped in pcall so one
-- system failing to even load can't silently prevent everything listed after it from starting.
-- Check the Output window for "init.server:" lines if something isn't working.

local SYSTEM_NAMES = {
	{ name = "MapBuilder", folder = "Systems" },
	{ name = "DiscoBuilder", folder = "Systems" },
	{ name = "PlayerDataStore", folder = "Data" },
	{ name = "GamepassService", folder = "Data" },
	{ name = "PurchaseSystem", folder = "Systems" },
	{ name = "OnboardingSystem", folder = "Systems" },
	{ name = "ProfileSystem", folder = "Systems" },
	{ name = "GroupSystem", folder = "Systems" },
	{ name = "PartySystem", folder = "Systems" },
	{ name = "SettingsSystem", folder = "Systems" },
	{ name = "CosmeticsSystem", folder = "Systems" },
	{ name = "CharSystem", folder = "Systems" },
	{ name = "ReportSystem", folder = "Systems" },
	{ name = "PlaytimeSystem", folder = "Systems" },
	{ name = "SprintSystem", folder = "Systems" },
	{ name = "ModRadioSystem", folder = "Systems" },
	{ name = "ModAdminSystem", folder = "Systems" },
	{ name = "PartyHostTitleSystem", folder = "Systems" },
	{ name = "DuoSystem", folder = "Systems" },
}

for _, entry in ipairs(SYSTEM_NAMES) do
	local folder = script:FindFirstChild(entry.folder)
	local moduleScript = folder and folder:FindFirstChild(entry.name)
	if not moduleScript then
		warn(("init.server: %s not found under Server/%s"):format(entry.name, entry.folder))
	else
		local requireSuccess, moduleOrError = pcall(require, moduleScript)
		if not requireSuccess then
			warn(("init.server: %s failed to load: %s"):format(entry.name, tostring(moduleOrError)))
		else
			local initSuccess, initError = pcall(function()
				(moduleOrError :: any).init()
			end)
			if not initSuccess then
				warn(("init.server: %s failed to initialize: %s"):format(entry.name, tostring(initError)))
			end
		end
	end
end
