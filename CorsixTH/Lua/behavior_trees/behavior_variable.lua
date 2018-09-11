
class "BehaviorVariable"

---@type BehaviorVariable
local BehaviorVariable = _G["BehaviorVariable"]

function BehaviorVariable:BehaviorVariable(name, value)
  self.name = name
  self.value = value
end

function BehaviorVariable:get()
  return self.value
end

function BehaviorVariable:set(value)
  self.value = value
end
