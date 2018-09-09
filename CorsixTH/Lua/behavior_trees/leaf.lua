
corsixth.require("behavior_trees/node")

local ABehaviorNode = _G["ABehaviorNode"]

---@type ALeafBehaviorNode
class "ALeafBehaviorNode" (ABehaviorNode)

local ALeafBehaviorNode = _G["ALeafBehaviorNode"]

function ALeafBehaviorNode:ALeafBehaviorNode()
  self:ABehaviorNode()
end
