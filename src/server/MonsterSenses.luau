--!strict
-- Server sight and reach share actual map occlusion; presentation never grants immunity.
local Config = require(game.ReplicatedStorage:WaitForChild("HalloweenShared"):WaitForChild("Config"))
local Senses = {}
function Senses.new(monster: BasePart)
    local cast = RaycastParams.new()
    cast.FilterType = Enum.RaycastFilterType.Exclude
    cast.RespectCanCollide = true
    local controller = {}
    function controller.sample(character: Model, playerRoot: BasePart, alert: boolean?): (boolean, boolean, boolean)
        cast.FilterDescendantsInstances = {monster, character}
        local head = character:FindFirstChild("Head")
        local eye = monster.Position + Vector3.new(0, 2.2, 0)
        local target = if head and head:IsA("BasePart") then head.Position else playerRoot.Position + Vector3.new(0, 1.5, 0)
        local delta = target - eye
        local flat = Vector3.new(delta.X, 0, delta.Z)
        local distance = flat.Magnitude
        local facing = if distance > 0.01 then monster.CFrame.LookVector:Dot(flat.Unit) else 1
        local unobstructed = workspace:Raycast(eye, delta, cast) == nil
        local peripheral = if alert then Config.AlertPeripheralDistance else Config.SightPeripheralDistance
        local cone = if alert then Config.AlertSightConeCosine else Config.SightConeCosine
        local visible = unobstructed and delta.Magnitude <= Config.SightDistance
            and (distance <= peripheral or facing >= cone)
        local sameLevel = math.abs(playerRoot.Position.Y - monster.Position.Y) < 4
        local contact = unobstructed and sameLevel and distance <= Config.MonsterContactDistance
        local reachable = contact or (unobstructed and sameLevel and distance <= Config.CatchDistance and facing >= 0)
        return visible, reachable, contact
    end
    function controller.footsteps(character: Model, playerRoot: BasePart): boolean
        local velocity=playerRoot.AssemblyLinearVelocity
        if Vector3.new(velocity.X,0,velocity.Z).Magnitude<Config.FootstepSpeed then return false end
        local delta=playerRoot.Position-monster.Position
        if math.abs(delta.Y)>4 or delta.Magnitude>Config.FootstepDistance then return false end
        cast.FilterDescendantsInstances={monster,character}
        -- Airborne movement and different floors cannot create a ground-level sound trail.
        if not workspace:Raycast(playerRoot.Position,Vector3.new(0,-4.5,0),cast) then return false end
        local blocked=workspace:Raycast(monster.Position,delta,cast)~=nil
        return not blocked or delta.Magnitude<=Config.FootstepOccludedDistance
    end
    return controller
end
return Senses
