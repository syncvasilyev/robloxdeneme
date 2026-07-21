--!strict
-- Registers the phone's home-screen apps: Profil, Duo, Bildirimler, Ayarlar. Reuses the same
-- tab content builders as the + menu (ProfileTabUI, DuoTabUI, SettingsTabUI) so both entry
-- points share logic — they're separate UI shells, not separate feature implementations.

local PhoneUI = require(script.Parent.Parent.UI.Phone.PhoneUI)
local ProfileClient = require(script.Parent.ProfileClient)
local ProfileTabUI = require(script.Parent.Parent.UI.ProfileTabUI)
local CosmeticsClient = require(script.Parent.CosmeticsClient)
local DuoClient = require(script.Parent.DuoClient)
local DuoTabUI = require(script.Parent.Parent.UI.DuoTabUI)
local NotificationsClient = require(script.Parent.NotificationsClient)
local NotificationsAppUI = require(script.Parent.Parent.UI.NotificationsAppUI)
local OnboardingClient = require(script.Parent.OnboardingClient)
local SettingsTabUI = require(script.Parent.Parent.UI.SettingsTabUI)

local PhoneClient = {}

function PhoneClient.init()
	print("[TELEFON TANI] PhoneClient.init basladi")
	PhoneUI.init()
	print("[TELEFON TANI] PhoneUI.init bitti, buton olusturulmus olmali")

	PhoneUI.registerApp("PROFILE", "Profil", "👤", function(parent: Frame)
		ProfileTabUI.build(parent, ProfileClient, CosmeticsClient)
	end)
	PhoneUI.registerApp("DUO", "Duo", "❤️", function(parent: Frame)
		DuoTabUI.build(parent, DuoClient)
	end)
	PhoneUI.registerApp("NOTIFICATIONS", "Bildirimler", "🔔", function(parent: Frame)
		NotificationsAppUI.build(parent, NotificationsClient)
	end)
	PhoneUI.registerApp("SETTINGS", "Ayarlar", "⚙️", function(parent: Frame)
		SettingsTabUI.build(parent, OnboardingClient, PhoneUI)
	end)
	print("[TELEFON TANI] PhoneClient.init tamamen bitti")
end

return PhoneClient
