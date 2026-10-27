--!strict
local RunService=game:GetService("RunService")
local Players=game:GetService("Players")
if workspace:GetAttribute("LastOrdersGreybox")~=true then return end
local root=workspace:WaitForChild("LastOrdersPrototype"):WaitForChild("ChuggernaughtPlaceholder") :: BasePart
local Config=require(game.ReplicatedStorage:WaitForChild("HalloweenShared"):WaitForChild("Config"))
local rig=require(script.Parent.ChuggernaughtRig).new()
local Pose=require(script.Parent.ChuggernaughtPose)
local function sound(name: string,path: string,volume: number,pitch: number): Sound
    local s=Instance.new("Sound") s.Name,s.SoundId=name,path
    s.Volume,s.PlaybackSpeed,s.RollOffMaxDistance,s.RollOffMinDistance=volume,pitch,65,7
    s.Parent=root return s
end
-- Bundled Roblox sounds verified locally; no uploaded sound IDs or invented voice assets.
local stepSound=sound("HeavyFootsteps","rbxasset://sounds/action_footsteps_plastic.mp3",0.65,0.62)
local drinkSound=sound("TankardGlug","rbxasset://sounds/impact_water.mp3",0.35,0.65)
local caption=Instance.new("BillboardGui")
caption.Name,caption.Size,caption.StudsOffsetWorldSpace="ChuggernaughtCaption",UDim2.fromOffset(260,50),Vector3.new(0,5.1,0)
caption.MaxDistance,caption.Adornee,caption.Parent=70,root,rig.model
local text=Instance.new("TextLabel")
text.Size,text.BackgroundTransparency=UDim2.fromScale(1,1),1
text.TextColor3,text.TextStrokeTransparency=Color3.fromRGB(255,224,170),0.15
text.Font,text.TextScaled,text.Parent=Enum.Font.GothamBold,true,caption
local displayed=root.Position
local last=displayed
local facing=Vector3.new(0,0,1)
local phase,lastStep,lastGlug=0,-1,-1
local previousMode=""
local connection: RBXScriptConnection? = nil
connection=RunService.RenderStepped:Connect(function(dt: number)
    if not root:IsDescendantOf(workspace) then
        if connection then connection:Disconnect() end
        rig.destroy() stepSound:Destroy() drinkSound:Destroy() return
    end
    local mode=root:GetAttribute("MonsterMode")
    if typeof(mode)~="string" then mode="Dormant" end
    local started=root:GetAttribute("MonsterModeStarted")
    local elapsed=if typeof(started)=="number" then math.max(0,workspace:GetServerTimeNow()-started) else 0
    if mode~=previousMode then
        lastGlug=-1 previousMode=mode
        if mode=="Dormant" then phase,lastStep=0,-1 stepSound:Stop() drinkSound:Stop() end
    end
    local targetPosition=root.Position
    if (targetPosition-displayed).Magnitude>12 then displayed=targetPosition
    else displayed=displayed:Lerp(targetPosition,1-math.exp(-dt*20)) end
    local delta=displayed-last last=displayed
    local horizontal=Vector3.new(delta.X,0,delta.Z)
    local moving=horizontal.Magnitude>0.001 and horizontal.Magnitude<5
    if moving then
        facing=facing:Lerp(horizontal.Unit,math.clamp(dt*12,0,1))
        if facing.Magnitude<0.01 then facing=horizontal.Unit end
        phase+=horizontal.Magnitude*2
    elseif mode=="Reveal" then
        local character=Players.LocalPlayer.Character
        local playerRoot=if character then character:FindFirstChild("HumanoidRootPart") else nil
        if playerRoot and playerRoot:IsA("BasePart") then
            local look=playerRoot.Position-root.Position local flat=Vector3.new(look.X,0,look.Z)
            if flat.Magnitude>0.1 then facing=facing:Lerp(flat.Unit,math.clamp(dt*4,0,1)) end
        end
    end
    if facing.Magnitude<0.01 then facing=Vector3.zAxis end
    local feet=displayed-Vector3.new(0,4,0)
    local basis=CFrame.lookAt(feet,feet+facing.Unit)
    local duration=if mode=="Reveal" then Config.MonsterRevealSeconds else Config.MonsterChugSeconds
    local alpha=if mode=="Dormant" then 1 elseif mode=="Reveal" then 1-math.clamp(elapsed/0.35,0,1) else 0
    rig.pose(Pose.frames(basis,phase,moving,mode,elapsed,duration),alpha,basis)
    local beat=math.floor(phase/math.pi)
    if moving and beat~=lastStep and mode~="Dormant" then stepSound:Play() end
    lastStep=beat
    if mode=="Reveal" or mode=="Chug" then
        local glug=math.floor((elapsed-0.85)/0.5)
        if glug>=0 and glug<3 and glug~=lastGlug then drinkSound:Play() lastGlug=glug end
    end
    text.Text=if mode=="Reveal" then "GLUG. GLUG. GLUG." elseif mode=="Hunt" and elapsed<2 then "LAST ORDERS!" else ""
    caption.Enabled=text.Text~=""
end)
