--!strict
-- Client bootstrap. Each system's require() AND init() are individually wrapped in pcall so one
-- system failing to even load can't silently prevent everything listed after it from starting.
-- Check the Output window for "init.client:" lines if something isn't showing up.

local SYSTEM_NAMES = {
	"OnboardingClient",
	"MainMenuClient",
	"NametagClient",
	"PartyMusicClient",
	"AmbientMusicClient",
	"SystemFeedbackClient",
	"PlayerVoiceVolumeClient",
	"PlayerContextMenuClient",
	"SprintClient",
	"FlyClient",
	"ModRadioClient",
	"PlaytimeClient",
	"BalloonClient",
	"DuoInviteClient",
	"NotificationsClient",
	"PhoneClient",
	"RainbowStickOfferClient",
	"DanceMenuClient",
}

for _, name in ipairs(SYSTEM_NAMES) do
	local moduleScript = script.Systems:FindFirstChild(name)
	if not moduleScript then
		warn(("init.client: %s not found under Client/Systems"):format(name))
	else
		local requireSuccess, moduleOrError = pcall(require, moduleScript)
		if not requireSuccess then
			warn(("init.client: %s failed to load: %s"):format(name, tostring(moduleOrError)))
		else
			local initSuccess, initError = pcall(function()
				(moduleOrError :: any).init()
			end)
			if not initSuccess then
				warn(("init.client: %s failed to initialize: %s"):format(name, tostring(initError)))
			end
		end
	end
end
