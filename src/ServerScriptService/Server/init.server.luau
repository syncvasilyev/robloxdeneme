--!strict
-- Server bootstrap: initializes data layer first, then gameplay systems that depend on it.

local PlayerDataStore = require(script.Data.PlayerDataStore)
local OnboardingSystem = require(script.Systems.OnboardingSystem)

PlayerDataStore.init()
OnboardingSystem.init()
