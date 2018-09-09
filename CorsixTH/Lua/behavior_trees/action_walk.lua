
corsixth.require("behavior_trees/decorator")
corsixth.require("behavior_trees/leaf")
corsixth.require("behavior_trees/loop_condition")
corsixth.require("behavior_trees/not")
corsixth.require("behavior_trees/selector")
corsixth.require("behavior_trees/sequence")

local ALeafBehaviorNode = _G["ALeafBehaviorNode"]
local ADecoratorBehaviorNode = _G["ADecoratorBehaviorNode"]
local LoopConditionBehaviorNode = _G["LoopConditionBehaviorNode"]
local SequenceBehaviorNode = _G["SequenceBehaviorNode"]
local WaitBehaviorNode = _G["WaitBehaviorNode"]
local NotBehaviorNode = _G["NotBehaviorNode"]
local SelectorBehaviorNode = _G["SelectorBehaviorNode"]

class "ActionFindPath" (ALeafBehaviorNode)

---@type ActionFindPath
local ActionFindPath = _G["ActionFindPath"]

function ActionFindPath:ActionFindPath(humanoid)
  self:ALeafBehaviorNode()
  self.humanoid = humanoid
end

function ActionFindPath:Visit(memory)
  local path_target = memory:get("path_target")
  local x = path_target.x
  local y = path_target.y

  local path_x, path_y = self.humanoid.world:getPath(self.humanoid.tile_x, self.humanoid.tile_y, x, y)

  if not path_x or #path_x == 1 then
    -- cant find route
    self:Fail()
    return
  end

  memory:set("path", { path_x = path_x, path_y = path_y })
  memory:set("path_index", 1)
  self:Succeed()
end

class "ConditionPathDestinationReachedNode" (ALeafBehaviorNode)

---@type ConditionPathDestinationReachedNode
local ConditionPathDestinationReachedNode = _G["ConditionPathDestinationReachedNode"]

function ConditionPathDestinationReachedNode:ConditionPathDestinationReachedNode()
  self:ALeafBehaviorNode()
end

function ConditionPathDestinationReachedNode:Visit(memory)
  local path = memory:get("path")
  local path_index = memory:get("path_index")
  local path_x = path.path_x

  local next_pathnode_missing = path_x[path_index+1] == nil

  if next_pathnode_missing then
    self:Succeed()
    return
  else
    self:Fail()
    return
  end
end

class "ConditionIsFacingDoor" (ADecoratorBehaviorNode)

---@type ConditionIsFacingDoor
local ConditionIsFacingDoor = _G["ConditionIsFacingDoor"]


function ConditionIsFacingDoor:ConditionIsFacingDoor(humanoid, child)
  self:ADecoratorBehaviorNode(child)
  self.humanoid = humanoid
end

function ConditionIsFacingDoor:Visit(memory)
  local humanoid = self.humanoid
  local map = humanoid.world.map.th

  local is_facing_door = false

  local path = memory:get("path")
  local path_index = memory:get("path_index")
  local path_x = path.path_x
  local path_y = path.path_y
  local x1, y1 = path_x[path_index  ], path_y[path_index  ]
  local x2, y2 = path_x[path_index+1], path_y[path_index+1]

  if x1 ~= x2 then
    if x1 < x2 then
      if map and map:getCellFlags(x2, y2).doorWest then
        is_facing_door = true
      end
    else
      if map and map:getCellFlags(x1, y1).doorWest then
        is_facing_door = true
      else
      end
    end
  else
    if y1 < y2 then
      if map and map:getCellFlags(x2, y2).doorNorth then
        is_facing_door = true
      end
    else
      if map and map:getCellFlags(x1, y1).doorNorth then
        is_facing_door = true
      end
    end
  end

  if is_facing_door then
    self.child:Visit(memory)
    self:SetState(self.child:GetState())
  else
    self:Fail()
  end
end

class "ActionWalkOneTile" (ALeafBehaviorNode)

---@type ActionWalkOneTile
local ActionWalkOneTile = _G["ActionWalkOneTile"]

function ActionWalkOneTile:ActionWalkOneTile(humanoid)
  self:ALeafBehaviorNode()
  self.humanoid = humanoid
end

function ActionWalkOneTile:Visit(memory)
  local humanoid = self.humanoid
  local anims = humanoid.walk_anims

  local path = memory:get("path")
  local path_index = memory:get("path_index")
  local path_x = path.path_x
  local path_y = path.path_y
  local x1, y1 = path_x[path_index  ], path_y[path_index  ]
  local x2, y2 = path_x[path_index+1], path_y[path_index+1]

  local factor
  if humanoid.speed and humanoid.speed == "fast" then
    factor = 2
  else
    factor = 1
  end

  local world = humanoid.world
  local notify_object = world:getObjectToNotifyOfOccupants(x2, y2)
  if notify_object then
    notify_object:onOccupantChange(1)
  end
  notify_object = world:getObjectToNotifyOfOccupants(x1, y1)
  if notify_object then
    notify_object:onOccupantChange(-1)
  end

  local flag_flip_h = 1

  if x1 ~= x2 then
    if x1 < x2 then
      humanoid.last_move_direction = "east"
      humanoid:setAnimation(anims.walk_east)
      humanoid:setTilePositionSpeed(x2, y2, -32, -16, 4*factor, 2*factor)
      self:Succeed()
      return
    else
      humanoid.last_move_direction = "west"
      humanoid:setAnimation(anims.walk_north, flag_flip_h)
      humanoid:setTilePositionSpeed(x1, y1, 0, 0, -4*factor, -2*factor)
      self:Succeed()
      return
    end
  else
    if y1 < y2 then
      humanoid.last_move_direction = "south"
      humanoid:setAnimation(anims.walk_east, flag_flip_h)
      humanoid:setTilePositionSpeed(x2, y2, 32, -16, -4*factor, 2*factor)
      self:Succeed()
      return
    else
      humanoid.last_move_direction = "north"
      humanoid:setAnimation(anims.walk_north)
      humanoid:setTilePositionSpeed(x1, y1, 0, 0, 4*factor, -2*factor)
      self:Succeed()
      return
    end
  end

  self:Fail()
end

class "ActionPathNodeReached" (ALeafBehaviorNode)

---@type ActionPathNodeReached
local ActionPathNodeReached = _G["ActionPathNodeReached"]

function ActionPathNodeReached:ActionPathNodeReached()
  self:ALeafBehaviorNode()
end

function ActionPathNodeReached:Visit(memory)
  local path_index = memory:get("path_index")

  path_index = path_index + 1
  memory:set("path_index", path_index)

  self:Succeed()
end

class "StopMovingNode" (ALeafBehaviorNode)

---@type StopMovingNode
local StopMovingNode = _G["StopMovingNode"]

function StopMovingNode:StopMovingNode(humanoid)
  self:ALeafBehaviorNode()
  self.humanoid = humanoid
end

function StopMovingNode:Visit(memory)
  local path = memory:get("path")
  local path_index = memory:get("path_index")
  local x1, y1 = path.path_x[path_index], path.path_y[path_index]

  self.humanoid:setTilePositionSpeed(x1, y1)

  memory:remove("path")
  memory:remove("path_index")
  self:Succeed()
end

class "ActionWalkToPoint" (ADecoratorBehaviorNode)

---@type ActionWalkToPoint
local ActionWalkToPoint = _G["ActionWalkToPoint"]

function ActionWalkToPoint:ActionWalkToPoint(humanoid)
  -- hardcoded for the time being
  local quantity = 8
  if humanoid.speed and humanoid.speed == "fast" then
    quantity = 4
  end

  self:ADecoratorBehaviorNode(
    SequenceBehaviorNode({
      ActionFindPath(humanoid),
      LoopConditionBehaviorNode(
        SequenceBehaviorNode({
          NotBehaviorNode(
              ConditionPathDestinationReachedNode()
          )
          --[[,
          NotBehaviorNode(
              ConditionPathBlockedNode()
          )
          ]]
        }),
        SequenceBehaviorNode({
          SelectorBehaviorNode({
            --[[
            SequenceBehaviorNode({
              ConditionIsFacingDoor(),
              ActionUseDoor()
            }),
            ]]
            SequenceBehaviorNode({
              ActionWalkOneTile(humanoid), -- seq: set anim, set speed/direction, set wait
              WaitBehaviorNode(humanoid, quantity)
            })
          }),
          ActionPathNodeReached()
        })
      ),
      StopMovingNode(humanoid)
    })
  )

end

