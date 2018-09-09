
corsixth.require("behavior_trees/decorator")

local ADecoratorBehaviorNode = _G["ADecoratorBehaviorNode"]

---@type NotBehaviorNode
class "NotBehaviorNode" (ADecoratorBehaviorNode)

function NotBehaviorNode:NotBehaviorNode(child)
  self:ADecoratorBehaviorNode(child)
end

function NotBehaviorNode:Visit(memory)
  self.child:Visit(memory)

  if self.child:IsSucceeded() then
    self:Fail()
  elseif self.child:IsFailed() then
    self:Succeed()
  else
    self:SetState(self.child:GetState())
  end
end
