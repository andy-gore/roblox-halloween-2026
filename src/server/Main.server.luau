--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("HalloweenShared"):WaitForChild("Config"))
local RunState = require(script.Parent.RunState)
-- Only the separate prototype project enables this runtime greybox.
if workspace:GetAttribute("LastOrdersGreybox") ~= true then
    print("Last Orders code ready; greybox disabled in authored place")
    return
end
-- The scaffold baseplate otherwise seals the cellar opening when code is synced.
-- This changes only the temporary Play datamodel; Stop restores the authored part.
local starterPlate = workspace:FindFirstChild("Baseplate")
if starterPlate and starterPlate:IsA("Part") and starterPlate.Anchored
    and starterPlate.Size == Vector3.new(128, 1, 128)
    and starterPlate.Position == Vector3.new(0, -0.5, 0) then
    starterPlate.CanCollide, starterPlate.CanQuery, starterPlate.Transparency = false, false, 1
end
require(script.Parent.PubAtmosphere).apply()
local map = require(script.Parent.PrototypeMap).build()
local monster = map:WaitForChild("ChuggernaughtPlaceholder") :: Part
local key = map:WaitForChild("OfficeKey") :: Part
local keyPrompt = key:FindFirstChildOfClass("ProximityPrompt") :: ProximityPrompt
local keyPlacement = require(script.Parent.KeyPlacement).new(map, key)
local keyVisual = require(script.Parent.ExitKeyVisual).new(key)
local power = require(script.Parent.CellarPower).new(map)
local home = monster.CFrame
local navigation = require(script.Parent.MonsterNavigation).new(monster)
local encounter = require(script.Parent.MonsterEncounter).new(monster)
local senses = require(script.Parent.MonsterSenses).new(monster)
local grab = require(script.Parent.MonsterGrab).new()
local hunt = require(script.Parent.MonsterHunt).new({
    Vector3.new(36, 0.5, 23), Vector3.new(-8, 0.5, 23),
    Vector3.new(-29, 0.5, -29), Vector3.new(9, 0.5, -29),
    Vector3.new(0, 16.5, -30), Vector3.new(0, 16.5, 30),
    Vector3.new(28, 0.5, 84), Vector3.new(-36, 0.5, 23),
}, nil, navigation.searchTargets)
local exitDoor = map:WaitForChild("ExitDoor") :: Part
local spawn = map:WaitForChild("PrototypeSpawn") :: SpawnLocation
local bell = map:WaitForChild("Bell") :: Part
local lights: {PointLight} = {}
for _, object in map:GetDescendants() do
    if object:IsA("PointLight") and object.Name == "PowerLight" then
        table.insert(lights, object)
    end
end
local state = RunState.new()
local activePlayer: Player? = nil
local graceUntil = 0
local function update(message: string?)
    power.available(state.stage == 2)
    key.Transparency = if state.stage == 3 then 0 else 1
    keyPrompt.Enabled = state.stage == 3
    key.CanQuery = state.stage == 3
    keyVisual.refresh(state.stage == 3)
    for _, light in lights do
        light.Brightness = if state.stage >= 3 then 2 else 0.35
    end
    exitDoor.CanCollide = state.stage < 5
    exitDoor.Transparency = if state.stage >= 5 then 0.8 else 0
    local player = activePlayer
    if player then
        player:SetAttribute("LastOrdersStage", state.stage)
        player:SetAttribute("LastOrdersMessage", message or "")
        player:SetAttribute("HasExitKey", state.stage >= 4)
        player:SetAttribute("CellarBreakerProgress", map.CellarPowerPanel:GetAttribute("BreakerProgress"))
    end
end
local function reset(message: string?)
    state = RunState.new()
    power.reset()
    graceUntil = os.clock() + 3
    keyPlacement.choose()
    navigation.reset()
    encounter.reset()
    hunt.reset()
    grab.reset()
    bell:SetAttribute("ReadyAt", 0)
    monster.CFrame = home
    monster:SetAttribute("MonsterBehaviour", "Dormant")
    update(message)
end
local function join(player: Player)
    if activePlayer then
        player:SetAttribute("LastOrdersMessage", "This prototype supports one player per server.")
        return
    end
    activePlayer = player
    player.RespawnLocation = spawn
    player.CharacterAdded:Connect(function()
        player.RespawnLocation = spawn
        reset("Find the warning at the bar.")
    end)
    reset()
end
Players.PlayerAdded:Connect(join)
Players.PlayerRemoving:Connect(function(player)
    if activePlayer == player then
        activePlayer = nil
        reset()
    end
end)
for _, player in Players:GetPlayers() do join(player) end
local stations = { Warning = 1, CellarFuseBox = 2, CellarBreakerCellar = 2, CellarBreakerGuest = 2,
    CellarBreakerBar = 2, CellarInstructions = 0, OfficeKey = 3, Bell = 0, EmergencyExit = 4 }
for name, expected in stations do
    local station = map:FindFirstChild(name) :: Part
    local prompt = station:FindFirstChildOfClass("ProximityPrompt") :: ProximityPrompt
    prompt.Triggered:Connect(function(player: Player)
        local character = player.Character
        local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
        local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
        if player ~= activePlayer or not character or not root or not root:IsA("BasePart") or not humanoid or humanoid.Health <= 0 then return end
        if (root.Position - station.Position).Magnitude > Config.InteractionDistance then return end
        local sight = RaycastParams.new()
        sight.FilterType = Enum.RaycastFilterType.Exclude
        sight.FilterDescendantsInstances = {character, monster}
        -- A waist-height ray hits counters even when the player can see the prompt.
        local head = character:FindFirstChild("Head")
        local eye = if head and head:IsA("BasePart") then head.Position else root.Position + Vector3.new(0, 2, 0)
        local obstruction = workspace:Raycast(eye, station.Position - eye, sight)
        if obstruction and obstruction.Instance ~= station then
            update("Move into view of the item to interact.")
            return
        end
        if name == "Warning" and state.stage > 1 then
            update("NEVER LET HIM FINISH HIS DRINK.")
            return
        end
        if name == "CellarInstructions" then
            update(require(script.Parent.CellarPower).Instructions)
            return
        end
        if string.sub(name, 1, 13) == "CellarBreaker" then
            if state.stage ~= 2 then update("Read the warning before restoring power.") return end
            local _, message = power.use(name)
            update(message)
            return
        end
        if name == "Bell" then
            if state.stage < 3 or state.stage >= 5 then return end
            if not hunt.ringBell(Vector3.new(-20, 0.5, 23)) then
                update("Give the bell a moment: " .. math.ceil(hunt.bellCooldown()) .. "s.")
                return
            end
            bell:SetAttribute("ReadyAt", workspace:GetServerTimeNow() + Config.BellCooldownSeconds)
            local visible = senses.sample(character, root, hunt.alert())
            update(if visible then "He can see you! The bell won't fool him. Break his sight and run!"
                else "The bell rang. Move away before he investigates!")
            return
        end
        if state.stage ~= expected then
            update("Follow the current objective first.")
            return
        end
        if name == "CellarFuseBox" then
            local completed, message = power.use(name)
            if not completed then update(message) return end
        end
        RunState.advance(state, expected)
        if state.stage >= 5 then encounter.stop() end
        if expected == 2 then
            local look = root.Position - monster.Position
            local flat = Vector3.new(look.X, 0, look.Z)
            if flat.Magnitude > 0.01 then monster.CFrame = CFrame.lookAt(monster.Position, monster.Position + flat.Unit) end
            encounter.wake()
            graceUntil = os.clock() + Config.MonsterRevealSeconds
            update("POWER RESTORED! He's waking beyond the barrel rack. Get to the stairs!")
        elseif expected == 3 then
            update("You have the exit key. Get to the emergency exit!")
        elseif expected == 1 then
            update("NEVER LET HIM FINISH HIS DRINK.")
        else
            update()
        end
    end)
end
RunService.Heartbeat:Connect(function(dt: number)
    local player = activePlayer
    if not player or state.stage < 3 or state.stage >= 5 then return end
    local character = player.Character
    local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
    local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
    if not character or not root or not root:IsA("BasePart") or not humanoid or humanoid.Health <= 0 then return end
    if not encounter.active() then
        local _, message = encounter.step("Patrol")
        if message then update(message) end
        if not encounter.active() then return end
    end
    local visible, inReach, contact = senses.sample(character, root, hunt.alert())
    local feet = monster.Position - Vector3.new(0, 4, 0)
    if not visible and senses.footsteps(character, root) then
        if hunt.hearFootstep(root.Position - Vector3.new(0, 2.5, 0)) then
            update("He heard your footsteps. Break his sight and keep still to lose him.")
        end
    end
    local target, behaviour, looking = hunt.step(feet, root.Position - Vector3.new(0, 2.5, 0), visible)
    monster:SetAttribute("MonsterBehaviour", behaviour)
    local action = grab.step(inReach and os.clock() > graceUntil, contact and os.clock() > graceUntil)
    if action == "Caught" then
        reset("Caught! Try again. Your progress has been reset.")
        character:PivotTo(spawn.CFrame + Vector3.new(0, 4, 0))
        return
    end
    local canMove, message = encounter.step(if action == "Ready" then behaviour else action)
    if message then update(message) end
    if not canMove then return end
    if os.clock() < graceUntil then return end
    if looking then
        -- Searching turns his real sight cone; the client follows this authoritative facing.
        monster.CFrame *= CFrame.Angles(0, math.min(dt, 0.1) * 1.8, 0)
        return
    end
    local speed = if behaviour == "Chase" then Config.ChaseSpeed
        elseif behaviour == "Investigate" then Config.InvestigateSpeed
        elseif behaviour == "Search" then Config.SearchSpeed else Config.MonsterSpeed
    navigation.step(target, encounter.speed(speed), dt)
end)
print("Last Orders prototype ready")
