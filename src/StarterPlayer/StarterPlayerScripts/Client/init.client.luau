--!strict
-- Client bootstrap.

local OnboardingClient = require(script.Systems.OnboardingClient)
local MainMenuClient = require(script.Systems.MainMenuClient)
local NametagClient = require(script.Systems.NametagClient)

OnboardingClient.init()
MainMenuClient.init()
NametagClient.init()
