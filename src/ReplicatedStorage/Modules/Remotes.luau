--!strict
-- Lazily creates/fetches RemoteEvents and RemoteFunctions under ReplicatedStorage.Remotes,
-- so client and server can reference the same instances by name without hand-wiring them in Studio.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if not remotesFolder then
	remotesFolder = Instance.new("Folder")
	remotesFolder.Name = "Remotes"
	remotesFolder.Parent = ReplicatedStorage
end

local Remotes = {}

function Remotes.getEvent(name: string): RemoteEvent
	local existing = remotesFolder:FindFirstChild(name)
	if existing then
		return existing :: RemoteEvent
	end
	local event = Instance.new("RemoteEvent")
	event.Name = name
	event.Parent = remotesFolder
	return event
end

function Remotes.getFunction(name: string): RemoteFunction
	local existing = remotesFolder:FindFirstChild(name)
	if existing then
		return existing :: RemoteFunction
	end
	local fn = Instance.new("RemoteFunction")
	fn.Name = name
	fn.Parent = remotesFolder
	return fn
end

return Remotes
