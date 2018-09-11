
corsixth.require("behavior_trees/action_walk")
corsixth.require("behavior_trees/behavior_variable")
corsixth.require("behavior_trees/decorator")
corsixth.require("behavior_trees/leaf")
corsixth.require("behavior_trees/sequence")

local ADecoratorBehaviorNode = _G["ADecoratorBehaviorNode"]
local SequenceBehaviorNode = _G["SequenceBehaviorNode"]
local ALeafBehaviorNode = _G["ALeafBehaviorNode"]
local ActionWalkToPoint = _G["ActionWalkToPoint"]
local BehaviorVariable = _G["BehaviorVariable"]

class "ActionFindRoomExitLocation" (ALeafBehaviorNode)

---@type ActionFindRoomExitLocation
local ActionFindRoomExitLocation = _G["ActionFindRoomExitLocation"]

function ActionFindRoomExitLocation:ActionFindRoomExitLocation(humanoid, room_exit_target_var)
  self:ALeafBehaviorNode()
  self.humanoid = humanoid
  self.room_exit_target_var = room_exit_target_var
end

function ActionFindRoomExitLocation:Visit(memory)
  local room = self.humanoid:getRoom()

  if room then
    local x, y = room:getEntranceXY(false)

    self.room_exit_target_var:set({x=x, y=y})
    self:Succeed()
  else
    self:Fail()
  end
end

class "ActionLeaveRoom" (ADecoratorBehaviorNode)

---@type ActionLeaveRoom
local ActionLeaveRoom = _G["ActionLeaveRoom"]

function ActionLeaveRoom:ActionLeaveRoom(humanoid)
  local room_exit_target_var = BehaviorVariable("room_exit_target")

  self:ADecoratorBehaviorNode(
    SequenceBehaviorNode({
      ActionFindRoomExitLocation(humanoid, room_exit_target_var),
      ActionWalkToPoint(humanoid, room_exit_target_var)
    })
  )
end
