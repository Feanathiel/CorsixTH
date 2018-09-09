
corsixth.require("behavior_trees/decorator")

local ADecoratorBehaviorNode = _G["ADecoratorBehaviorNode"]

class "ConditionEmptyActionQueue" (ADecoratorBehaviorNode)

---@type ConditionEmptyActionQueue
local ConditionEmptyActionQueue = _G["ConditionEmptyActionQueue"]

function ConditionEmptyActionQueue:ConditionEmptyActionQueue(humanoid, child)
  self:ADecoratorBehaviorNode(child)
  self.humanoid = humanoid
end

-- override
function ConditionEmptyActionQueue:Visit(memory)
  local queue_count = (self.humanoid.action_queue and #self.humanoid.action_queue) or 0

  if queue_count == 0 then
    self.child:Visit(memory)
    self:SetState(self.child.state)
  else
    self:Fail()
  end
end
