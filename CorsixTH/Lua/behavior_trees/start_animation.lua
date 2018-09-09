
corsixth.require("behavior_trees/leaf")

local ALeafBehaviorNode = _G["ALeafBehaviorNode"]

---@type StartAnimationBehaviorNode
class "StartAnimationBehaviorNode" (ALeafBehaviorNode)

local StartAnimationBehaviorNode = _G["StartAnimationBehaviorNode"]

function StartAnimationBehaviorNode:StartAnimationBehaviorNode(humanoid, animation, flags)
  self:ALeafBehaviorNode()
  self.humanoid = humanoid
  self.animation = animation
  self.flags = flags
end

-- override
function StartAnimationBehaviorNode:Visit(memory)
  print("starting animation" .. self.animation)
  self.humanoid:setAnimation(self.animation, self.flags)
  self:Succeed()
end
