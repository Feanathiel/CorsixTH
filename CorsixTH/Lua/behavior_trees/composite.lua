
corsixth.require("behavior_trees/node")

local ABehaviorNode = _G["ABehaviorNode"]

---@type ACompositeBehaviorNode
class "ACompositeBehaviorNode" (ABehaviorNode)

local ACompositeBehaviorNode = _G["ACompositeBehaviorNode"]

function ACompositeBehaviorNode:ACompositeBehaviorNode(children)
  self:ABehaviorNode()
  self.children = children
end

function ACompositeBehaviorNode:child_count()
  return #self.children
end
