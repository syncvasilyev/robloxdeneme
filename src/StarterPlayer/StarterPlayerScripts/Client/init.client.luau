--!strict
-- Client bootstrap.

local OnboardingClient = require(script.Systems.OnboardingClient)
local MainMenuClient = require(script.Systems.MainMenuClient)
local NametagClient = require(script.Systems.NametagClient)
local PartyMusicClient = require(script.Systems.PartyMusicClient)
local AmbientMusicClient = require(script.Systems.AmbientMusicClient)

OnboardingClient.init()
MainMenuClient.init()
NametagClient.init()
PartyMusicClient.init()
AmbientMusicClient.init()
