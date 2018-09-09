
corsixth.require("behavior_trees/node")

local ABehaviorNode = _G["ABehaviorNode"]

---@type ADecoratorBehaviorNode
class "ADecoratorBehaviorNode" (ABehaviorNode)

local ADecoratorBehaviorNode = _G["ADecoratorBehaviorNode"]

function ADecoratorBehaviorNode:ADecoratorBehaviorNode(child)
  self:ABehaviorNode()
  self.child = child
end

function ADecoratorBehaviorNode:Visit(memory)
  self.child:Visit(memory)
  self:SetState(self.child.state)
end

function ADecoratorBehaviorNode:Update()
  if not self:IsReady() then
    self:Ready()
  else
    self.child:Update()
  end
end
