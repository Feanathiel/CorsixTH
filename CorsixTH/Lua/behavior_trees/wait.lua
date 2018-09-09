
corsixth.require("behavior_trees/leaf")

local ALeafBehaviorNode = _G["ALeafBehaviorNode"]

---@type WaitBehaviorNode
class "WaitBehaviorNode" (ALeafBehaviorNode)

local WaitBehaviorNode = _G["WaitBehaviorNode"]

function WaitBehaviorNode:WaitBehaviorNode(humanoid, wait_tag)
  self:ALeafBehaviorNode()
  self.humanoid = humanoid
  self.current = 1
  self.wait_tag = wait_tag
end

-- override
function WaitBehaviorNode:Visit(memory)
  if not self:IsRunning() then
    self.current = 1
  end

  self.current = self.current + 1
  local length = memory:get(self.wait_tag)

  if length == nil then
    print("what")
  end

  if self.current <= length then
    self:Run()
    return
  else
    self:Succeed()
    return
  end
end
