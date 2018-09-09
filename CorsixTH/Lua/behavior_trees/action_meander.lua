
corsixth.require("behavior_trees/action_idle")
corsixth.require("behavior_trees/action_walk")
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

class "ActionFindMeanderLocation" (ALeafBehaviorNode)

---@type ActionFindMeanderLocation
local ActionFindMeanderLocation = _G["ActionFindMeanderLocation"]

function ActionFindMeanderLocation:ActionFindMeanderLocation(humanoid)
  self:ALeafBehaviorNode()
  self.humanoid = humanoid
end

function ActionFindMeanderLocation:Visit(memory)
  local humanoid = self.humanoid

  local distance = math.random(1, 24)

  local x, y = humanoid.world.pathfinder:findIdleTile(
      humanoid.tile_x,
      humanoid.tile_y,
      distance)

  memory:set("path_target", {x=x, y=y})
  self:Succeed()
end

class "SetIdleTime" (ALeafBehaviorNode)

local SetIdleTime = _G["SetIdleTime"]

function SetIdleTime:SetIdleTime()
  self:ALeafBehaviorNode()
end

function SetIdleTime:Visit(memory)
  local idle_time = math.random(5 ,30)
  memory:set("tag_idle_time", idle_time)
  self:Succeed()
end

class "ActionMeander" (ADecoratorBehaviorNode)

---@type ActionMeander
local ActionMeander = _G["ActionMeander"]

function ActionMeander:ActionMeander(humanoid)
  self:ADecoratorBehaviorNode(
    RandomSelectorBehaviorNode({
      SequenceBehaviorNode({
        ActionFindMeanderLocation(humanoid),
        ActionWalkToPoint(humanoid)
      }),
      SequenceBehaviorNode({
        SetIdleTime(),
        ActionIdle(humanoid, "tag_idle_time")
      })
    })
  )
end
