--!strict
-- A single look towards the wake-up avoids a reveal behind the panel-facing camera.
-- Keep normal camera type, movement and look controls; no cutscene lock or camera takeover.
local RunService=game:GetService("RunService")
local Players=game:GetService("Players")
if workspace:GetAttribute("LastOrdersGreybox")~=true then return end
local root=workspace:WaitForChild("LastOrdersPrototype"):WaitForChild("ChuggernaughtPlaceholder") :: BasePart
local seen: number?=nil
RunService:BindToRenderStep("LastOrdersCellarReveal",Enum.RenderPriority.Camera.Value+1,function()
    if not root:IsDescendantOf(workspace) then RunService:UnbindFromRenderStep("LastOrdersCellarReveal") return end
    local started=root:GetAttribute("MonsterModeStarted")
    if root:GetAttribute("MonsterMode")~="Reveal" or typeof(started)~="number" or started==seen then return end
    seen=started
    local character=Players.LocalPlayer.Character
    local playerRoot=if character then character:FindFirstChild("HumanoidRootPart") else nil
    local camera=workspace.CurrentCamera
    if workspace:GetServerTimeNow()-started<1 and camera and camera.CameraType==Enum.CameraType.Custom and playerRoot and playerRoot:IsA("BasePart")
        and playerRoot.Position.Y < -6 and (playerRoot.Position-root.Position).Magnitude<80 then
        camera.CFrame=CFrame.lookAt(camera.CFrame.Position,root.Position+Vector3.new(0,2,0))
    end
end)
