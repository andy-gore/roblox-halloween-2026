--!strict
-- Small server-owned sequence; only the final lever can complete the power objective.
local Sequence = {}
local order = {"Cellar", "Guest", "Bar"}
function Sequence.new()
    local progress, powered = 0, false
    local controller = {}
    function controller.reset() progress, powered = 0, false end
    function controller.progress(): number return progress end
    function controller.powered(): boolean return powered end
    function controller.press(circuit: string): boolean
        if powered then return false end
        if circuit ~= order[progress+1] then progress=0 return false end
        progress+=1
        return true
    end
    function controller.pullMain(): boolean
        if powered or progress~=#order then return false end
        powered=true
        return true
    end
    return controller
end
return Sequence
