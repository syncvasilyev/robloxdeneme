--!strict
-- Handles nickname/bio reads and writes. Text shown to other players (nickname, bio) must go
-- through Roblox's text filter via GetNonChatStringForBroadcastAsync before being persisted.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")

local Remotes = require(ReplicatedStorage.Modules.Remotes)
local PlayerDataStore = require(script.Parent.Parent.Data.PlayerDataStore)

local ProfileSystem = {}

local MAX_NICKNAME_LENGTH = 20
local MAX_BIO_LENGTH = 150

local updateProfileFunction = Remotes.getFunction("UpdateProfile")
local getProfileFunction = Remotes.getFunction("GetProfile")

local function trim(text: string): string
	return (text:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function filterForBroadcast(player: Player, text: string): (boolean, string)
	local success, result = pcall(function()
		local filterResult = TextService:FilterStringAsync(text, player.UserId)
		return filterResult:GetNonChatStringForBroadcastAsync()
	end)
	if success then
		return true, result
	end
	return false, tostring(result)
end

local function onUpdateProfile(player: Player, payload: any)
	local data = PlayerDataStore.get(player)
	if not data then
		return { success = false, error = "Profil henüz yüklenmedi." }
	end
	if type(payload) ~= "table" then
		return { success = false, error = "Geçersiz istek." }
	end

	if payload.nickname ~= nil then
		if type(payload.nickname) ~= "string" then
			return { success = false, error = "Geçersiz nickname." }
		end
		local nickname = trim(payload.nickname):sub(1, MAX_NICKNAME_LENGTH)
		if nickname == "" then
			return { success = false, error = "Nickname boş olamaz." }
		end
		local filtered, result = filterForBroadcast(player, nickname)
		if not filtered then
			return { success = false, error = "Nickname filtrelenemedi, tekrar dene." }
		end
		data.profile.nickname = result
		player:SetAttribute("Nickname", result)
	end

	if payload.bio ~= nil then
		if type(payload.bio) ~= "string" then
			return { success = false, error = "Geçersiz bio." }
		end
		local bio = trim(payload.bio):sub(1, MAX_BIO_LENGTH)
		local filtered, result = filterForBroadcast(player, bio)
		if not filtered then
			return { success = false, error = "Bio filtrelenemedi, tekrar dene." }
		end
		data.profile.bio = result
	end

	PlayerDataStore.save(player)

	return { success = true, profile = data.profile }
end

local function onGetProfile(player: Player)
	local data = PlayerDataStore.get(player)
	if not data then
		return nil
	end
	return data.profile
end

function ProfileSystem.init()
	updateProfileFunction.OnServerInvoke = onUpdateProfile
	getProfileFunction.OnServerInvoke = onGetProfile
end

return ProfileSystem
