--!strict
-- Tracks which players are currently standing inside any part tagged with a given
-- CollectionService tag (e.g. "CharZone" for Public Map / Disco). If no parts carry that tag
-- yet, isPlayerInTag returns true for everyone — so features built on a zone are testable
-- before the actual map exists and gets tagged in Studio, and start being restricted the
-- moment someone tags the real zone parts.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local ZoneTracker = {}

-- tag -> player -> number of tagged parts currently touching that player
local counts: { [string]: { [Player]: number } } = {}
local trackedTags: { [string]: boolean } = {}

local function getPlayerFromPart(part: BasePart): Player?
	local character = part:FindFirstAncestorOfClass("Model")
	if not character then
		return nil
	end
	return Players:GetPlayerFromCharacter(character)
end

local function trackTag(tag: string)
	if trackedTags[tag] then
		return
	end
	trackedTags[tag] = true
	counts[tag] = {}

	local function hookPart(part: Instance)
		if not part:IsA("BasePart") then
			return
		end
		part.Touched:Connect(function(hit)
			local player = getPlayerFromPart(hit)
			if player then
				counts[tag][player] = (counts[tag][player] or 0) + 1
			end
		end)
		part.TouchEnded:Connect(function(hit)
			local player = getPlayerFromPart(hit)
			if player and counts[tag][player] then
				counts[tag][player] = math.max(0, counts[tag][player] - 1)
			end
		end)
	end

	for _, part in ipairs(CollectionService:GetTagged(tag)) do
		hookPart(part)
	end
	CollectionService:GetInstanceAddedSignal(tag):Connect(hookPart)

	Players.PlayerRemoving:Connect(function(player)
		counts[tag][player] = nil
	end)
end

function ZoneTracker.isPlayerInTag(player: Player, tag: string): boolean
	trackTag(tag)
	if next(CollectionService:GetTagged(tag)) == nil then
		return true
	end
	return (counts[tag][player] or 0) > 0
end

return ZoneTracker
