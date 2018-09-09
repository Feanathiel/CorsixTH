
corsixth.require("behavior_trees/composite")

local ACompositeBehaviorNode = _G["ACompositeBehaviorNode"]

---@type SelectorBehaviorNode
class "SelectorBehaviorNode" (ACompositeBehaviorNode)

local SelectorBehaviorNode = _G["SelectorBehaviorNode"]

function SelectorBehaviorNode:SelectorBehaviorNode(children)
  self:ACompositeBehaviorNode(children)
  self.index = 1
end

-- override
function SelectorBehaviorNode:Visit(memory)
  if not self:IsRunning() then
    self.index = 1
  end

  while self.index <= #self.children do
    local child = self.children[self.index]
    child:Visit(memory)

    if child:IsRunning() then
      self:Run()
      return
    elseif child:IsSucceeded() then
      self:Succeed()
      return
    end

    self.index = self.index + 1
  end

  self:Fail()
end

-- override
function SelectorBehaviorNode:Update()
  if not self:IsReady() then
    self:Ready()
  else
    for index, child in ipairs(self.children) do
      child:Update()
    end
  end

  self.index = 1
end