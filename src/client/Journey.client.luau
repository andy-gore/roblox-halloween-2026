--!strict
-- Short entrance reaction and car escape presentation; the server owns progression.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
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
local previousType: Enum.CameraType?=nil
local previousSubject: Instance?=nil
local previousFrame=CFrame.identity
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
    card.Visible=stage==7
    if not entry and not driving then restore() fade.BackgroundTransparency=1 return end
    if not previousType then previousType,previousSubject,previousFrame=camera.CameraType,camera.CameraSubject,camera.CFrame end
    camera.CameraType=Enum.CameraType.Scriptable
    if entry then
        camera.CFrame=CFrame.lookAt(Vector3.new(6,7,78),Vector3.new(6,6,88))
    else
        local map=workspace:FindFirstChild("LastOrdersPrototype")
        -- Locate by model name so the camera also follows a translated test fixture.
        local car=workspace:FindFirstChild("BrokenDownCar",true)
        if car and car:IsA("Model") then
            local cf=car:GetPivot()
            camera.CFrame=CFrame.lookAt((cf*CFrame.new(-15,8,-12)).Position,cf.Position+Vector3.new(0,2,0))
        end
        fade.BackgroundTransparency=if stage==7 then 0 else 1
    end
end)
script.Destroying:Connect(function() RunService:UnbindFromRenderStep("LastOrdersJourney") restore() gui:Destroy() end)
