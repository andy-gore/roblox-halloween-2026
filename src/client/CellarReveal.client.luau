--!strict
-- Deliberate, collision-checked reveal; fade masks the cut instead of spinning the player.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local TweenService=game:GetService("TweenService")
if workspace:GetAttribute("LastOrdersGreybox")~=true then return end
local player=Players.LocalPlayer
local monster=workspace:WaitForChild("LastOrdersPrototype"):WaitForChild("ChuggernaughtPlaceholder") :: BasePart
local gui=Instance.new("ScreenGui") gui.Name,gui.ResetOnSpawn,gui.DisplayOrder="AwakeningView",false,25
local fade=Instance.new("Frame") fade.Name,fade.Size,fade.BackgroundColor3,fade.BorderSizePixel="Fade",UDim2.fromScale(1,1),Color3.new(),0
fade.BackgroundTransparency,fade.Parent=1,gui gui.Parent=player:WaitForChild("PlayerGui")
local saved: CFrame?=nil
local subject: Instance?=nil
local eye=Vector3.zero
local tween: Tween?=nil
local function restore()
    if not saved then return end
    local camera=workspace.CurrentCamera
    if camera then
        local character=player.Character
        local live=if character then character:FindFirstChildOfClass("Humanoid") else nil
        camera.CFrame=saved camera.CameraSubject=live or subject camera.CameraType=Enum.CameraType.Custom
    end
    saved=nil
    if tween then tween:Cancel() end
    fade.BackgroundTransparency=0
    tween=TweenService:Create(fade,TweenInfo.new(.2),{BackgroundTransparency=1}) tween:Play()
end
RunService:BindToRenderStep("LastOrdersCellarReveal",Enum.RenderPriority.Camera.Value+1,function()
    local camera=workspace.CurrentCamera
    if not camera then return end
    if player:GetAttribute("LastOrdersRevealScene")~=true or not monster:IsDescendantOf(workspace) then restore() return end
    if not saved then
        saved,subject=camera.CFrame,camera.CameraSubject
        local focus=monster.Position+Vector3.new(0,1.5,0)
        local desired=monster.Position+monster.CFrame.LookVector*12+monster.CFrame.RightVector*4+Vector3.new(0,2.5,0)
        local cast=RaycastParams.new() cast.FilterType=Enum.RaycastFilterType.Exclude
        cast.FilterDescendantsInstances=if player.Character then {player.Character,monster} else {monster}
        local hit=workspace:Blockcast(CFrame.new(focus),Vector3.one*.6,desired-focus,cast)
        eye=if hit then hit.Position+hit.Normal*.6 else desired
        if (eye-focus).Magnitude<5 then eye=monster.Position+Vector3.new(-8,2,5) end
    end
    camera.CameraType=Enum.CameraType.Scriptable
    local started=player:GetAttribute("LastOrdersSceneStarted")
    local duration=player:GetAttribute("LastOrdersSceneDuration")
    local elapsed=if typeof(started)=="number" then workspace:GetServerTimeNow()-started else 0
    local seconds=if typeof(duration)=="number" then duration else 4.5
    fade.BackgroundTransparency=math.min(math.clamp(elapsed/.2,0,1),math.clamp((seconds-elapsed)/.2,0,1))
    camera.CFrame=CFrame.lookAt(eye,monster.Position+Vector3.new(0,1.5,0))
end)
script.Destroying:Connect(function() restore() RunService:UnbindFromRenderStep("LastOrdersCellarReveal") gui:Destroy() end)
