
corsixth.require("behavior_trees/composite")

local ACompositeBehaviorNode = _G["ACompositeBehaviorNode"]

---@type RandomSelectorBehaviorNode
class "RandomSelectorBehaviorNode" (ACompositeBehaviorNode)

local RandomSelectorBehaviorNode = _G["RandomSelectorBehaviorNode"]

function RandomSelectorBehaviorNode:RandomSelectorBehaviorNode(children)
  self:ACompositeBehaviorNode(children)
  self.index = nil
end

-- override
function RandomSelectorBehaviorNode:Visit(memory)
  if not self:IsRunning() then
    self.index = math.random(1, self:child_count())
  end

  local child = self.children[self.index]
  child:Visit(memory)

  if child:IsRunning() then
    self:Run()
    return
  elseif child:IsSucceeded() then
    self:Succeed()
    return
  else
    self:Fail()
    return
  end
end

-- override
function RandomSelectorBehaviorNode:Update()
  if not self:IsReady() then
    self:Ready()
  else
    for index, child in ipairs(self.children) do
      child:Update()
    end
  end

  self.index = 1
end