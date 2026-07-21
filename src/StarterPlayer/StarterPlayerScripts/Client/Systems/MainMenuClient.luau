--!strict
-- Registers the + menu's tabs (the game-systems control center — Character, Group, Party,
-- Audio, Premium — plus Profile/Duo/Settings, which are also reachable from the phone; see
-- PhoneClient). Each tab reuses the same content builder the phone uses for shared ones.

local MainMenuUI = require(script.Parent.Parent.UI.MainMenu.MainMenuUI)
local OnboardingClient = require(script.Parent.OnboardingClient)
local ProfileClient = require(script.Parent.ProfileClient)
local ProfileTabUI = require(script.Parent.Parent.UI.ProfileTabUI)
local GroupClient = require(script.Parent.GroupClient)
local GroupTabUI = require(script.Parent.Parent.UI.GroupTabUI)
local PartyClient = require(script.Parent.PartyClient)
local PartyTabUI = require(script.Parent.Parent.UI.PartyTabUI)
local AmbientMusicClient = require(script.Parent.AmbientMusicClient)
local AudioTabUI = require(script.Parent.Parent.UI.AudioTabUI)
local CosmeticsClient = require(script.Parent.CosmeticsClient)
local CharacterTabUI = require(script.Parent.Parent.UI.CharacterTabUI)
local PremiumTabUI = require(script.Parent.Parent.UI.PremiumTabUI)
local DuoClient = require(script.Parent.DuoClient)
local DuoTabUI = require(script.Parent.Parent.UI.DuoTabUI)
local SettingsTabUI = require(script.Parent.Parent.UI.SettingsTabUI)

local MainMenuClient = {}

function MainMenuClient.init()
	MainMenuUI.init()

	MainMenuUI.registerTab("PROFILE", "Profil", function(parent: Frame)
		ProfileTabUI.build(parent, ProfileClient, CosmeticsClient)
	end)
	MainMenuUI.registerTab("CHARACTER", "Karakter", function(parent: Frame)
		CharacterTabUI.build(parent, CosmeticsClient)
	end)
	MainMenuUI.registerTab("GROUP", "Grup", function(parent: Frame)
		GroupTabUI.build(parent, GroupClient)
	end)
	MainMenuUI.registerTab("DUO", "Duo", function(parent: Frame)
		DuoTabUI.build(parent, DuoClient)
	end)
	MainMenuUI.registerTab("PARTY", "Parti", function(parent: Frame)
		PartyTabUI.build(parent, PartyClient)
	end)
	MainMenuUI.registerTab("AUDIO", "Ses", function(parent: Frame)
		AudioTabUI.build(parent, AmbientMusicClient)
	end)
	MainMenuUI.registerTab("PREMIUM", "Premium", function(parent: Frame)
		PremiumTabUI.build(parent)
	end)
	MainMenuUI.registerTab("SETTINGS", "Ayarlar", function(parent: Frame)
		SettingsTabUI.build(parent, OnboardingClient, MainMenuUI)
	end)
end

return MainMenuClient
