corsixth.require("behavior_trees/decorator")

local ADecoratorBehaviorNode = _G["ADecoratorBehaviorNode"]

class "LoopConditionBehaviorNode" (ADecoratorBehaviorNode)

---@type LoopConditionBehaviorNode
local LoopConditionBehaviorNode = _G["LoopConditionBehaviorNode"]

function LoopConditionBehaviorNode:LoopConditionBehaviorNode(condition, body)
  self:ADecoratorBehaviorNode(body)
  self.condition = condition
end

-- override
function LoopConditionBehaviorNode:Visit(memory)
  while true do
    self.condition:Visit(memory)

    if self.condition:IsFailed() then
      self:Succeed()
      return
    elseif self.condition:IsRunning() then
      self:Run()
      return
    end

    self.child:Visit(memory)

    if self.child:IsFailed() or self.child:IsRunning() then
      self:SetState(self.child.state)
      return
    end
  end
end

-- override
function LoopConditionBehaviorNode:Update()
  if not self:IsReady() then
    self:Ready()
  else
    self.condition:Update()
    self.body:Update()
  end
end