--!strict
-- Placeholder cosmetic content. Asset ids are 0 until real, owned/licensed assets are uploaded
-- in Studio — LARP outfits and profile photos in particular need real clothing/decal assets
-- before they'll show anything. The Trail textures below use Roblox's built-in particle
-- textures as a stand-in and can stay as-is or be swapped for custom ones.

export type LarpOutfit = { id: string, name: string, shirtId: number, pantsId: number }
export type ProfilePhoto = { id: string, name: string, imageId: string }
export type TrailConfig = { Color: ColorSequence, Lifetime: number, Texture: string }

local CosmeticPresets = {
	LarpOutfits = {
		{ id = "larp1", name = "Gece Kulübü", shirtId = 0, pantsId = 0 },
		{ id = "larp2", name = "Sokak Stili", shirtId = 0, pantsId = 0 },
	} :: { LarpOutfit },

	ProfilePhotos = {
		{ id = "photo1", name = "Klasik", imageId = "rbxassetid://0" },
		{ id = "photo2", name = "Neon", imageId = "rbxassetid://0" },
		{ id = "photo3", name = "Minimal", imageId = "rbxassetid://0" },
	} :: { ProfilePhoto },

	Trails = {
		Normal = {
			Color = ColorSequence.new(Color3.fromRGB(139, 0, 0)),
			Lifetime = 1,
			Texture = "rbxasset://textures/particles/fire_main.dds",
		},
		Flying = {
			Color = ColorSequence.new(Color3.fromRGB(255, 215, 0)),
			Lifetime = 1.6,
			Texture = "rbxasset://textures/particles/sparkles_main.dds",
		},
	} :: { [string]: TrailConfig },
}

return CosmeticPresets
