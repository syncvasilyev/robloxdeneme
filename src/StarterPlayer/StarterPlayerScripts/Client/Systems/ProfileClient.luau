--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Modules.Remotes)

local ProfileClient = {}

local updateProfileFunction = Remotes.getFunction("UpdateProfile")
local getProfileFunction = Remotes.getFunction("GetProfile")

export type ProfileResult = {
	success: boolean,
	error: string?,
	profile: { nickname: string, bio: string, profilePhotoId: number }?,
}

function ProfileClient.getProfile(): { nickname: string, bio: string, profilePhotoId: number }?
	local success, result = pcall(function()
		return getProfileFunction:InvokeServer()
	end)
	if success then
		return result
	end
	return nil
end

function ProfileClient.updateProfile(payload: { nickname: string?, bio: string? }): ProfileResult
	local success, result = pcall(function()
		return updateProfileFunction:InvokeServer(payload)
	end)
	if success then
		return result
	end
	return { success = false, error = "Sunucuya ulaşılamadı." }
end

return ProfileClient
