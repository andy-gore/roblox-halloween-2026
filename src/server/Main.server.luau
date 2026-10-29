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
local journey = require(script.Parent.Journey).new(map)
local replay = Instance.new("RemoteEvent")
replay.Name, replay.Parent = "RestartJourney", game.ReplicatedStorage.HalloweenShared
local home = monster.CFrame
local navigation = require(script.Parent.MonsterNavigation).new(monster)
local encounter = require(script.Parent.MonsterEncounter).new(monster)
local senses = require(script.Parent.MonsterSenses).new(monster)
local grab = require(script.Parent.MonsterGrab).new()
local survival = require(script.Parent.PlayerSurvival).new()
local hold = require(script.Parent.PlayerHold).new(monster)
local hunt = require(script.Parent.MonsterHunt).new({
    Vector3.new(36, 0.5, 23), Vector3.new(-8, 0.5, 23),
    Vector3.new(-29, 0.5, -29), Vector3.new(9, 0.5, -29),
    Vector3.new(0, 16.5, -30), Vector3.new(0, 16.5, 30),
    Vector3.new(28, 0.5, 84), Vector3.new(-36, 0.5, 23),
}, nil, navigation.searchTargets)
local exitDoor = map:WaitForChild("ExitDoor") :: Part
local spawn = map:WaitForChild("PrototypeSpawn") :: SpawnLocation
local bell = map:WaitForChild("Bell") :: Part
local bellSound=Instance.new("Sound") bellSound.Name,bellSound.SoundId="BellRing","rbxasset://sounds/volume_slider.ogg"
bellSound.Volume,bellSound.PlaybackSpeed,bellSound.RollOffMinDistance,bellSound.RollOffMaxDistance=.8,1.35,10,90
bellSound.Parent=bell
local lastBell=-math.huge
local lights: {PointLight} = {}
for _, object in map:GetDescendants() do
    if object:IsA("PointLight") and object.Name == "PowerLight" then
        table.insert(lights, object)
    end
end
local state = RunState.new()
local activePlayer: Player? = nil
local graceUntil = 0
local arrivalUntil=0
local arrivalSeen=false
local skipArrival=Instance.new("RemoteEvent") skipArrival.Name,skipArrival.Parent="SkipArrival",game.ReplicatedStorage.HalloweenShared
skipArrival.OnServerEvent:Connect(function(player)
    if player~=activePlayer or state.stage~=0 then return end
    arrivalUntil=0 player:SetAttribute("LastOrdersArrivalScene",false)
end)
local function updateVitals()
    local player=activePlayer
    if not player then return end
    player:SetAttribute("LastOrdersArrivalScene",os.clock()<arrivalUntil)
    player:SetAttribute("LastOrdersDriving",state.stage>=6)
    player:SetAttribute("LastOrdersEntryScene",journey.entryActive())
    player:SetAttribute("LastOrdersDriveStarted",journey.driveStarted())
    player:SetAttribute("LastOrdersHealth",survival.health())
    player:SetAttribute("LastOrdersMaxHealth",Config.PlayerMaxHealth)
    player:SetAttribute("LastOrdersHeld",survival.locked())
    player:SetAttribute("LastOrdersGameOver",survival.phase()=="GameOver")
    player:SetAttribute("LastOrdersProtected",survival.protected())
end
local function update(message: string?)
    updateVitals()
    journey.phase(state.stage)
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
    arrivalUntil=0
    hold.release()
    survival.reset()
    journey.reset()
    state = RunState.new()
    power.reset()
    require(script.Parent.AssetDressing).reroll(map)
    graceUntil = os.clock() + 3
    keyPlacement.choose()
    navigation.reset()
    encounter.reset()
    hunt.reset()
    grab.reset()
    bell:SetAttribute("ReadyAt", 0)
    bellSound:Stop() lastBell=-math.huge
    monster.CFrame = home
    monster:SetAttribute("MonsterBehaviour", "Dormant")
    update(message)
    navigation.refresh()
end
replay.OnServerEvent:Connect(function(player)
    if player~=activePlayer or state.stage~=7 then return end
    reset(require(script.Parent.Journey).Intro)
    if player.Character then player.Character:PivotTo(spawn.CFrame+Vector3.new(0,4,0)) end
end)
local function join(player: Player)
    if activePlayer then
        player:SetAttribute("LastOrdersMessage", "This prototype supports one player per server.")
        return
    end
    activePlayer = player
    arrivalSeen=false
    player.RespawnLocation = spawn
    player.CharacterAdded:Connect(function(character)
        player.RespawnLocation = spawn
        reset(require(script.Parent.Journey).Intro)
        local root=character:WaitForChild("HumanoidRootPart",10)
        if root and character==player.Character then
            character:PivotTo(spawn.CFrame+Vector3.new(0,3,0))
            if not arrivalSeen then
                arrivalSeen=true arrivalUntil=os.clock()+4
                player:SetAttribute("LastOrdersArrivalStarted",workspace:GetServerTimeNow())
                updateVitals()
            end
        end
    end)
    reset(require(script.Parent.Journey).Intro)
end
Players.PlayerAdded:Connect(join)
Players.PlayerRemoving:Connect(function(player)
    if activePlayer == player then
        activePlayer = nil
        reset()
    end
end)
for _, player in Players:GetPlayers() do join(player) end
local stations = { FrontEntrance = 0, EscapeCar = 5, Warning = 1, CellarFuseBox = 2, CellarBreakerCellar = 2, CellarBreakerGuest = 2,
    CellarBreakerBar = 2, CellarInstructions = 0, OfficeKey = 3, Bell = 0, EmergencyExit = 4 }
for name, expected in stations do
    local station = map:FindFirstChild(name,true) :: Part
    local prompt = station:FindFirstChildOfClass("ProximityPrompt") :: ProximityPrompt
    prompt.Triggered:Connect(function(player: Player)
        local character = player.Character
        local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
        local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
        if player ~= activePlayer or not character or not root or not root:IsA("BasePart") or not humanoid or humanoid.Health <= 0 then return end
        if survival.locked() or journey.entryActive() or os.clock()<arrivalUntil or state.stage>=6 then return end
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
        if name == "FrontEntrance" then
            if state.stage==0 then journey.openEntrance() update("The door is open. Step inside to begin the dare.")
            else update("The fallen beam blocks the entrance. Find the emergency exit key.") end
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
            if os.clock()-lastBell<.25 then return end
            lastBell=os.clock() bellSound:Play()
            if state.stage<3 then update("The bell rings through the empty tavern.") return end
            if not hunt.ringBell(Vector3.new(-20, 0.5, 23)) then
                update("The bell rang. He will not fall for another distraction for " .. math.ceil(hunt.bellCooldown()) .. "s.")
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
        if expected==5 then
            survival.finish() encounter.stop() journey.beginDrive(character,root,humanoid)
            update("You made it to the car. Get out of here!") return
        elseif expected==4 then
            journey.openExit() navigation.refresh()
            hunt.alarm(Vector3.new(-36,0.5,44)) encounter.rally()
            update("The exit is open! Follow the courtyard lights to your car!") return
        end
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
    if not player or state.stage==7 then return end
    local character = player.Character
    local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
    local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
    if not character or not root or not root:IsA("BasePart") or not humanoid or humanoid.Health <= 0 then return end
    if state.stage<6 and not survival.locked() and (root.Position.Y< -45 or math.abs(root.Position.X)>216 or math.abs(root.Position.Z)>176) then
        character:PivotTo(if state.stage==0 then spawn.CFrame+Vector3.new(0,3,0) else CFrame.new(6,4,82))
        root.AssemblyLinearVelocity,root.AssemblyAngularVelocity=Vector3.zero,Vector3.zero
        graceUntil=os.clock()+3
        update("Back on safe ground. Your progress is preserved.")
        return
    end
    if state.stage==0 then
        updateVitals()
        if os.clock()<arrivalUntil then return end
        if journey.crossed(root.Position) then
            RunState.advance(state,0) journey.collapse() navigation.refresh()
            update("The entrance beam has fallen! Find another way out. Read the warning at the bar.")
        end
        return
    elseif state.stage==6 then
        if journey.stepDrive() then RunState.advance(state,6) update("You survived Last Orders. The dare is over.") end
        return
    elseif state.stage<3 then updateVitals() return end
    hold.step()
    local event=survival.step()
    if event=="Restart" then
        reset("Caught twice! Try again with two fresh health segments.")
        character:PivotTo(spawn.CFrame+Vector3.new(0,4,0))
        return
    elseif event=="Release" then
        hold.release()
        grab.reset()
        update("One hit left! He's recovering. Get away and break his sight!")
    end
    updateVitals()
    local phase=survival.phase()
    if phase=="Held" or phase=="Recovery" or phase=="GameOver" then
        encounter.step(if phase=="Held" then "Hold" elseif phase=="Recovery" then "Stunned" else "Defeat")
        return
    end
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
    local vulnerable=not survival.protected() and os.clock()>graceUntil
    local action = grab.step(inReach and vulnerable, contact and vulnerable)
    if action == "Caught" then
        if survival.hit() then
            hold.begin(character,root,humanoid,survival.health()==0)
            grab.reset()
            encounter.step("Hold")
            update(if survival.health()>0 then "He caught you! One hit left — get ready to run."
                else "He caught you again!")
        end
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
    navigation.step(target, if state.stage==5 then Config.FinaleSpeed else encounter.speed(speed), dt)
end)
print("Last Orders prototype ready")
