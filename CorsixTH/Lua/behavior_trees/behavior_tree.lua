
-- Enum
local behavior_state = {
  success = "behavior_state_success",
  failed = "behavior_state_failed",
  running = "behavior_state_running",
  ready = "behavior_state_ready"
}

---@type ABehaviorNode
class "ABehaviorNode"

local ABehaviorNode = _G["ABehaviorNode"]

function ABehaviorNode:ABehaviorNode()
  self:Ready()
end

-- virtual
function ABehaviorNode:Visit(memory)
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

---@type RandomSelectorBehaviorNode
class "RandomSelectorBehaviorNode" (ACompositeBehaviorNode)

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

---@type SequenceBehaviorNode
class "SequenceBehaviorNode" (ACompositeBehaviorNode)

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

---@type WaitBehaviorNode
class "WaitBehaviorNode" (ALeafBehaviorNode)

function WaitBehaviorNode:WaitBehaviorNode(humanoid, length)
  self:ALeafBehaviorNode()
  self.humanoid = humanoid
  self.current = 1
  self.length = length
end

-- override
function WaitBehaviorNode:Visit(memory)
  if not self:IsRunning() then
    self.current = 1
  end

  self.current = self.current + 1

  if self.current <= self.length then
    self:Run()
    return
  else
    self:Succeed()
    return
  end
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
function StartAnimationBehaviorNode:Visit(memory)
  print("starting animation" .. self.animation)
  self.humanoid:setAnimation(self.animation, self.flags)
  self:Succeed()
end

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

class "BehaviorMemory"

---@type BehaviorMemory
local BehaviorMemory = _G["BehaviorMemory"]

function BehaviorMemory:BehaviorMemory()
  self.data = {}
end

function BehaviorMemory:get(key)
  return self.data[key]
end

function BehaviorMemory:set(key, value)
  self.data[key] = value
end

function BehaviorMemory:has(key)
  return self.data[key] ~= nil
end

function BehaviorMemory:remove(key)
  self.data[key] = nil
end

class "BehaviorTree"

---@type BehaviorTree
local BehaviorTree = _G["BehaviorTree"]

function BehaviorTree:BehaviorTree(root)
  self.root = root
  self.memory = BehaviorMemory()
end

function BehaviorTree:Tick()
  self.root:Visit(self.memory)
  self.root:Update()
end

-- ---------------------

