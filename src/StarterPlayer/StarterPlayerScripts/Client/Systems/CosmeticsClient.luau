--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Modules.Remotes)

local CosmeticsClient = {}

local setR6ModeEvent = Remotes.getEvent("SetR6Mode")
local setRainbowNicknameEvent = Remotes.getEvent("SetRainbowNickname")
local setTrailEvent = Remotes.getEvent("SetTrail")
local setLarpOutfitEvent = Remotes.getEvent("SetLarpOutfit")
local setProfilePhotoFunction = Remotes.getFunction("SetProfilePhoto")

function CosmeticsClient.setR6Mode(value: boolean)
	setR6ModeEvent:FireServer(value)
end

function CosmeticsClient.setRainbowNickname(value: boolean)
	setRainbowNicknameEvent:FireServer(value)
end

function CosmeticsClient.setTrail(trailType: string)
	setTrailEvent:FireServer(trailType)
end

function CosmeticsClient.setLarpOutfit(outfitId: string?)
	setLarpOutfitEvent:FireServer(outfitId)
end

function CosmeticsClient.setProfilePhoto(photoId: string)
	local success, result = pcall(function()
		return setProfilePhotoFunction:InvokeServer(photoId)
	end)
	if success then
		return result
	end
	return { success = false, error = "Sunucuya ulaşılamadı." }
end

return CosmeticsClient
