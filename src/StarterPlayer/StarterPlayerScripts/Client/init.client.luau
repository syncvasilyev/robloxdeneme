--!strict
-- Client bootstrap.

local OnboardingClient = require(script.Systems.OnboardingClient)
local MainMenuClient = require(script.Systems.MainMenuClient)
local NametagClient = require(script.Systems.NametagClient)
local PartyMusicClient = require(script.Systems.PartyMusicClient)
local AmbientMusicClient = require(script.Systems.AmbientMusicClient)
local CharFeedbackClient = require(script.Systems.CharFeedbackClient)
local PlayerVoiceVolumeClient = require(script.Systems.PlayerVoiceVolumeClient)
local PlayerContextMenuClient = require(script.Systems.PlayerContextMenuClient)

OnboardingClient.init()
MainMenuClient.init()
NametagClient.init()
PartyMusicClient.init()
AmbientMusicClient.init()
CharFeedbackClient.init()
PlayerVoiceVolumeClient.init()
PlayerContextMenuClient.init()
