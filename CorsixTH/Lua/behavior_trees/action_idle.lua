
corsixth.require("behavior_trees/sequence")
corsixth.require("behavior_trees/start_animation")
corsixth.require("behavior_trees/wait")

local SequenceBehaviorNode = _G["SequenceBehaviorNode"]
local StartAnimationBehaviorNode = _G["StartAnimationBehaviorNode"]
local WaitBehaviorNode = _G["WaitBehaviorNode"]

class "ActionIdle" (SequenceBehaviorNode)

---@type ActionIdle
local ActionIdle = _G["ActionIdle"]

function ActionIdle:ActionIdle(humanoid, duration_var)
  local direction = humanoid.last_move_direction
  local anim = nil
  local flags = nil

  if direction == "north" then
    anim = humanoid.walk_anims.idle_north
    flags = 0
  elseif direction == "east" then
    anim = humanoid.walk_anims.idle_east
    flags = 0
  elseif direction == "south" then
    anim = humanoid.walk_anims.idle_east
    flags = 1
  elseif direction == "west" then
    anim = humanoid.walk_anims.idle_north
    flags = 0
  end

  self:SequenceBehaviorNode({
    StartAnimationBehaviorNode(humanoid, anim, flags),
    WaitBehaviorNode(humanoid, duration_var)
  })
end

