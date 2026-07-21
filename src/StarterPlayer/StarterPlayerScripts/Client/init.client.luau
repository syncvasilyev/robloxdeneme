--!strict
-- Client bootstrap. Each system's init() is isolated with pcall so one system's failure can't
-- silently prevent everything after it from starting — failures are printed as clear warnings
-- instead (check the Output window for "init.client: X failed" if something isn't showing up).

local OnboardingClient = require(script.Systems.OnboardingClient)
local MainMenuClient = require(script.Systems.MainMenuClient)
local NametagClient = require(script.Systems.NametagClient)
local PartyMusicClient = require(script.Systems.PartyMusicClient)
local AmbientMusicClient = require(script.Systems.AmbientMusicClient)
local SystemFeedbackClient = require(script.Systems.SystemFeedbackClient)
local PlayerVoiceVolumeClient = require(script.Systems.PlayerVoiceVolumeClient)
local PlayerContextMenuClient = require(script.Systems.PlayerContextMenuClient)
local SprintClient = require(script.Systems.SprintClient)
local FlyClient = require(script.Systems.FlyClient)
local ModRadioClient = require(script.Systems.ModRadioClient)
local PlaytimeClient = require(script.Systems.PlaytimeClient)
local BalloonClient = require(script.Systems.BalloonClient)
local DuoInviteClient = require(script.Systems.DuoInviteClient)
local NotificationsClient = require(script.Systems.NotificationsClient)
local PhoneClient = require(script.Systems.PhoneClient)

local systems = {
	{ name = "OnboardingClient", module = OnboardingClient },
	{ name = "MainMenuClient", module = MainMenuClient },
	{ name = "NametagClient", module = NametagClient },
	{ name = "PartyMusicClient", module = PartyMusicClient },
	{ name = "AmbientMusicClient", module = AmbientMusicClient },
	{ name = "SystemFeedbackClient", module = SystemFeedbackClient },
	{ name = "PlayerVoiceVolumeClient", module = PlayerVoiceVolumeClient },
	{ name = "PlayerContextMenuClient", module = PlayerContextMenuClient },
	{ name = "SprintClient", module = SprintClient },
	{ name = "FlyClient", module = FlyClient },
	{ name = "ModRadioClient", module = ModRadioClient },
	{ name = "PlaytimeClient", module = PlaytimeClient },
	{ name = "BalloonClient", module = BalloonClient },
	{ name = "DuoInviteClient", module = DuoInviteClient },
	{ name = "NotificationsClient", module = NotificationsClient },
	{ name = "PhoneClient", module = PhoneClient },
}

for _, system in ipairs(systems) do
	local success, err = pcall(function()
		system.module.init()
	end)
	if not success then
		warn(("init.client: %s failed to initialize: %s"):format(system.name, tostring(err)))
	end
end
