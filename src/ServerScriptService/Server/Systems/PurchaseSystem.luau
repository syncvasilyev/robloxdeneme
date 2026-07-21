--!strict
-- Central dispatcher for MarketplaceService.ProcessReceipt. Only one callback can be assigned
-- to ProcessReceipt globally, so individual systems register a handler per developer product id
-- here instead of overwriting ProcessReceipt themselves.

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local PurchaseSystem = {}

export type ReceiptInfo = {
	PurchaseId: string,
	PlayerId: number,
	ProductId: number,
	CurrencySpent: number,
	CurrencyType: Enum.CurrencyType,
	PlaceIdWherePurchased: number,
}

local handlers: { [number]: (Player, ReceiptInfo) -> Enum.ProductPurchaseDecision } = {}

--- Registers the handler for a developer product id. Must return PurchaseGranted once the
--- purchased item has actually been applied, per Roblox's receipt-processing requirements.
function PurchaseSystem.registerHandler(productId: number, handler: (Player, ReceiptInfo) -> Enum.ProductPurchaseDecision)
	handlers[productId] = handler
end

local function onProcessReceipt(receiptInfo: ReceiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local handler = handlers[receiptInfo.ProductId]
	if not handler then
		warn(("PurchaseSystem: no handler registered for product %d"):format(receiptInfo.ProductId))
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local success, decision = pcall(handler, player, receiptInfo)
	if not success then
		warn(("PurchaseSystem: handler for product %d errored: %s"):format(receiptInfo.ProductId, tostring(decision)))
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	return decision :: Enum.ProductPurchaseDecision
end

function PurchaseSystem.init()
	MarketplaceService.ProcessReceipt = onProcessReceipt
end

return PurchaseSystem
