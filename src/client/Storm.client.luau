--!strict
-- Exterior ambience only. No player movement, objectives, NPC states or inventory changes.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local TweenService=game:GetService("TweenService")
local SoundService=game:GetService("SoundService")
local UserInputService=game:GetService("UserInputService")
if workspace:GetAttribute("LastOrdersGreybox")~=true then return end
local map=workspace:WaitForChild("LastOrdersPrototype")
local exterior=map:WaitForChild("Exterior")
local player=Players.LocalPlayer
local folder=Instance.new("Folder") folder.Name="LastOrdersStorm" folder.Parent=workspace
local rain=require(script.Parent.StormRain).new(folder,if UserInputService.TouchEnabled then 64 else 100)
local function audio(name: string,id: string,volume: number,pitch: number,looped: boolean): Sound
    local s=Instance.new("Sound") s.Name,s.SoundId=name,id
    s.Volume,s.PlaybackSpeed,s.Looped=volume,pitch,looped s.Parent=SoundService return s
end
-- Bundled water/impact clips provide local placeholder storm audio without uploads.
local rainSound=audio("LastOrdersRain","rbxasset://sounds/action_swim.mp3",0.04,0.7,true)
local thunder=audio("LastOrdersThunder","rbxasset://sounds/impact_explosion_03.mp3",0.12,0.45,false)
local eq=Instance.new("EqualizerSoundEffect") eq.HighGain,eq.MidGain,eq.LowGain=-20,-8,4 eq.Parent=thunder
rainSound:Play()
local flash=Instance.new("ColorCorrectionEffect") flash.Name="LastOrdersLightning" flash.Parent=game:GetService("Lighting")
local windowLightning=require(script.Parent.WindowLightning).new(map,folder)
local skyLightning=require(script.Parent.SkyLightning).new(folder)
local random=Random.new()
local nextThunder=os.clock()+random:NextNumber(6,11)
local inside=true
local accumulator,coverTime=0,0
local coverCast=RaycastParams.new() coverCast.FilterType=Enum.RaycastFilterType.Exclude
local sign=exterior:WaitForChild("PubFrontage"):WaitForChild("HangingPubSign") :: Model
local signPivot=sign:GetPivot()
local hazards: {BasePart}={}
local car=exterior:WaitForChild("BrokenDownCar")
for _,object in car:GetChildren() do
    if object:IsA("BasePart") and object.Name=="HazardLamp" then table.insert(hazards,object) end
end
local alive=true
local connection: RBXScriptConnection?=nil
connection=RunService.Heartbeat:Connect(function(dt: number)
    if not map:IsDescendantOf(workspace) then
        alive=false
        if connection then connection:Disconnect() end
        skyLightning.destroy() folder:Destroy() rainSound:Destroy() thunder:Destroy() flash:Destroy() return
    end
    local character=player.Character
    local root=if character then character:FindFirstChild("HumanoidRootPart") else nil
    if not root or not root:IsA("BasePart") then return end
    accumulator+=dt coverTime+=dt
    if coverTime>=0.5 then
        coverTime=0 coverCast.FilterDescendantsInstances={character,folder}
        inside=workspace:Raycast(root.Position+Vector3.new(0,1,0),Vector3.new(0,100,0),coverCast)~=nil
        rainSound.Volume=if inside then 0.035 else 0.16
    end
    if accumulator>=1/30 then
        rain.step(root.Position,character,accumulator) accumulator=0
        local t=workspace:GetServerTimeNow()
        sign:PivotTo(signPivot*CFrame.Angles(0,0,math.sin(t*1.1)*0.025))
        local on=car:GetAttribute("HazardsEnabled")==true and math.floor(t*1.3)%2==0
        for _,p in hazards do p.Material=if on then Enum.Material.Neon else Enum.Material.Glass p.Transparency=if on then 0 else 0.5 end
    end
    if os.clock()>=nextThunder then
        nextThunder=os.clock()+random:NextNumber(22,40)
        skyLightning.flash()
        windowLightning.flash()
        flash.Brightness=if inside then 0 else 0.09
        TweenService:Create(flash,TweenInfo.new(0.3),{Brightness=0}):Play()
        task.delay(random:NextNumber(0.8,1.7),function()
            if alive then thunder.Volume=if inside then 0.1 else 0.22 thunder:Play() end
        end)
    end
end)
