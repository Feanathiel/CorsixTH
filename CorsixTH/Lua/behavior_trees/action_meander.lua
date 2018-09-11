
corsixth.require("behavior_trees/action_idle")
corsixth.require("behavior_trees/action_walk")
corsixth.require("behavior_trees/behavior_variable")
corsixth.require("behavior_trees/decorator")
corsixth.require("behavior_trees/leaf")
corsixth.require("behavior_trees/sequence")
corsixth.require("behavior_trees/random_selector")

local ADecoratorBehaviorNode = _G["ADecoratorBehaviorNode"]
local SequenceBehaviorNode = _G["SequenceBehaviorNode"]
local RandomSelectorBehaviorNode = _G["RandomSelectorBehaviorNode"]
local ALeafBehaviorNode = _G["ALeafBehaviorNode"]
local ActionWalkToPoint = _G["ActionWalkToPoint"]
local ActionIdle = _G["ActionIdle"]
local BehaviorVariable = _G["BehaviorVariable"]

class "ActionFindMeanderLocation" (ALeafBehaviorNode)

---@type ActionFindMeanderLocation
local ActionFindMeanderLocation = _G["ActionFindMeanderLocation"]

function ActionFindMeanderLocation:ActionFindMeanderLocation(humanoid, meander_target_var)
  self:ALeafBehaviorNode()
  self.humanoid = humanoid
  self.meander_target_var = meander_target_var
end

function ActionFindMeanderLocation:Visit(memory)
  local humanoid = self.humanoid

  local distance = math.random(1, 24)

  local x, y = humanoid.world.pathfinder:findIdleTile(
      humanoid.tile_x,
      humanoid.tile_y,
      distance)

  self.meander_target_var:set({x=x, y=y})
  self:Succeed()
end

class "SetIdleTime" (ALeafBehaviorNode)

local SetIdleTime = _G["SetIdleTime"]

function SetIdleTime:SetIdleTime(idle_duration_var)
  self:ALeafBehaviorNode()
  self.idle_duration_var = idle_duration_var
end

function SetIdleTime:Visit(memory)
  local idle_time = math.random(5 ,30)
  self.idle_duration_var:set(idle_time)
  self:Succeed()
end

class "ActionMeander" (ADecoratorBehaviorNode)

---@type ActionMeander
local ActionMeander = _G["ActionMeander"]

function ActionMeander:ActionMeander(humanoid)
  local meander_target_var = BehaviorVariable("meander_target")
  local idle_duration_var = BehaviorVariable("idle_duration")

  self:ADecoratorBehaviorNode(
    RandomSelectorBehaviorNode({
      SequenceBehaviorNode({
        ActionFindMeanderLocation(humanoid, meander_target_var),
        ActionWalkToPoint(humanoid, meander_target_var)
      }),
      SequenceBehaviorNode({
        SetIdleTime(idle_duration_var),
        ActionIdle(humanoid, idle_duration_var)
      })
    })
  )
end
