--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Modules.Remotes)

local GroupClient = {}

local createGroupEvent = Remotes.getEvent("CreateGroup")
local joinGroupEvent = Remotes.getEvent("JoinGroup")
local leaveGroupEvent = Remotes.getEvent("LeaveGroup")
local requestColorChangeEvent = Remotes.getEvent("RequestGroupColorChange")
local groupStateEvent = Remotes.getEvent("GroupStateChanged")

function GroupClient.create()
	createGroupEvent:FireServer()
end

function GroupClient.join(code: string)
	joinGroupEvent:FireServer(code)
end

function GroupClient.leave()
	leaveGroupEvent:FireServer()
end

function GroupClient.requestColorChange(color: Color3)
	requestColorChangeEvent:FireServer(color)
end

function GroupClient.onStateChanged(callback: (state: any) -> ()): RBXScriptConnection
	return groupStateEvent.OnClientEvent:Connect(callback)
end

return GroupClient
