
corsixth.require("behavior_trees/behavior_variable")
corsixth.require("behavior_trees/sequence")
corsixth.require("behavior_trees/start_animation")
corsixth.require("behavior_trees/wait")

local BehaviorVariable = _G["BehaviorVariable"]
local ALeafBehaviorNode = _G["ALeafBehaviorNode"]
local SequenceBehaviorNode = _G["SequenceBehaviorNode"]
local WaitBehaviorNode = _G["WaitBehaviorNode"]

class "DoorStart" (ALeafBehaviorNode)

---@type DoorStart
local DoorStart = _G["DoorStart"]

function DoorStart:DoorStart(humanoid, door_var, target_position_var, walk_duration_var)
  self:ALeafBehaviorNode()
  self.humanoid = humanoid
  self.door_var = door_var
  self.target_position_var = target_position_var
  self.walk_duration_var = walk_duration_var
end

-- override
function DoorStart:Visit(memory)
  local door_data = self.door_var:get()

  local humanoid = self.humanoid
  local door = door_data.door
  local direction = door_data.direction
  local pos_x, pos_y = door_data.pos_x, door_data.pos_y

  humanoid:setTilePositionSpeed(pos_x, pos_y)
  humanoid.user_of = door
  door:setUser(humanoid) -- (makes it invisible, etc.)

  local entering = humanoid.door_anims.entering
  local leaving = humanoid.door_anims.leaving

  local flag_list_bottom = 2048
  local flag_flip_h = 1

  local to_x, to_y
  local duration = 12

  if direction == "north" then
    humanoid:setAnimation(leaving, flag_list_bottom)
    to_x, to_y = pos_x, pos_y - 1
    duration = humanoid.world:getAnimLength(leaving)
  elseif direction == "west" then
    humanoid:setAnimation(leaving, flag_list_bottom + flag_flip_h)
    to_x, to_y = pos_x - 1, pos_y
    duration = humanoid.world:getAnimLength(leaving)
  elseif direction == "east" then
    humanoid:setAnimation(entering, flag_list_bottom)
    to_x, to_y = pos_x, pos_y
    duration = 10
  elseif direction == "south" then
    humanoid:setAnimation(entering, flag_list_bottom + flag_flip_h)
    to_x, to_y = pos_x, pos_y
    duration = 10
  end

  self.walk_duration_var:set(duration)
  self.target_position_var:set({x = to_x, y = to_y})

  self:Succeed()
end

class "SwitchRooms" (ALeafBehaviorNode)

---@type SwitchRooms
local SwitchRooms = _G["SwitchRooms"]

function SwitchRooms:SwitchRooms(humanoid, door_var, target_position_var)
  self:ALeafBehaviorNode()
  self.humanoid = humanoid
  self.door_var = door_var
  self.target_position_var = target_position_var
end

-- override
function SwitchRooms:Visit(memory)
  local door_data = self.door_var:get()
  local to_data = self.target_position_var:get()
  local humanoid = self.humanoid
  local pos_x, pos_y = door_data.pos_x, door_data.pos_y
  local to_x, to_y = to_data.x, to_data.y

  local srm = humanoid.world:getRoom(pos_x, pos_y)
  if srm then
    srm:onHumanoidLeave(humanoid)
  end

  local trm = humanoid.world:getRoom(to_x, to_y)
  if trm then
    trm:onHumanoidEnter(humanoid)
  end

  self:Succeed()
end

class "DoorEnd" (ALeafBehaviorNode)

---@type DoorEnd
local DoorEnd = _G["DoorEnd"]

function DoorEnd:DoorEnd(humanoid, door_var)
  self:ALeafBehaviorNode()
  self.humanoid = humanoid
  self.door_var = door_var
end

-- override
function DoorEnd:Visit(memory)
  local door_data = self.door_var:get()
  local humanoid = self.humanoid
  local door = door_data.door

  door:removeUser(humanoid)
  humanoid.user_of = nil

  self:Succeed()
end

class "ActionUseDoor" (SequenceBehaviorNode)

---@type ActionIdle
local ActionUseDoor = _G["ActionUseDoor"]

function ActionUseDoor:ActionUseDoor(humanoid, door_var)
  local target_position_var = BehaviorVariable("target_position")
  local walk_duration_var = BehaviorVariable("walk_duration")

  self:SequenceBehaviorNode({
    DoorStart(humanoid, door_var, target_position_var, walk_duration_var),
    WaitBehaviorNode(humanoid, walk_duration_var),
    SwitchRooms(humanoid, door_var, target_position_var),
    DoorEnd(humanoid, door_var)
  })
end

