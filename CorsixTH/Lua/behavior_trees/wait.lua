
corsixth.require("behavior_trees/leaf")

local ALeafBehaviorNode = _G["ALeafBehaviorNode"]

---@type WaitBehaviorNode
class "WaitBehaviorNode" (ALeafBehaviorNode)

local WaitBehaviorNode = _G["WaitBehaviorNode"]

function WaitBehaviorNode:WaitBehaviorNode(humanoid, length)
  self:ALeafBehaviorNode()
  self.humanoid = humanoid
  self.current = 1
  self.length = length
end

-- override
function WaitBehaviorNode:Visit(memory)
  if not self:IsRunning() then
    self.current = 1
  end

  self.current = self.current + 1

  if self.current <= self.length then
    self:Run()
    return
  else
    self:Succeed()
    return
  end
end
