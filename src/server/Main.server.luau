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
local home = monster.CFrame
local navigation = require(script.Parent.MonsterNavigation).new(monster)
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
local distractedUntil = 0
local graceUntil = 0
local function update(message: string?)
    key.Transparency = if state.stage == 3 then 0 else 1
    keyPrompt.Enabled = state.stage == 3
    key.CanQuery = state.stage == 3
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
    end
end
local function reset(message: string?)
    state = RunState.new()
    distractedUntil = 0
    graceUntil = os.clock() + 3
    keyPlacement.choose()
    navigation.reset()
    monster.CFrame = home
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
local stations = { Warning = 1, CellarFuseBox = 2, OfficeKey = 3, Bell = 0, EmergencyExit = 4 }
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
        if name == "Bell" then
            if state.stage < 3 or state.stage >= 5 then return end
            distractedUntil = os.clock() + Config.DistractionSeconds
            update("He is heading for the bell. Keep moving!")
            return
        end
        if state.stage ~= expected then
            update("Follow the current objective first.")
            return
        end
        RunState.advance(state, expected)
        if expected == 2 then
            graceUntil = os.clock() + 3
            update("LAST ORDERS! The Chuggernaught is awake.")
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
    if not character or not root or not root:IsA("BasePart") then return end
    local distracted = os.clock() < distractedUntil
    local target = if distracted then bell.Position - Vector3.new(0, 4, -6) else root.Position - Vector3.new(0, 2.5, 0)
    local delta = root.Position - monster.Position
    local sight = RaycastParams.new()
    sight.FilterType = Enum.RaycastFilterType.Exclude
    sight.FilterDescendantsInstances = {monster, character}
    if not distracted and delta.Magnitude < Config.CatchDistance and os.clock() > graceUntil
        and workspace:Raycast(monster.Position, delta, sight) == nil then
        reset("Caught! Try again. Your progress has been reset.")
        character:PivotTo(spawn.CFrame + Vector3.new(0, 4, 0))
        return
    end
    if os.clock() < graceUntil then return end
    local speed = if state.stage >= 4 then Config.ChaseSpeed else Config.MonsterSpeed
    navigation.step(target, speed, dt)
end)
print("Last Orders prototype ready")
