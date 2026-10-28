--!strict
-- Server-owned panel presentation and anticipation cues; no monster or objective advancement here.
local Sequence=require(script.Parent.BreakerSequence)
local TweenService=game:GetService("TweenService")
local Power={}
Power.Instructions="CELLAR FIRST. GUEST ROOMS BEFORE THE BAR. MAIN SUPPLY LAST."
local circuits={"Cellar","Guest","Bar"}
function Power.new(map: Folder)
    local sequence=Sequence.new()
    local decor=map:WaitForChild("CellarDressing")
    local panel=map:WaitForChild("CellarPowerPanel")
    local cue=map:FindFirstChild("CellarCueLight",true) :: PointLight
    local crate=decor:WaitForChild("LooseCellarCrate") :: BasePart
    local crateHome=crate.CFrame
    local handles: {[string]: BasePart}={}
    local indicators: {[string]: BasePart}={}
    local bind: {[string]: CFrame}={}
    local names={"CellarBreakerCellar","CellarBreakerGuest","CellarBreakerBar","CellarFuseBox"}
    for _,name in names do
        handles[name]=decor:WaitForChild(name.."Handle") :: BasePart
        indicators[name]=decor:WaitForChild(name.."Indicator") :: BasePart
        bind[name]=handles[name].CFrame
    end
    local function sound(name: string,parent: Instance,path: string,volume: number,pitch: number): Sound
        local s=Instance.new("Sound") s.Name,s.SoundId,s.Volume,s.PlaybackSpeed=name,path,volume,pitch
        s.RollOffMinDistance,s.RollOffMaxDistance,s.Parent=7,70,parent return s
    end
    -- Existing bundled local placeholders; no asset uploads.
    local click=sound("BreakerClunk",panel,"rbxasset://sounds/action_footsteps_plastic.mp3",0.5,0.6)
    local thud=sound("BarrelShift",crate,"rbxasset://sounds/action_footsteps_plastic.mp3",0.7,0.4)
    local glug=sound("CellarGlug",cue.Parent :: Instance,"rbxasset://sounds/impact_water.mp3",0.65,0.65)
    local tween: Tween?=nil
    local wrong: string?=nil
    local controller={}
    local function apply()
        local progress=sequence.progress()
        for i,name in names do
            local on=if i==4 then sequence.powered() else i<=progress
            handles[name].CFrame=bind[name]*CFrame.Angles(0,0,if on then -0.8 else 0.15)
            indicators[name].Color=if wrong==name then Color3.fromRGB(215,61,42)
                elseif on or (i==4 and progress==3) then Color3.fromRGB(113,222,112) else Color3.fromRGB(107,77,41)
        end
        cue.Brightness=if sequence.powered() then 2.6 elseif progress>0 then 1.2+progress*0.3 else 0
        panel:SetAttribute("BreakerProgress",progress)
        panel:SetAttribute("Powered",sequence.powered())
        local status=if sequence.powered() then "POWER RESTORED" elseif progress==3 then "READY\nPULL MAIN LEVER" else "NOT READY\n"..progress.."/3 CIRCUITS"
        for _,obj in (decor:WaitForChild("MainSupplyStatus")):GetDescendants() do
            if obj:IsA("TextLabel") then obj.Text=status end
        end
        for i,name in names do
            local prompt=(map:FindFirstChild(name) :: BasePart):FindFirstChildOfClass("ProximityPrompt") :: ProximityPrompt
            prompt.ObjectText=if i==4 then (if progress==3 then "MAIN SUPPLY — READY" else "MAIN SUPPLY — "..progress.."/3 CIRCUITS")
                else (if i==1 then "CELLAR" elseif i==2 then "GUEST ROOMS" else "BAR")..(if i<=progress then " — ON" else " — OFF")
        end
    end
    function controller.reset()
        sequence.reset() wrong=nil
        if tween then tween:Cancel() tween=nil end
        crate.CFrame=crateHome
        click:Stop() thud:Stop() glug:Stop()
        apply()
    end
    function controller.available(enabled: boolean)
        for _,name in names do
            local prompt=(map:FindFirstChild(name) :: BasePart):FindFirstChildOfClass("ProximityPrompt") :: ProximityPrompt
            prompt.Enabled=enabled
        end
    end
    function controller.use(name: string): (boolean,string)
        if name=="CellarFuseBox" then
            if not sequence.pullMain() then
                click.PlaybackSpeed=0.45 click:Play()
                return false,"The main supply is not ready. "..Power.Instructions
            end
            wrong=nil apply()
            return true,"The lights are back on. Something is waking up."
        end
        local circuit: string?=nil
        for _,id in circuits do if name=="CellarBreaker"..id then circuit=id break end end
        if not circuit then return false,"Unknown circuit." end
        if sequence.powered() then return false,"The lights are already restored." end
        local accepted=sequence.press(circuit)
        wrong=if accepted then nil else name
        click.PlaybackSpeed=if accepted then 0.9 else 0.45 click:Play()
        apply()
        if not accepted then
            if tween then tween:Cancel() tween=nil end
            crate.CFrame=crateHome thud:Stop() glug:Stop()
            return false,"Wrong circuit. Sequence reset. Cellar first; guest rooms before the bar."
        end
        local progress=sequence.progress()
        if progress==1 then return false,"Cellar circuit set. A light comes on behind the barrels."
        elseif progress==2 then
            thud:Play()
            if tween then tween:Cancel() end
            crate.CFrame=crateHome*CFrame.Angles(0,0,0.045)
            tween=TweenService:Create(crate,TweenInfo.new(0.5,Enum.EasingStyle.Bounce),{CFrame=crateHome}) tween:Play()
            return false,"Guest rooms circuit set. Something shifted behind the racks."
        end
        glug:Play()
        return false,"Bar circuit set. GLUG… The main lever is ready."
    end
    controller.reset()
    return controller
end
return Power
