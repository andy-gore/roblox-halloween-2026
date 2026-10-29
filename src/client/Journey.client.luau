--!strict
-- Short entrance reaction and car escape presentation; the server owns progression.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local Input=game:GetService("UserInputService")
local Config=require(game.ReplicatedStorage:WaitForChild("HalloweenShared"):WaitForChild("Config"))
if workspace:GetAttribute("LastOrdersGreybox")~=true then return end
local player=Players.LocalPlayer
local gui=Instance.new("ScreenGui") gui.Name,gui.ResetOnSpawn,gui.DisplayOrder="LastOrdersJourney",false,30
local fade=Instance.new("Frame") fade.Size,fade.BackgroundColor3,fade.BackgroundTransparency=UDim2.fromScale(1,1),Color3.new(),1
fade.Parent=gui
local UI=require(script.Parent.TavernUI)
local card=UI.ending(fade,false) card.Visible=false
local replay=Instance.new("TextButton") replay.Name="Replay"
replay.Size,replay.Text,replay.FontFace,replay.TextSize=UDim2.new(1,0,0,52),"Play again",UI.Body,20
replay.BackgroundColor3,replay.TextColor3,replay.AutoButtonColor=Color3.fromRGB(70,48,35),UI.Ivory,true
replay.BorderSizePixel,replay.LayoutOrder,replay.Parent=0,6,card
local corner=Instance.new("UICorner") corner.CornerRadius,corner.Parent=UDim.new(0,4),replay
local stroke=Instance.new("UIStroke") stroke.Color,stroke.Transparency,stroke.Parent=UI.Brass,.4,replay
gui.Parent=player:WaitForChild("PlayerGui")
replay.Activated:Connect(function() game.ReplicatedStorage.HalloweenShared:WaitForChild("RestartJourney"):FireServer() end)
local function faceEntrance()
    task.defer(function()
        local character=player.Character
        if not character then return end
        local root=character:WaitForChild("HumanoidRootPart",10)
        task.wait(.2)
        if not root or character~=player.Character or player:GetAttribute("LastOrdersStage")~=0 then return end
        local camera=workspace.CurrentCamera
        if camera then
            local direction=Vector3.new(6-root.Position.X,0,88-root.Position.Z).Unit
            camera.CFrame=CFrame.lookAt(root.Position-direction*10+Vector3.new(0,4,0),root.Position+direction*12)
        end
    end)
end
player.CharacterAdded:Connect(faceEntrance)
player:GetAttributeChangedSignal("LastOrdersStage"):Connect(function() if player:GetAttribute("LastOrdersStage")==0 then faceEntrance() end end)
faceEntrance()
local bars={}
for _,y in {0,.93} do
    local bar=Instance.new("Frame") bar.Name="CinemaBar" bar.Position,bar.Size=UDim2.fromScale(0,y),UDim2.fromScale(1,.07)
    bar.BackgroundColor3,bar.BorderSizePixel,bar.Visible,bar.Parent=Color3.new(),0,false,gui table.insert(bars,bar)
end
local caption=Instance.new("TextLabel") caption.Name="SceneCaption"
caption.Size,caption.Position=UDim2.fromScale(.86,.12),UDim2.fromScale(.07,.78)
caption.BackgroundTransparency,caption.FontFace,caption.TextSize,caption.TextWrapped=1,UI.Body,21,true
caption.TextColor3,caption.TextStrokeTransparency,caption.Visible,caption.Parent=UI.Ivory,.25,false,gui
local skip=Instance.new("TextButton") skip.Name="SkipArrival" skip.Text="Skip intro  ·  Space / B"
skip.Size,skip.Position=UDim2.fromOffset(220,44),UDim2.new(1,-236,0,16)
skip.BackgroundColor3,skip.TextColor3,skip.FontFace,skip.TextSize=UI.Ink,UI.Ivory,UI.Body,17
skip.Visible,skip.Parent=false,gui
local function skipIntro()
    if player:GetAttribute("LastOrdersArrivalScene")==true then game.ReplicatedStorage.HalloweenShared:WaitForChild("SkipArrival"):FireServer() end
end
skip.Activated:Connect(skipIntro)
local skipInput=Input.InputBegan:Connect(function(input,processed)
    if not processed and (input.KeyCode==Enum.KeyCode.Space or input.KeyCode==Enum.KeyCode.ButtonB) then skipIntro() end
end)
local previousType: Enum.CameraType?=nil
local previousSubject: Instance?=nil
local previousFrame=CFrame.identity
local lastScene=""
local sceneAt=0
local function restore()
    local camera=workspace.CurrentCamera
    if camera and previousType then
        camera.CameraType=previousType camera.CameraSubject=previousSubject camera.CFrame=previousFrame
    end
    previousType=nil
end
RunService:BindToRenderStep("LastOrdersJourney",Enum.RenderPriority.Camera.Value+2,function()
    local camera=workspace.CurrentCamera
    if not camera then return end
    local entry=player:GetAttribute("LastOrdersEntryScene")==true
    local driving=player:GetAttribute("LastOrdersDriving")==true
    local stage=player:GetAttribute("LastOrdersStage")
    local arrival=player:GetAttribute("LastOrdersArrivalScene")==true
    card.Visible=stage==7
    local scene=if arrival then "Arrival" elseif entry then "Entry" elseif driving then "Drive" else ""
    if scene~=lastScene then sceneAt=os.clock() lastScene=scene end
    skip.Visible=arrival
    caption.Visible=scene~="" and stage~=7
    for _,bar in bars do bar.Visible=caption.Visible end
    if scene=="" then restore() fade.BackgroundTransparency=1 return end
    if not previousType then previousType,previousSubject,previousFrame=camera.CameraType,camera.CameraSubject,camera.CFrame end
    camera.CameraType=Enum.CameraType.Scriptable
    if arrival then
        local started=player:GetAttribute("LastOrdersArrivalStarted")
        local elapsed=if typeof(started)=="number" then workspace:GetServerTimeNow()-started else os.clock()-sceneAt
        local t=math.clamp(elapsed/4,0,1)
        local signView=CFrame.lookAt(Vector3.new(-8,12,110),Vector3.new(-.5,11,100))
        local entranceView=CFrame.lookAt(Vector3.new(-24,13,115),Vector3.new(6,12,89))
        camera.CFrame=signView:Lerp(entranceView,t*t*(3-2*t))
        caption.Text="The Firefly Tavern. Halloween night.\nOne dare: get the lights working."
    elseif entry then
        local map=workspace:FindFirstChild("LastOrdersPrototype")
        local started=if map then map:GetAttribute("EntranceCollapseStarted") else nil
        local elapsed=if typeof(started)=="number" then workspace:GetServerTimeNow()-started else os.clock()-sceneAt
        local t=math.clamp(elapsed/Config.EntrySceneSeconds,0,1)
        camera.CFrame=previousFrame:Lerp(CFrame.lookAt(previousFrame.Position,Vector3.new(6,5,88)),math.sin(t*math.pi)^2*.8)
        caption.Text="The entrance is blocked. Find another way out."
    else
        -- Locate by model name so the camera also follows a translated test fixture.
        local car=workspace:FindFirstChild("BrokenDownCar",true)
        if car and car:IsA("Model") then
            local cf=car:GetPivot()
            local elapsed=os.clock()-sceneAt
            local boardView=CFrame.lookAt((cf*CFrame.new(-5,4,-9)).Position,cf.Position+Vector3.new(0,2,0))
            local escapeView=CFrame.lookAt((cf*CFrame.new(-15,8,-12)).Position,cf.Position+Vector3.new(0,2,0))
            local blend=math.clamp((elapsed-.4)/1.2,0,1)
            camera.CFrame=boardView:Lerp(escapeView,blend*blend*(3-2*blend))
            caption.Text="Go. Just go."
            fade.BackgroundTransparency=if stage==7 then 0 else math.clamp((Config.DriveSeconds-elapsed)/.8,0,1)
            if stage~=7 and elapsed<.35 then fade.BackgroundTransparency=math.clamp(elapsed/.35,0,1) end
        end
        if stage==7 then fade.BackgroundTransparency=0 end
    end
end)
script.Destroying:Connect(function() skipInput:Disconnect() RunService:UnbindFromRenderStep("LastOrdersJourney") restore() gui:Destroy() end)
