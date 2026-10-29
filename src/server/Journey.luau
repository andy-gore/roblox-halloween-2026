--!strict
-- Server-owned entrance collapse and car escape. All scenery/driver state resets together.
local TweenService=game:GetService("TweenService")
local Config=require(game.ReplicatedStorage:WaitForChild("HalloweenShared"):WaitForChild("Config"))
local Journey={}
Journey.Intro="HALLOWEEN DARE: get the lights on in the abandoned Firefly Tavern. Your working car is parked here."
function Journey.new(map: Folder,clock: (() -> number)?)
    local time=clock or os.clock
    local decor=map.JourneyDressing
    local front=map.FrontDoor :: BasePart
    local beam=decor.FallingEntranceBeam :: BasePart
    local blocker=map.FrontEntranceBlocker :: BasePart
    local car=map.Exterior.BrokenDownCar :: Model
    local parked=car:GetPivot()
    local offset=front.Position-Vector3.new(6,5.5,88)
    local beamHome,doorHome,exitHome=beam.CFrame,front.CFrame,map.ExitDoor.CFrame
    local opened,collapsed=false,false
    local entryUntil,driveAt=0,0
    local driving=false
    local entryAt=0
    local tween: Tween?=nil
    local driver: BasePart?=nil
    local restoreDriver: (() -> ())?=nil
    local wheels: {[BasePart]: CFrame}={}
    for _,p in car:GetChildren() do
        if p:IsA("BasePart") and (p.Name=="Tyre" or p.Name=="WheelHub") then wheels[p]=parked:ToObjectSpace(p.CFrame) end
    end
    local crash=Instance.new("Sound") crash.Name,crash.SoundId="EntranceCrash","rbxasset://sounds/impact_explosion_03.mp3"
    crash.Volume,crash.PlaybackSpeed,crash.RollOffMaxDistance,crash.Parent=0.7,0.75,180,beam
    local doorSound=Instance.new("Sound") doorSound.Name,doorSound.SoundId="ExitClatter","rbxasset://sounds/impact_explosion_03.mp3"
    doorSound.Volume,doorSound.PlaybackSpeed,doorSound.RollOffMaxDistance,doorSound.Parent=0.35,1.1,150,map.ExitDoor
    local engine=Instance.new("Sound") engine.Name,engine.SoundId="CarEngine","rbxasset://sounds/action_swim.mp3"
    engine.Volume,engine.PlaybackSpeed,engine.Looped,engine.RollOffMaxDistance,engine.Parent=0.15,0.45,true,80,car.PrimaryPart
    local function lights(enabled: boolean)
        for _,p in car:GetChildren() do
            if p:IsA("BasePart") and (p.Name=="Headlight" or p.Name=="RearLamp") then
                p.Material=if enabled then Enum.Material.Neon else Enum.Material.Glass
                local light=p:FindFirstChildOfClass("SpotLight") if light then light.Enabled=enabled end
            end
        end
    end
    local controller={}
    function controller.entryActive(): boolean return time()<entryUntil end
    function controller.driveStarted(): number return driveAt end
    function controller.openEntrance()
        if opened or collapsed then return end
        opened=true
        front.CFrame=CFrame.new(offset+Vector3.new(1.5,5.5,88))*CFrame.Angles(0,-math.pi/2,0)*CFrame.new(4.5,0,0)
    end
    function controller.crossed(position: Vector3): boolean
        position-=offset
        return opened and not collapsed and position.X>0 and position.X<12 and position.Y>0 and position.Y<11
            and position.Z<85.5 and position.Z>80
    end
    function controller.collapse()
        if collapsed then return end
        collapsed=true entryAt=time() entryUntil=entryAt+Config.EntrySceneSeconds
        map:SetAttribute("EntranceCollapseStarted",workspace:GetServerTimeNow())
        blocker.CanCollide=true map:SetAttribute("EntranceCollapsed",true)
        crash:Play()
        tween=TweenService:Create(beam,TweenInfo.new(0.75,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{CFrame=CFrame.new(offset+Vector3.new(6,4.2,88))*CFrame.Angles(0,0,0.2)})
        tween:Play()
        for _,p in decor:GetChildren() do if p:IsA("BasePart") and p.Name=="EntranceDebris" then p.Transparency=0 end end
    end
    function controller.phase(stage: number)
        local entry=map.FrontEntrance :: BasePart
        entry.Position=offset+(if collapsed then Vector3.new(6,5,85) else Vector3.new(6,5,90))
        local prompt=entry:FindFirstChildOfClass("ProximityPrompt") :: ProximityPrompt
        prompt.Enabled=(stage==0 and not opened) or (collapsed and stage<6)
        prompt.ActionText,prompt.ObjectText=if collapsed then "Inspect wreckage" else "Open front door",if collapsed then "Front entrance — blocked" else "The Firefly Tavern"
        local escape=car.EscapeCar
        escape.ProximityPrompt.Enabled=stage==5
        escape.CarGoal.Enabled=stage==5
        for _,label in map.EntranceLabel:GetDescendants() do if label:IsA("TextLabel") then label.Text=if collapsed then "FRONT ENTRANCE — BLOCKED" else "FRONT ENTRANCE" end end
    end
    function controller.openExit()
        map.ExitDoor.CanCollide=false map.ExitDoor.Transparency=0.8
        doorSound:Play()
    end
    function controller.beginDrive(character: Model,root: BasePart,humanoid: Humanoid)
        if driving then return end
        driving=true driveAt=time()
        local original,anchored=root.CFrame,root.Anchored
        local speed,jumpPower,jumpHeight,rotate,sit=humanoid.WalkSpeed,humanoid.JumpPower,humanoid.JumpHeight,humanoid.AutoRotate,humanoid.Sit
        local collisions: {[BasePart]: boolean}={}
        for _,p in character:GetDescendants() do if p:IsA("BasePart") then collisions[p]=p.CanCollide p.CanCollide=false end end
        root.Anchored=true root.AssemblyLinearVelocity,root.AssemblyAngularVelocity=Vector3.zero,Vector3.zero
        humanoid.WalkSpeed,humanoid.JumpPower,humanoid.JumpHeight,humanoid.AutoRotate,humanoid.Sit=0,0,0,false,true
        driver=root lights(true) engine:Play()
        restoreDriver=function()
            for p,value in collisions do if p.Parent then p.CanCollide=value end end
            if root.Parent then root.CFrame=original root.Anchored=anchored root.AssemblyLinearVelocity,root.AssemblyAngularVelocity=Vector3.zero,Vector3.zero
                if not anchored then pcall(function() root:SetNetworkOwnershipAuto() end) end end
            if humanoid.Parent then humanoid.WalkSpeed,humanoid.JumpPower,humanoid.JumpHeight,humanoid.AutoRotate,humanoid.Sit=speed,jumpPower,jumpHeight,rotate,sit end
        end
    end
    function controller.stepDrive(): boolean
        if not driving then return false end
        local elapsed=math.max(0,time()-driveAt)
        local junction=CFrame.new(-40+offset.X,parked.Y,132+offset.Z)
        local cf
        if elapsed<1.3 then
            local t=elapsed/1.3 cf=parked:Lerp(junction,t*t*(3-2*t))
        else cf=junction:Lerp(CFrame.new(190+offset.X,parked.Y,132+offset.Z),math.clamp((elapsed-1.3)/(Config.DriveSeconds-1.3),0,1)) end
        car:PivotTo(cf)
        for wheel,bind in wheels do wheel.CFrame=cf*bind*CFrame.Angles(elapsed*22,0,0) end
        if driver and driver.Parent then driver.CFrame=cf*CFrame.new(-1,0.4,0) end
        return elapsed>=Config.DriveSeconds
    end
    function controller.reset()
        if restoreDriver then restoreDriver() restoreDriver=nil end
        driver=nil driving=false driveAt=0 entryUntil=0 opened=false collapsed=false
        if tween then tween:Cancel() tween=nil end
        crash:Stop() doorSound:Stop() engine:Stop()
        front.CFrame,beam.CFrame,blocker.CanCollide=doorHome,beamHome,false
        map.ExitDoor.CFrame=exitHome map.ExitDoor.CanCollide,map.ExitDoor.Transparency=true,0
        map:SetAttribute("EntranceCollapsed",false)
        car:PivotTo(parked)
        for wheel,bind in wheels do wheel.CFrame=parked*bind end
        lights(false)
        for _,p in decor:GetChildren() do if p:IsA("BasePart") and p.Name=="EntranceDebris" then p.Transparency=1 end end
        controller.phase(0)
    end
    controller.reset()
    return controller
end
return Journey
