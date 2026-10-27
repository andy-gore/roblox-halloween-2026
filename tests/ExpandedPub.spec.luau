--!strict
-- Studio Edit-mode server Command Bar; temporary fixture is removed on pass or failure.
local server = game.ServerScriptService:WaitForChild("HalloweenServer")
local map = require(server:WaitForChild("PrototypeMap")).build()
map.Name = "ExpandedPubTest"
local offset = Vector3.new(5000,0,0)
for _, object in map:GetDescendants() do
    if object:IsA("BasePart") then object.Position += offset end
end
local ok, err = pcall(function()
    local key = map:FindFirstChild("OfficeKey") :: Part
    local placement = require(server:WaitForChild("KeyPlacement")).new(map,key)
    local seen: {[string]: boolean} = {}
    local bedrooms = 0
    for _, object in map:GetChildren() do if object.Name == "BedroomBed" then bedrooms += 1 end end
    assert(bedrooms==8, "Expected eight furnished bedrooms")
    local furniture: {[string]: number} = {BedroomBed=0, BedroomHeadboard=0, BedroomDresser=0, BedroomWardrobe=0}
    for _,object in map:GetChildren() do
        if object:IsA("BasePart") and furniture[object.Name] ~= nil then
            assert(object.Anchored and object.CanCollide, "Guest furniture must be solid: "..object.Name)
            furniture[object.Name] += 1
        end
    end
    for name,count in furniture do assert(count==8,"Expected one solid "..name.." per bedroom") end
    for i=1,9 do
        local name=placement.choose(i)
        assert(not seen[name], "Duplicate key room") seen[name]=true
        assert(key.Transparency==1 and not (key:FindFirstChildOfClass("ProximityPrompt") :: ProximityPrompt).Enabled, "Choosing a room must not reveal the key")
        if name~="Office" then assert(key.Position.Y>16, "Bedroom key must be upstairs") end
    end
    assert(seen.Office and seen.Room01 and seen.Room08, "Expected office and numbered guest rooms")
    local monster=map:FindFirstChild("ChuggernaughtPlaceholder") :: Part
    local controller=require(server:WaitForChild("MonsterNavigation")).new(monster)
    controller.validate()
    local destinations={Vector3.new(-8,0.5,23)}
    for _,z in {-30,-10,10,30} do table.insert(destinations,Vector3.new(-26,16.5,z)) end
    for _,z in {30,10,-10,-30} do table.insert(destinations,Vector3.new(26,16.5,z)) end
    table.insert(destinations,Vector3.new(-29,0.5,-29))
    table.insert(destinations,Vector3.new(-36,0.5,34))
    table.insert(destinations,Vector3.new(36,-15.5,-35))
    for i,destination in destinations do
        local target=destination+offset
        local arrived=false
        for _=1,800 do
            controller.step(target,16,0.1)
            for _,object in workspace:GetPartsInPart(monster) do
                if object:IsDescendantOf(map) and (object:GetAttribute("BlocksNavigation")==true or string.find(object.Name,"Wall") or string.find(object.Name,"Partition")) then
                    error("Monster crossed "..object.Name.." at destination "..i)
                end
            end
            if (monster.Position-target-Vector3.new(0,4,0)).Magnitude<1 then arrived=true break end
            task.wait(0.015)
        end
        assert(arrived,"Failed destination "..i.." at "..tostring(monster.Position-offset))
    end
    controller.reset()
end)
map:Destroy()
assert(ok,tostring(err))
print("Expanded pub: eight bedrooms, nine key rooms and full pursuit route passed")
