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
local map = require(script.Parent.PrototypeMap).build()
local monster = map:WaitForChild("ChuggernaughtPlaceholder") :: Part
local tankard = map:WaitForChild("Tankard") :: Part
local home = monster.Position
local state = RunState.new()
local activePlayer: Player? = nil
local distractedUntil = 0
local graceUntil = 0
local function update(message: string?)
    local player = activePlayer
    if player then
        player:SetAttribute("LastOrdersStage", state.stage)
        player:SetAttribute("LastOrdersMessage", message or "")
        player:SetAttribute("HasExitKey", state.stage >= 4)
        player:SetAttribute("HasTankard", state.stage >= 6)
    end
end
local function reset(message: string?)
    state = RunState.new()
    distractedUntil = 0
    graceUntil = os.clock() + 3
    monster.Position = home
    tankard.Transparency = 0
    update(message)
end
local function join(player: Player)
    if activePlayer then
        player:SetAttribute("LastOrdersMessage", "This prototype supports one player per server.")
        return
    end
    activePlayer = player
    player.CharacterAdded:Connect(function()
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
local stations = { Warning = 1, CellarFuseBox = 2, OfficeKey = 3, Bell = 4, Tankard = 5, EmergencyExit = 6 }
for name, expected in stations do
    local station = map:FindFirstChild(name) :: Part
    local prompt = station:FindFirstChildOfClass("ProximityPrompt") :: ProximityPrompt
    prompt.Triggered:Connect(function(player: Player)
        local character = player.Character
        local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
        local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
        if player ~= activePlayer or not root or not root:IsA("BasePart") or not humanoid or humanoid.Health <= 0 then return end
        if (root.Position - station.Position).Magnitude > Config.InteractionDistance then return end
        if state.stage ~= expected then
            update("Follow the current objective first.")
            return
        end
        if expected == 5 and os.clock() >= distractedUntil then return end
        if expected == 6 then
            state.stage = 7
        else
            RunState.advance(state, expected)
        end
        if expected == 2 then
            graceUntil = os.clock() + 3
            update("LAST ORDERS! The Chuggernaught is awake.")
        elseif expected == 4 then
            distractedUntil = os.clock() + Config.DistractionSeconds
            update("He is heading for the bell. Grab the tankard!")
        elseif expected == 5 then
            tankard.Transparency = 1
            distractedUntil = 0
            graceUntil = os.clock() + 2
            update("OI! THAT'S MY TANKARD!")
        elseif expected == 1 then
            update("NEVER LET HIM FINISH HIS DRINK.")
        else
            update()
        end
    end)
end
RunService.Heartbeat:Connect(function(dt: number)
    local player = activePlayer
    if not player or state.stage < 3 or state.stage >= 7 then return end
    if state.stage == 5 and os.clock() >= distractedUntil then
        state.stage = 4
        update("He returned to his tankard. Ring the bell again.")
    end
    local character = player.Character
    local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
    if not root or not root:IsA("BasePart") then return end
    local distracted = os.clock() < distractedUntil
    local target = if distracted then (map:FindFirstChild("Bell") :: Part).Position else root.Position
    local delta = Vector3.new(target.X - monster.Position.X, 0, target.Z - monster.Position.Z)
    if not distracted and delta.Magnitude < Config.CatchDistance and os.clock() > graceUntil then
        reset("Caught! Try again. Your progress has been reset.")
        character:PivotTo(CFrame.new(0, 5, 20))
        return
    end
    if os.clock() < graceUntil then return end
    local speed = if state.stage >= 6 then Config.ChaseSpeed else Config.MonsterSpeed
    if delta.Magnitude > 1 then
        monster.Position += delta.Unit * math.min(delta.Magnitude, speed * math.min(dt, 0.1))
    end
end)
print("Last Orders prototype ready")
