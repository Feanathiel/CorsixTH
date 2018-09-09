
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
