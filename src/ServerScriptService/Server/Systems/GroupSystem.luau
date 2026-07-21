--!strict
-- Lightweight in-game "party group" tag system: create a group, share a join code, up to 5
-- members, shared nickname color shown above members' heads. Membership is per-server/session,
-- not persisted — this is a social tag, not Roblox's own Group/rank system.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local Remotes = require(ReplicatedStorage.Modules.Remotes)
local ProductIds = require(ReplicatedStorage.Modules.ProductIds)
local PurchaseSystem = require(script.Parent.PurchaseSystem)

local GroupSystem = {}

local MAX_MEMBERS = 5
local DEFAULT_COLOR = Color3.fromRGB(245, 245, 245)
local CODE_CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"

type Group = {
	code: string,
	members: { Player },
	color: Color3,
}

local groupsByCode: { [string]: Group } = {}
local groupByPlayer: { [Player]: Group } = {}
local pendingColorChange: { [Player]: Color3 } = {}

local createGroupEvent = Remotes.getEvent("CreateGroup")
local joinGroupEvent = Remotes.getEvent("JoinGroup")
local leaveGroupEvent = Remotes.getEvent("LeaveGroup")
local requestColorChangeEvent = Remotes.getEvent("RequestGroupColorChange")
local groupStateEvent = Remotes.getEvent("GroupStateChanged")

local function generateCode(): string
	local code
	repeat
		local parts = {}
		for _ = 1, 5 do
			local index = math.random(1, #CODE_CHARS)
			table.insert(parts, CODE_CHARS:sub(index, index))
		end
		code = table.concat(parts)
	until not groupsByCode[code]
	return code
end

local function applyNicknameColor(player: Player)
	local group = groupByPlayer[player]
	player:SetAttribute("NicknameColor", if group then group.color else DEFAULT_COLOR)
end

local function broadcastGroupState(group: Group)
	local memberNames = {}
	for _, member in ipairs(group.members) do
		table.insert(memberNames, member.Name)
	end
	for _, member in ipairs(group.members) do
		groupStateEvent:FireClient(member, {
			code = group.code,
			members = memberNames,
			color = group.color,
		})
	end
end

local function removePlayerFromGroup(player: Player)
	local group = groupByPlayer[player]
	if not group then
		return
	end

	for i, member in ipairs(group.members) do
		if member == player then
			table.remove(group.members, i)
			break
		end
	end
	groupByPlayer[player] = nil
	applyNicknameColor(player)
	groupStateEvent:FireClient(player, nil)

	if #group.members == 0 then
		groupsByCode[group.code] = nil
	else
		broadcastGroupState(group)
	end
end

local function onCreateGroup(player: Player)
	if groupByPlayer[player] then
		removePlayerFromGroup(player)
	end

	local group: Group = {
		code = generateCode(),
		members = { player },
		color = DEFAULT_COLOR,
	}
	groupsByCode[group.code] = group
	groupByPlayer[player] = group
	applyNicknameColor(player)
	broadcastGroupState(group)
end

local function onJoinGroup(player: Player, code: any)
	if type(code) ~= "string" then
		return
	end
	local group = groupsByCode[code:upper()]
	if not group then
		groupStateEvent:FireClient(player, { error = "Kod bulunamadı." })
		return
	end
	if #group.members >= MAX_MEMBERS then
		groupStateEvent:FireClient(player, { error = "Grup dolu." })
		return
	end
	if groupByPlayer[player] then
		removePlayerFromGroup(player)
	end

	table.insert(group.members, player)
	groupByPlayer[player] = group
	applyNicknameColor(player)
	broadcastGroupState(group)
end

local function onLeaveGroup(player: Player)
	removePlayerFromGroup(player)
end

local function onRequestColorChange(player: Player, colorPayload: any)
	if not groupByPlayer[player] then
		return
	end
	if typeof(colorPayload) ~= "Color3" then
		return
	end
	if ProductIds.GroupColorChange == 0 then
		warn("GroupSystem: ProductIds.GroupColorChange is not configured yet.")
		return
	end

	pendingColorChange[player] = colorPayload
	local success = pcall(function()
		MarketplaceService:PromptProductPurchase(player, ProductIds.GroupColorChange)
	end)
	if not success then
		pendingColorChange[player] = nil
	end
end

local function onGroupColorChangeReceipt(player: Player)
	local group = groupByPlayer[player]
	local newColor = pendingColorChange[player]
	if group and newColor then
		group.color = newColor
		for _, member in ipairs(group.members) do
			applyNicknameColor(member)
		end
		broadcastGroupState(group)
	end
	pendingColorChange[player] = nil

	return Enum.ProductPurchaseDecision.PurchaseGranted
end

function GroupSystem.init()
	createGroupEvent.OnServerEvent:Connect(onCreateGroup)
	joinGroupEvent.OnServerEvent:Connect(onJoinGroup)
	leaveGroupEvent.OnServerEvent:Connect(onLeaveGroup)
	requestColorChangeEvent.OnServerEvent:Connect(onRequestColorChange)

	Players.PlayerRemoving:Connect(removePlayerFromGroup)

	PurchaseSystem.registerHandler(ProductIds.GroupColorChange, function(player)
		return onGroupColorChangeReceipt(player)
	end)
end

return GroupSystem
