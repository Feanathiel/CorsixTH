
corsixth.require("behavior_trees/behavior_memory")

local BehaviorMemory = _G["BehaviorMemory"]

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

