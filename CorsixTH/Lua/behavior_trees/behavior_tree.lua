
-- Enum
local behavior_state = {
  success = "behavior_state_success",
  failed = "behavior_state_failed",
  running = "behavior_state_running",
  ready = "behavior_state_ready"
}

---@type ABehaviorNode
class "ABehaviorNode" (Object)

local ABehaviorNode = _G["ABehaviorNode"]

function ABehaviorNode:ABehaviorNode()
  self:Ready()
end

-- virtual
function ABehaviorNode:Visit()
  self:Succeed()
end

-- virtual
function ABehaviorNode:Update()
  if not self:IsReady() then
    self:Ready()
  end
end

function ABehaviorNode:SetState(state)
  self.state = state
end

function ABehaviorNode:IsSucceeded()
  return self.state == behavior_state.success
end

function ABehaviorNode:Succeed()
  self.state = behavior_state.success
end

function ABehaviorNode:IsFailed()
  return self.state == behavior_state.failed
end

function ABehaviorNode:Fail()
  self.state = behavior_state.failed
end

function ABehaviorNode:IsRunning()
  return self.state == behavior_state.running
end

function ABehaviorNode:Run()
  self.state = behavior_state.running
end

function ABehaviorNode:IsReady()
  return self.state == behavior_state.ready
end

function ABehaviorNode:Ready()
  self.state = behavior_state.ready
end

---@type ACompositeBehaviorNode
class "ACompositeBehaviorNode" (ABehaviorNode)

function ACompositeBehaviorNode:ACompositeBehaviorNode(children)
  self:ABehaviorNode()
  self.children = children
end

function ACompositeBehaviorNode:child_count()
  return #self.children
end

---@type ADecoratorBehaviorNode
class "ADecoratorBehaviorNode" (ABehaviorNode)

function ADecoratorBehaviorNode:ADecoratorBehaviorNode(child)
  self:ABehaviorNode()
  self.child = child
end

---@type ALeafBehaviorNode
class "ALeafBehaviorNode" (ABehaviorNode)

function ALeafBehaviorNode:ALeafBehaviorNode()
  self:ABehaviorNode()
end

---@type SelectorBehaviorNode
class "SelectorBehaviorNode" (ACompositeBehaviorNode)

function SelectorBehaviorNode:SelectorBehaviorNode(children)
  self:ACompositeBehaviorNode(children)
  self.index = 1
end

-- override
function SelectorBehaviorNode:Visit()
  if not self:IsRunning() then
    self.index = 1
  end

  while self.index <= #self.children do
    local child = self.children[index]
    child:Visit()

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

---@type SequenceBehaviorNode
class "SequenceBehaviorNode" (ACompositeBehaviorNode)

function SequenceBehaviorNode:SequenceBehaviorNode(children)
  self:ACompositeBehaviorNode(children)
  self.index = 1
end

-- override
function SequenceBehaviorNode:Visit()
  if not self:IsRunning() then
    self.index = 1
  end

  while self.index <= self:child_count() do
    local child = self.children[self.index]
    child:Visit()

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

---@type WaitBehaviorNode
class "WaitBehaviorNode" (ALeafBehaviorNode)

function WaitBehaviorNode:WaitBehaviorNode(humanoid, length)
  self:ALeafBehaviorNode()
  self.humanoid = humanoid
  self.done = false
  self.length = length
end

-- override
function WaitBehaviorNode:Visit()
  if self:IsReady() then
    self.humanoid:setTimer(self.length, function() self.done = true end)
  elseif self:IsRunning() then
    if self.done then
      self:Succeed()
      return
    end
  end

  self:Run()
end

-- override
function WaitBehaviorNode:Update()
  if not self:IsReady() and not self:IsRunning() then
    self.done = false
  end

  ALeafBehaviorNode.Update(self) -- base call
end

---@type StartAnimationBehaviorNode
class "StartAnimationBehaviorNode" (ALeafBehaviorNode)

function StartAnimationBehaviorNode:StartAnimationBehaviorNode(humanoid, animation, flags)
  self:ALeafBehaviorNode()
  self.humanoid = humanoid
  self.animation = animation
  self.flags = flags
end

-- override
function StartAnimationBehaviorNode:Visit()
  print("starting animation" .. self.animation)
  self.humanoid:setAnimation(self.animation, self.flags)
  self:Succeed()
end

class "BehaviorTree" (Object)

---@type BehaviorTree
local BehaviorTree = _G["BehaviorTree"]

function BehaviorTree:BehaviorTree(root)
  self.root = root
end

function BehaviorTree:Tick()
  self.root:Visit()
  self.root:Update()
end

-- ---------------------

