
corsixth.require("behavior_trees/leaf")

local ALeafBehaviorNode = _G["ALeafBehaviorNode"]

---@type WaitBehaviorNode
class "WaitBehaviorNode" (ALeafBehaviorNode)

local WaitBehaviorNode = _G["WaitBehaviorNode"]

function WaitBehaviorNode:WaitBehaviorNode(humanoid, duration_var)
  self:ALeafBehaviorNode()
  self.humanoid = humanoid
  self.current = 1
  self.duration_var = duration_var
end

-- override
function WaitBehaviorNode:Visit(memory)
  if not self:IsRunning() then
    self.current = 1
  end

  self.current = self.current + 1
  local length = self.duration_var:get()

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
