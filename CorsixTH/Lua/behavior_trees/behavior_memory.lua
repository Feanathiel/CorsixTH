
class "BehaviorMemory"

---@type BehaviorMemory
local BehaviorMemory = _G["BehaviorMemory"]

function BehaviorMemory:BehaviorMemory()
  self.data = {}
end

function BehaviorMemory:get(key)
  return self.data[key]
end

function BehaviorMemory:set(key, value)
  self.data[key] = value
end

function BehaviorMemory:has(key)
  return self.data[key] ~= nil
end

function BehaviorMemory:remove(key)
  self.data[key] = nil
end
