--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Modules.Remotes)

local DuoClient = {}

local setDuoProfileFunction = Remotes.getFunction("SetDuoProfile")
local listDuoPlayersFunction = Remotes.getFunction("ListDuoPlayers")
local sendDuoInviteEvent = Remotes.getEvent("SendDuoInvite")
local respondDuoInviteEvent = Remotes.getEvent("RespondDuoInvite")
local duoInviteReceivedEvent = Remotes.getEvent("DuoInviteReceived")

function DuoClient.setProfile(optIn: boolean, interests: { string })
	local success, result = pcall(function()
		return setDuoProfileFunction:InvokeServer({ optIn = optIn, interests = interests })
	end)
	if success then
		return result
	end
	return { success = false }
end

function DuoClient.listPlayers(): { any }
	local success, result = pcall(function()
		return listDuoPlayersFunction:InvokeServer()
	end)
	if success and result then
		return result
	end
	return {}
end

function DuoClient.sendInvite(targetName: string)
	sendDuoInviteEvent:FireServer(targetName)
end

function DuoClient.respondInvite(fromName: string, accepted: boolean)
	respondDuoInviteEvent:FireServer({ fromName = fromName, accepted = accepted })
end

function DuoClient.onInviteReceived(callback: (payload: any) -> ()): RBXScriptConnection
	return duoInviteReceivedEvent.OnClientEvent:Connect(callback)
end

return DuoClient
