--!strict
-- A bounded, gentle hint towards the awakening. Normal camera/input remain in control.
local RunService=game:GetService("RunService")
local Players=game:GetService("Players")
local Input=game:GetService("UserInputService")
if workspace:GetAttribute("LastOrdersGreybox")~=true then return end
local player=Players.LocalPlayer
local root=workspace:WaitForChild("LastOrdersPrototype"):WaitForChild("ChuggernaughtPlaceholder") :: BasePart
local seen: number?=nil
local untilTime,budget=0,0
local connections: {RBXScriptConnection}={}
local function cancel() untilTime=0 end
-- Deliberate looking cancels the hint; walking does not lock or fight the view.
table.insert(connections,Input.InputChanged:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseMovement and input.Delta.Magnitude>2 then cancel()
    elseif input.KeyCode==Enum.KeyCode.Thumbstick2 and input.Position.Magnitude>.15 then cancel() end
end))
table.insert(connections,Input.TouchMoved:Connect(cancel))
table.insert(connections,player.CharacterRemoving:Connect(cancel))
RunService:BindToRenderStep("LastOrdersCellarReveal",Enum.RenderPriority.Camera.Value+1,function(dt)
    if not root:IsDescendantOf(workspace) then cancel() return end
    local started=root:GetAttribute("MonsterModeStarted")
    local mode=root:GetAttribute("MonsterMode")
    if mode~="Reveal" then cancel() return end
    if typeof(started)=="number" and started~=seen then
        seen=started untilTime=os.clock()+1.3 budget=math.rad(65)
    end
    local camera=workspace.CurrentCamera
    local character=player.Character
    local playerRoot=if character then character:FindFirstChild("HumanoidRootPart") else nil
    if os.clock()>=untilTime or budget<=0 or not camera or camera.CameraType~=Enum.CameraType.Custom
        or not playerRoot or not playerRoot:IsA("BasePart") or playerRoot.Position.Y>=-6
        or (playerRoot.Position-root.Position).Magnitude>=80 then return end
    local cf=camera.CFrame
    local delta=root.Position+Vector3.new(0,2,0)-cf.Position
    if delta.Magnitude<.1 then return end
    local angle=math.acos(math.clamp(cf.LookVector:Dot(delta.Unit),-1,1))
    if angle<.01 then return end
    local remaining=untilTime-os.clock()
    local rate=math.rad(55)*math.clamp(remaining/.35,0,1)
    local turn=math.min(angle,math.min(dt,.05)*rate,budget)
    camera.CFrame=cf:Lerp(CFrame.lookAt(cf.Position,cf.Position+delta),turn/angle)
    budget-=turn
end)
script.Destroying:Connect(function()
    RunService:UnbindFromRenderStep("LastOrdersCellarReveal")
    for _,c in connections do c:Disconnect() end
end)
