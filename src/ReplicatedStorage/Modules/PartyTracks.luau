--!strict
-- Placeholder Disco/Party track list. Replace assetId with real rbxassetid:// values for audio
-- you own the rights to or that's licensed for Roblox use — Roblox strictly enforces audio
-- copyright, and uploading music without rights can get the asset (or the account) moderated.

export type Track = { id: string, name: string, assetId: string }

local tracks: { Track } = {
	{ id = "track1", name = "Soft Wave", assetId = "rbxassetid://0" },
	{ id = "track2", name = "Neon Nights", assetId = "rbxassetid://0" },
	{ id = "track3", name = "Midnight Drive", assetId = "rbxassetid://0" },
}

return tracks
