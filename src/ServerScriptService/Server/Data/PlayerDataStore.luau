--!strict
-- Minimal DataStore wrapper: loads/saves a per-player profile with autosave and reconciliation
-- against a default template so newly added fields backfill on old saves. Single-server-per-player
-- games only — this does not implement cross-server session locking (see ProfileService if that
-- becomes necessary later).

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local PlayerDataStore = {}

local STORE_NAME = "PlayerData_v1"
local dataStore = DataStoreService:GetDataStore(STORE_NAME)
local AUTOSAVE_INTERVAL_SECONDS = 120

local DEFAULT_DATA = {
	onboardingCompleted = false,
	loginCount = 0,
	profile = {
		nickname = "",
		bio = "",
		profilePhotoId = "", -- id into CosmeticPresets.ProfilePhotos, "" = default avatar thumbnail
	},
	cosmetics = {
		rainbowNickname = false,
		r6Mode = false,
		trail = "None", -- "None" | "Normal" | "Flying"
		-- larpOutfitId is intentionally absent here: its default is nil, and nil-valued keys
		-- can't be reconciled from a table literal anyway (see `reconcile` below), so it's just
		-- read as nil until a player equips an outfit.
	},
	-- Group membership (see GroupSystem) is intentionally not persisted here — it's a
	-- per-server social tag, not saved player state.
	party = {
		hostCount = 0,
		totalGuestJoins = 0, -- cumulative joins across every party this player has hosted (see PARTY KING title)
		rainbowStickOffered = false,
	},
	duo = {
		optIn = false,
		interests = {},
	},
	playtimeSeconds = 0,
	rewards = {
		balloon50h = false,
		speedBoost100h = false,
	},
	settings = {
		musicVolume = 0.5,
		playerVolumeOverrides = {},
	},
}

local function deepCopy(tbl: { [any]: any }): { [any]: any }
	local copy = {}
	for key, value in pairs(tbl) do
		if type(value) == "table" then
			copy[key] = deepCopy(value)
		else
			copy[key] = value
		end
	end
	return copy
end

local function reconcile(data: { [any]: any }, template: { [any]: any }): { [any]: any }
	for key, value in pairs(template) do
		if data[key] == nil then
			data[key] = if type(value) == "table" then deepCopy(value) else value
		elseif type(value) == "table" and type(data[key]) == "table" then
			reconcile(data[key], value)
		end
	end
	return data
end

local profiles = {} :: { [Player]: { [any]: any } }
local sessionStartTimes = {} :: { [Player]: number }

local function loadProfile(player: Player)
	local key = "Player_" .. player.UserId
	local success, result = pcall(function()
		return dataStore:GetAsync(key)
	end)

	local data
	if success and result then
		data = reconcile(result, DEFAULT_DATA)
	else
		if not success then
			warn(("PlayerDataStore: failed to load data for %s: %s"):format(player.Name, tostring(result)))
		end
		data = deepCopy(DEFAULT_DATA)
	end

	data.loginCount += 1
	profiles[player] = data
	sessionStartTimes[player] = os.time()

	-- Replicated to all clients so nametags (see NametagClient) can show the chosen nickname.
	player:SetAttribute("Nickname", if data.profile.nickname ~= "" then data.profile.nickname else player.DisplayName)
	player:SetAttribute("RainbowNickname", data.cosmetics.rainbowNickname)
	if not player:GetAttribute("NicknameColor") then
		player:SetAttribute("NicknameColor", Color3.fromRGB(245, 245, 245))
	end
end

local function saveProfile(player: Player)
	local data = profiles[player]
	if not data then
		return
	end

	local elapsed = os.time() - (sessionStartTimes[player] or os.time())
	data.playtimeSeconds += elapsed
	sessionStartTimes[player] = os.time()

	local key = "Player_" .. player.UserId
	local success, err = pcall(function()
		dataStore:SetAsync(key, data)
	end)
	if not success then
		warn(("PlayerDataStore: failed to save data for %s: %s"):format(player.Name, tostring(err)))
	end
end

--- Returns the loaded profile table for a player, or nil if it hasn't loaded yet.
function PlayerDataStore.get(player: Player): { [any]: any }?
	return profiles[player]
end

--- Blocks the calling thread until the player's profile has loaded (or they leave / timeout).
function PlayerDataStore.waitForProfile(player: Player, timeoutSeconds: number?): { [any]: any }?
	local deadline = os.clock() + (timeoutSeconds or 15)
	while player.Parent and not profiles[player] do
		if os.clock() > deadline then
			warn(("PlayerDataStore: timed out waiting for %s's profile"):format(player.Name))
			return nil
		end
		task.wait(0.1)
	end
	return profiles[player]
end

--- Forces an immediate save (e.g. right after a critical flag like onboardingCompleted changes).
function PlayerDataStore.save(player: Player)
	saveProfile(player)
end

--- Playtime including the current, not-yet-saved session (playtimeSeconds is only updated on
--- save). Returns nil if the profile hasn't loaded yet.
function PlayerDataStore.getLivePlaytimeSeconds(player: Player): number?
	local data = profiles[player]
	if not data then
		return nil
	end
	local sessionStart = sessionStartTimes[player] or os.time()
	return data.playtimeSeconds + (os.time() - sessionStart)
end

function PlayerDataStore.init()
	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(loadProfile, player)
	end

	Players.PlayerAdded:Connect(loadProfile)
	Players.PlayerRemoving:Connect(function(player)
		saveProfile(player)
		profiles[player] = nil
		sessionStartTimes[player] = nil
	end)

	game:BindToClose(function()
		if RunService:IsStudio() then
			return
		end
		for _, player in ipairs(Players:GetPlayers()) do
			saveProfile(player)
		end
	end)

	task.spawn(function()
		while true do
			task.wait(AUTOSAVE_INTERVAL_SECONDS)
			for _, player in ipairs(Players:GetPlayers()) do
				saveProfile(player)
			end
		end
	end)
end

return PlayerDataStore
