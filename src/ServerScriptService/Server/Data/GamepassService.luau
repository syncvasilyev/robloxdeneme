--!strict
-- Cached wrapper around MarketplaceService:UserOwnsGamePassAsync. Ownership rarely changes
-- mid-session and the raw API is rate-limited, so results are cached per (player, gamepassId)
-- and refreshed immediately on a successful in-game purchase.

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local GamepassService = {}

local cache: { [Player]: { [number]: boolean } } = {}

function GamepassService.playerOwns(player: Player, gamepassId: number): boolean
	if gamepassId == 0 then
		return false
	end

	local playerCache = cache[player]
	if not playerCache then
		playerCache = {}
		cache[player] = playerCache
	end

	local cached = playerCache[gamepassId]
	if cached ~= nil then
		return cached
	end

	local success, owns = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamepassId)
	end)

	local result = success and owns == true
	playerCache[gamepassId] = result
	return result
end

function GamepassService.init()
	Players.PlayerRemoving:Connect(function(player)
		cache[player] = nil
	end)

	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamepassId, wasPurchased)
		if not wasPurchased then
			return
		end
		local playerCache = cache[player]
		if not playerCache then
			playerCache = {}
			cache[player] = playerCache
		end
		playerCache[gamepassId] = true
	end)
end

return GamepassService
