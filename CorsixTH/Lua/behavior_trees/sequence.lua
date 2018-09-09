
corsixth.require("behavior_trees/composite")

local ACompositeBehaviorNode = _G["ACompositeBehaviorNode"]

---@type SequenceBehaviorNode
class "SequenceBehaviorNode" (ACompositeBehaviorNode)

local SequenceBehaviorNode = _G["SequenceBehaviorNode"]

function SequenceBehaviorNode:SequenceBehaviorNode(children)
  self:ACompositeBehaviorNode(children)
  self.index = nil
end

-- override
function SequenceBehaviorNode:Visit(memory)
  if not self:IsRunning() then
    self.index = 1
  end

  while self.index <= self:child_count() do
    local child = self.children[self.index]
    child:Visit(memory)

    if child:IsRunning() then
      self:Run()
      return
    elseif child:IsFailed() then
      self:Fail()
      return
    end

    self.index = self.index + 1
  end

  self:Succeed()
end

-- override
function SequenceBehaviorNode:Update()
  if not self:IsReady() then
    self:Ready()
  else
    for index, child in ipairs(self.children) do
      child:Update()
    end
  end

  self.index = 1
end
