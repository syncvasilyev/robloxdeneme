--!strict
-- "Duo Finder": players opt in with a few interest tags and browse other opted-in players,
-- sorted by how many tags overlap, then send a simple invite (accept/decline) to team up and
-- use the existing Group/Party systems together. Deliberately not a swipe/like/match flow.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Modules.Remotes)
local DuoInterests = require(ReplicatedStorage.Modules.DuoInterests)
local PlayerDataStore = require(script.Parent.Parent.Data.PlayerDataStore)

local DuoSystem = {}

local MAX_INTERESTS = 5

local systemFeedbackEvent = Remotes.getEvent("SystemFeedback")
local setDuoProfileFunction = Remotes.getFunction("SetDuoProfile")
local listDuoPlayersFunction = Remotes.getFunction("ListDuoPlayers")
local sendDuoInviteEvent = Remotes.getEvent("SendDuoInvite")
local respondDuoInviteEvent = Remotes.getEvent("RespondDuoInvite")
local duoInviteReceivedEvent = Remotes.getEvent("DuoInviteReceived")

local function onSetDuoProfile(player: Player, payload: any)
	local data = PlayerDataStore.get(player)
	if not data or type(payload) ~= "table" then
		return { success = false }
	end

	local optIn = payload.optIn == true
	local interests = {}
	if type(payload.interests) == "table" then
		for _, tag in ipairs(payload.interests) do
			if type(tag) == "string" and table.find(DuoInterests, tag) and #interests < MAX_INTERESTS then
				table.insert(interests, tag)
			end
		end
	end

	data.duo.optIn = optIn
	data.duo.interests = interests
	PlayerDataStore.save(player)
	return { success = true, optIn = optIn, interests = interests }
end

local function overlapScore(a: { string }, b: { string }): number
	local score = 0
	for _, tagA in ipairs(a) do
		if table.find(b, tagA) then
			score += 1
		end
	end
	return score
end

local function onListDuoPlayers(player: Player)
	local myData = PlayerDataStore.get(player)
	local myInterests = if myData then myData.duo.interests else {}

	local results = {}
	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= player then
			local otherData = PlayerDataStore.get(other)
			if otherData and otherData.duo.optIn then
				table.insert(results, {
					name = other.Name,
					interests = otherData.duo.interests,
					score = overlapScore(myInterests, otherData.duo.interests),
				})
			end
		end
	end

	table.sort(results, function(a, b)
		return a.score > b.score
	end)

	return results
end

local function onSendDuoInvite(player: Player, targetName: any)
	if type(targetName) ~= "string" then
		return
	end
	local target = Players:FindFirstChild(targetName) :: Player?
	if not target or target == player then
		return
	end
	local targetData = PlayerDataStore.get(target)
	if not targetData or not targetData.duo.optIn then
		systemFeedbackEvent:FireClient(player, "Bu oyuncu şu an Duo bulmaya kapalı.")
		return
	end
	duoInviteReceivedEvent:FireClient(target, { fromName = player.Name })
end

local function onRespondDuoInvite(player: Player, payload: any)
	if type(payload) ~= "table" or type(payload.fromName) ~= "string" then
		return
	end
	local requester = Players:FindFirstChild(payload.fromName) :: Player?
	if not requester then
		return
	end
	local accepted = payload.accepted == true

	if accepted then
		systemFeedbackEvent:FireClient(requester, ("%s Duo davetini kabul etti! Artık birlikte oynayabilirsiniz."):format(player.Name))
		systemFeedbackEvent:FireClient(player, ("%s ile Duo oldun! Artık birlikte oynayabilirsiniz."):format(requester.Name))
	else
		systemFeedbackEvent:FireClient(requester, ("%s Duo davetini reddetti."):format(player.Name))
	end
end

function DuoSystem.init()
	setDuoProfileFunction.OnServerInvoke = onSetDuoProfile
	listDuoPlayersFunction.OnServerInvoke = onListDuoPlayers
	sendDuoInviteEvent.OnServerEvent:Connect(onSendDuoInvite)
	respondDuoInviteEvent.OnServerEvent:Connect(onRespondDuoInvite)
end

return DuoSystem
