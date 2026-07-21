--!strict
-- Cosmetic gamepass features: R6 mode, rainbow nickname, trails, LARP outfits, profile photo.
-- Each toggle is gated behind its gamepass via the cached GamepassService.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Modules.Remotes)
local GamepassIds = require(ReplicatedStorage.Modules.GamepassIds)
local CosmeticPresets = require(ReplicatedStorage.Modules.CosmeticPresets)
local GamepassService = require(script.Parent.Parent.Data.GamepassService)
local PlayerDataStore = require(script.Parent.Parent.Data.PlayerDataStore)

local CosmeticsSystem = {}

local setR6ModeEvent = Remotes.getEvent("SetR6Mode")
local setRainbowNicknameEvent = Remotes.getEvent("SetRainbowNickname")
local setTrailEvent = Remotes.getEvent("SetTrail")
local setLarpOutfitEvent = Remotes.getEvent("SetLarpOutfit")
local setProfilePhotoFunction = Remotes.getFunction("SetProfilePhoto")

local function respawnWithRigType(player: Player, rigType: Enum.HumanoidRigType)
	local success, err = pcall(function()
		local oldCharacter = player.Character
		local humanoidDescription = Players:GetHumanoidDescriptionFromUserId(player.UserId)
		local newCharacter = Players:CreateHumanoidModelFromDescription(humanoidDescription, rigType)
		newCharacter.Name = player.Name

		if oldCharacter then
			local oldRoot = oldCharacter:FindFirstChild("HumanoidRootPart") :: BasePart?
			if oldRoot then
				newCharacter:PivotTo(oldRoot.CFrame)
			end
		end

		newCharacter.Parent = Workspace
		player.Character = newCharacter

		if oldCharacter then
			oldCharacter:Destroy()
		end
	end)
	if not success then
		warn(("CosmeticsSystem: failed to switch rig type for %s: %s"):format(player.Name, tostring(err)))
	end
end

local function applyTrail(character: Model, trailType: string)
	local rootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not rootPart then
		return
	end

	local existing = rootPart:FindFirstChild("CosmeticTrail")
	if existing then
		existing:Destroy()
	end
	local existingAttachment0 = rootPart:FindFirstChild("CosmeticTrailAttachment0")
	if existingAttachment0 then
		existingAttachment0:Destroy()
	end
	local existingAttachment1 = rootPart:FindFirstChild("CosmeticTrailAttachment1")
	if existingAttachment1 then
		existingAttachment1:Destroy()
	end

	if trailType == "None" then
		return
	end

	local config = CosmeticPresets.Trails[trailType]
	if not config then
		return
	end

	local attachment0 = Instance.new("Attachment")
	attachment0.Name = "CosmeticTrailAttachment0"
	attachment0.Position = Vector3.new(0, 1, 0.3)
	attachment0.Parent = rootPart

	local attachment1 = Instance.new("Attachment")
	attachment1.Name = "CosmeticTrailAttachment1"
	attachment1.Position = Vector3.new(0, -1, 0.3)
	attachment1.Parent = rootPart

	local trail = Instance.new("Trail")
	trail.Name = "CosmeticTrail"
	trail.Attachment0 = attachment0
	trail.Attachment1 = attachment1
	trail.Color = config.Color
	trail.Lifetime = config.Lifetime
	trail.Texture = config.Texture
	trail.Parent = rootPart
end

local function applyLarpOutfit(player: Player, character: Model, outfitId: string)
	local outfit
	for _, candidate in ipairs(CosmeticPresets.LarpOutfits) do
		if candidate.id == outfitId then
			outfit = candidate
			break
		end
	end
	if not outfit then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	local success, err = pcall(function()
		local description = humanoid:GetAppliedDescription()
		if outfit.shirtId > 0 then
			description.Shirt = outfit.shirtId
		end
		if outfit.pantsId > 0 then
			description.Pants = outfit.pantsId
		end
		humanoid:ApplyDescription(description)
	end)
	if not success then
		warn(("CosmeticsSystem: failed to apply LARP outfit for %s: %s"):format(player.Name, tostring(err)))
	end
end

local function reapplyCosmetics(player: Player, character: Model)
	local data = PlayerDataStore.get(player)
	if not data then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid and data.cosmetics.r6Mode and humanoid.RigType ~= Enum.HumanoidRigType.R6 then
		respawnWithRigType(player, Enum.HumanoidRigType.R6)
		return -- respawnWithRigType swaps player.Character, which fires CharacterAdded again
	end

	applyTrail(character, data.cosmetics.trail)
	if data.cosmetics.larpOutfitId then
		applyLarpOutfit(player, character, data.cosmetics.larpOutfitId)
	end
end

local function onSetR6Mode(player: Player, value: any)
	if type(value) ~= "boolean" then
		return
	end
	if value and not GamepassService.playerOwns(player, GamepassIds.R6Mode) then
		return
	end
	local data = PlayerDataStore.get(player)
	if not data then
		return
	end
	data.cosmetics.r6Mode = value
	PlayerDataStore.save(player)
	respawnWithRigType(player, if value then Enum.HumanoidRigType.R6 else Enum.HumanoidRigType.R15)
end

local function onSetRainbowNickname(player: Player, value: any)
	if type(value) ~= "boolean" then
		return
	end
	if value and not GamepassService.playerOwns(player, GamepassIds.RainbowNickname) then
		return
	end
	local data = PlayerDataStore.get(player)
	if not data then
		return
	end
	data.cosmetics.rainbowNickname = value
	PlayerDataStore.save(player)
	player:SetAttribute("RainbowNickname", value)
end

local function onSetTrail(player: Player, trailType: any)
	if type(trailType) ~= "string" then
		return
	end
	if trailType ~= "None" then
		local gamepassId = if trailType == "Flying" then GamepassIds.TrailFlying else GamepassIds.TrailNormal
		if not GamepassService.playerOwns(player, gamepassId) then
			return
		end
	end
	local data = PlayerDataStore.get(player)
	if not data then
		return
	end
	data.cosmetics.trail = trailType
	PlayerDataStore.save(player)
	if player.Character then
		applyTrail(player.Character, trailType)
	end
end

local function onSetLarpOutfit(player: Player, outfitId: any)
	if not GamepassService.playerOwns(player, GamepassIds.Larp) then
		return
	end
	if outfitId ~= nil and type(outfitId) ~= "string" then
		return
	end
	local data = PlayerDataStore.get(player)
	if not data then
		return
	end
	data.cosmetics.larpOutfitId = outfitId
	PlayerDataStore.save(player)
	if player.Character and outfitId then
		applyLarpOutfit(player, player.Character, outfitId)
	end
end

local function onSetProfilePhoto(player: Player, photoId: any)
	if not GamepassService.playerOwns(player, GamepassIds.ProfilePhoto) then
		return { success = false, error = "Profil fotoğrafı değiştirmek için Gamepass gerekiyor." }
	end
	if type(photoId) ~= "string" then
		return { success = false, error = "Geçersiz seçim." }
	end

	local exists = false
	for _, photo in ipairs(CosmeticPresets.ProfilePhotos) do
		if photo.id == photoId then
			exists = true
			break
		end
	end
	if not exists then
		return { success = false, error = "Geçersiz seçim." }
	end

	local data = PlayerDataStore.get(player)
	if not data then
		return { success = false, error = "Profil henüz yüklenmedi." }
	end
	data.profile.profilePhotoId = photoId
	PlayerDataStore.save(player)
	return { success = true, profilePhotoId = photoId }
end

function CosmeticsSystem.init()
	setR6ModeEvent.OnServerEvent:Connect(onSetR6Mode)
	setRainbowNicknameEvent.OnServerEvent:Connect(onSetRainbowNickname)
	setTrailEvent.OnServerEvent:Connect(onSetTrail)
	setLarpOutfitEvent.OnServerEvent:Connect(onSetLarpOutfit)
	setProfilePhotoFunction.OnServerInvoke = onSetProfilePhoto

	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			reapplyCosmetics(player, character)
		end)
	end)
end

return CosmeticsSystem
