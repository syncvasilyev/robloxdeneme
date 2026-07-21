--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Modules.Remotes)

local PartyClient = {}

local createPartyEvent = Remotes.getEvent("CreateParty")
local joinPartyEvent = Remotes.getEvent("JoinParty")
local leavePartyEvent = Remotes.getEvent("LeaveParty")
local closePartyEvent = Remotes.getEvent("ClosePartyHost")
local setFriendsOnlyEvent = Remotes.getEvent("SetPartyFriendsOnly")
local grantDjEvent = Remotes.getEvent("GrantPartyDj")
local playTrackEvent = Remotes.getEvent("PlayPartyTrack")
local stopTrackEvent = Remotes.getEvent("StopPartyTrack")
local partyStateEvent = Remotes.getEvent("PartyStateChanged")

function PartyClient.create(maxSize: number?)
	createPartyEvent:FireServer({ maxSize = maxSize })
end

function PartyClient.join(code: string)
	joinPartyEvent:FireServer(code)
end

function PartyClient.leave()
	leavePartyEvent:FireServer()
end

function PartyClient.close()
	closePartyEvent:FireServer()
end

function PartyClient.setFriendsOnly(value: boolean)
	setFriendsOnlyEvent:FireServer(value)
end

function PartyClient.grantDj(targetName: string)
	grantDjEvent:FireServer(targetName)
end

function PartyClient.playTrack(trackId: string)
	playTrackEvent:FireServer(trackId)
end

function PartyClient.stopTrack()
	stopTrackEvent:FireServer()
end

function PartyClient.onStateChanged(callback: (state: any) -> ()): RBXScriptConnection
	return partyStateEvent.OnClientEvent:Connect(callback)
end

return PartyClient
