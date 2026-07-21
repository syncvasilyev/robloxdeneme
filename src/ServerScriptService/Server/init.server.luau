--!strict
-- Server bootstrap: initializes data layer first, then gameplay systems that depend on it.

local PlayerDataStore = require(script.Data.PlayerDataStore)
local PurchaseSystem = require(script.Systems.PurchaseSystem)
local OnboardingSystem = require(script.Systems.OnboardingSystem)
local ProfileSystem = require(script.Systems.ProfileSystem)
local GroupSystem = require(script.Systems.GroupSystem)

PlayerDataStore.init()
PurchaseSystem.init()
OnboardingSystem.init()
ProfileSystem.init()
GroupSystem.init()
