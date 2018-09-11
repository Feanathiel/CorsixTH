
corsixth.require("behavior_trees/behavior_variable")
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
local BehaviorVariable = _G["BehaviorVariable"]

class "ActionFindPath" (ALeafBehaviorNode)

---@type ActionFindPath
local ActionFindPath = _G["ActionFindPath"]

function ActionFindPath:ActionFindPath(humanoid, path_var, path_index_var, path_target_var)
  self:ALeafBehaviorNode()
  self.humanoid = humanoid
  self.path_var = path_var
  self.path_index_var = path_index_var
  self.path_target_var = path_target_var
end

function ActionFindPath:Visit(memory)
  local path_target = self.path_target_var:get()
  local x = path_target.x
  local y = path_target.y

  local path_x, path_y = self.humanoid.world:getPath(self.humanoid.tile_x, self.humanoid.tile_y, x, y)

  if not path_x or #path_x == 1 then
    -- cant find route
    self:Fail()
    return
  end

  self.path_var:set({ path_x = path_x, path_y = path_y })
  self.path_index_var:set(1)
  self:Succeed()
end

class "ConditionPathDestinationReachedNode" (ALeafBehaviorNode)

---@type ConditionPathDestinationReachedNode
local ConditionPathDestinationReachedNode = _G["ConditionPathDestinationReachedNode"]

function ConditionPathDestinationReachedNode:ConditionPathDestinationReachedNode(path_var, path_index_var)
  self:ALeafBehaviorNode()
  self.path_var = path_var
  self.path_index_var = path_index_var
end

function ConditionPathDestinationReachedNode:Visit(memory)
  local path = self.path_var:get()
  local path_index = self.path_index_var:get()
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


function ConditionIsFacingDoor:ConditionIsFacingDoor(humanoid, path_var, path_index_var, child)
  self:ADecoratorBehaviorNode(child)
  self.humanoid = humanoid
  self.path_var = path_var
  self.path_index_var = path_index_var
end

function ConditionIsFacingDoor:Visit(memory)
  local humanoid = self.humanoid
  local map = humanoid.world.map.th

  local is_facing_door = false

  local path = self.path_var:get()
  local path_index = self.path_index_var:get()
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

function ActionWalkOneTile:ActionWalkOneTile(humanoid, path_var, path_index_var, walk_duration_var)
  self:ALeafBehaviorNode()
  self.humanoid = humanoid
  self.path_var = path_var
  self.path_index_var = path_index_var
  self.walk_duration_var = walk_duration_var
end

function ActionWalkOneTile:Visit(memory)
  local humanoid = self.humanoid
  local anims = humanoid.walk_anims

  local path = self.path_var:get()
  local path_index = self.path_index_var:get()
  local path_x = path.path_x
  local path_y = path.path_y
  local x1, y1 = path_x[path_index  ], path_y[path_index  ]
  local x2, y2 = path_x[path_index+1], path_y[path_index+1]

  local factor
  local quantity
  if humanoid.speed and humanoid.speed == "fast" then
    factor = 2
    quantity = 4
  else
    factor = 1
    quantity = 8
  end

  self.walk_duration_var:set(quantity)

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

function ActionPathNodeReached:ActionPathNodeReached(path_index_var)
  self:ALeafBehaviorNode()
  self.path_index_var = path_index_var
end

function ActionPathNodeReached:Visit(memory)
  local path_index = self.path_index_var:get()

  path_index = path_index + 1
  self.path_index_var:set(path_index)

  self:Succeed()
end

class "StopMovingNode" (ALeafBehaviorNode)

---@type StopMovingNode
local StopMovingNode = _G["StopMovingNode"]

function StopMovingNode:StopMovingNode(humanoid, path_var, path_index_var)
  self:ALeafBehaviorNode()
  self.humanoid = humanoid
  self.path_var = path_var
  self.path_index_var = path_index_var
end

function StopMovingNode:Visit(memory)
  local path = self.path_var:get()
  local path_index = self.path_index_var:get()
  local x1, y1 = path.path_x[path_index], path.path_y[path_index]

  self.humanoid:setTilePositionSpeed(x1, y1)

  self:Succeed()
end

class "ActionWalkToPoint" (ADecoratorBehaviorNode)

---@type ActionWalkToPoint
local ActionWalkToPoint = _G["ActionWalkToPoint"]

function ActionWalkToPoint:ActionWalkToPoint(humanoid, path_target_var)
  local path_var = BehaviorVariable("path")
  local path_index_var = BehaviorVariable("path_index")
  local walk_duration_var = BehaviorVariable("walk_duration", 1)

  self:ADecoratorBehaviorNode(
    SequenceBehaviorNode({
      ActionFindPath(humanoid, path_var, path_index_var, path_target_var),
      LoopConditionBehaviorNode(
        SequenceBehaviorNode({
          NotBehaviorNode(
              ConditionPathDestinationReachedNode(path_var, path_index_var)
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
              ConditionIsFacingDoor(humanoid, path_var, path_index_var, nil),
              ActionUseDoor()
            }),
            ]]
            SequenceBehaviorNode({
              ActionWalkOneTile(humanoid, path_var, path_index_var, walk_duration_var), -- seq: set anim, set speed/direction, set wait
              WaitBehaviorNode(humanoid, walk_duration_var)
            })
          }),
          ActionPathNodeReached(path_index_var)
        })
      ),
      StopMovingNode(humanoid, path_var, path_index_var)
    })
  )

end

