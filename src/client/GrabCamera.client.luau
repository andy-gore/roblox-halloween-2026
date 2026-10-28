--!strict
-- Brief, collision-checked framing makes the hold visible; restore the player's view afterwards.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
if workspace:GetAttribute("LastOrdersGreybox")~=true then return end
local player=Players.LocalPlayer
local monster=workspace:WaitForChild("LastOrdersPrototype"):WaitForChild("ChuggernaughtPlaceholder") :: BasePart
local savedCamera: Camera?=nil
local savedFrame,savedFocus=CFrame.identity,CFrame.identity
local savedSubject: Instance?=nil
local started=0
local view=Vector3.zero
local visibility: {[BasePart]: number}={}
local characterReady=player.Character~=nil
local ray=RaycastParams.new() ray.FilterType,ray.RespectCanCollide=Enum.RaycastFilterType.Exclude,true
local function clearEye(focus: Vector3,eye: Vector3): Vector3
    local delta=eye-focus
    if delta.Magnitude<0.01 then return eye end
    local hit=workspace:Raycast(focus,delta,ray)
    return if hit then focus+delta.Unit*math.max(0.2,hit.Distance-0.9) else eye
end
local function restore()
    local camera=savedCamera
    savedCamera=nil
    for part,alpha in visibility do if part.Parent then part.LocalTransparencyModifier=alpha end end
    visibility={}
    if camera and camera.Parent then
        local character=player.Character
        local subject=if savedSubject and savedSubject:IsDescendantOf(workspace) then savedSubject else if character then character:FindFirstChildOfClass("Humanoid") else nil
        camera.CameraSubject=subject
        camera.CFrame,camera.Focus,camera.CameraType=savedFrame,savedFocus,Enum.CameraType.Custom
    end
end
RunService:BindToRenderStep("LastOrdersGrabCamera",Enum.RenderPriority.Camera.Value+10,function()
    if not monster:IsDescendantOf(workspace) then restore() RunService:UnbindFromRenderStep("LastOrdersGrabCamera") return end
    local character=player.Character
    local camera=workspace.CurrentCamera
    if savedCamera and camera~=savedCamera then restore() end
    local held=player:GetAttribute("LastOrdersHeld")==true and monster:GetAttribute("MonsterMode")=="Hold"
    if not held or not characterReady or not character or not camera then if savedCamera then restore() end return end
    ray.FilterDescendantsInstances={character,monster}
    local basis=CFrame.new(monster.Position-Vector3.new(0,4,0))*monster.CFrame.Rotation
    local focus=basis:PointToWorldSpace(Vector3.new(-0.8,4.7,-0.9))
    if not savedCamera then
        if camera.CameraType~=Enum.CameraType.Custom then return end
        savedCamera,savedFrame,savedFocus,savedSubject=camera,camera.CFrame,camera.Focus,camera.CameraSubject
        started=os.clock()
        local distance=-1
        for _,offset in {Vector3.new(-9,6.2,-11),Vector3.new(9,6.2,-11),Vector3.new(0,6.8,-14)} do
            local candidate=clearEye(focus,basis:PointToWorldSpace(offset))
            local length=(candidate-focus).Magnitude
            if length>distance then distance,view=length,candidate end
        end
        for _,part in character:GetDescendants() do
            if part:IsA("BasePart") then visibility[part]=part.LocalTransparencyModifier end
        end
        camera.CameraType=Enum.CameraType.Scriptable
    end
    local t=math.clamp((os.clock()-started)/0.2,0,1)
    local eye=clearEye(focus,savedFrame.Position:Lerp(view,t*t*(3-2*t)))
    -- Keep close first-person head geometry out of the lens while pulling back.
    for part in visibility do
        if part.Parent then part.LocalTransparencyModifier=if (part.Position-eye).Magnitude<1.5 then 1 else 0 end
    end
    camera.CFrame,camera.Focus=CFrame.lookAt(eye,focus),CFrame.new(focus)
end)
player.CharacterRemoving:Connect(function() characterReady=false restore() end)
player.CharacterAdded:Connect(function() characterReady=true end)
script.Destroying:Connect(function() restore() RunService:UnbindFromRenderStep("LastOrdersGrabCamera") end)
