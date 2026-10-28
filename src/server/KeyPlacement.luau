--!strict
-- One server choice per new run; power restoration never rerolls the location.
local KeyPlacement = {}
function KeyPlacement.new(map: Folder, key: BasePart)
    local locations: {BasePart} = {}
    for _, object in map:WaitForChild("KeyLocations"):GetChildren() do
        if object:IsA("BasePart") then table.insert(locations, object) end
    end
    table.sort(locations, function(a, b) return a.Name < b.Name end)
    assert(#locations == 9, "Expected office plus eight bedroom key locations")
    local random = Random.new()
    local placement = {}
    function placement.choose(index: number?): string
        local chosen = locations[index or random:NextInteger(1, #locations)]
        assert(chosen, "Invalid key location")
        key.CFrame = chosen.CFrame
        key:SetAttribute("KeyRoom",chosen.Name)
        return chosen.Name
    end
    return placement
end
return KeyPlacement
