--!strict
-- CLIENT Play Command Bar. Local presentation fixtures only; restores replicated inputs.
local map=workspace:WaitForChild("LastOrdersPrototype")
local view=workspace:WaitForChild("OriginalAssetVisuals")
local Config=require(game.ReplicatedStorage.HalloweenShared.Config)
local deadline=os.clock()+30
while view:GetAttribute("Rendering")=="Loading" and os.clock()<deadline do task.wait(0.1) end
assert(view:GetAttribute("Rendering")=="OriginalMeshes",tostring(view:GetAttribute("LastError")))
assert(view:GetAttribute("LoadedPlacements")==164 and view:GetAttribute("FailedAssets")==0)
local key,panel,bell,door=map.OfficeKey,map.CellarPowerPanel,map.Bell,map.ExitDoor
local keyCF,keyAlpha,powered,ready,doorAlpha=key.CFrame,key.Transparency,panel:GetAttribute("Powered"),bell:GetAttribute("ReadyAt"),door.Transparency
local marker
for _,m in map.AssetPlacements:GetChildren() do if m:GetAttribute("CobwebCandidate") and m:GetAttribute("Enabled") then marker=m break end end
assert(marker)
local oldEnabled=marker:GetAttribute("Enabled")
local ok,err=pcall(function()
    for _,p in view:GetChildren() do
        assert(p:IsA("MeshPart") and p.Anchored and not p.CanCollide and not p.CanTouch and not p.CanQuery)
        for _,n in {p.CFrame:GetComponents()} do assert(n==n and math.abs(n)<10000) end
    end
    local mesh=view.ExitKey_Static :: BasePart
    key.Transparency=0 task.wait(.12) assert(mesh.Transparency==0)
    key.CFrame=keyCF+Vector3.new(12,0,0) task.wait(.12)
    assert((mesh.Position-key.Position).Magnitude<.3,"Original key must follow actual random placement")
    key.Transparency=1 task.wait(.12) assert(mesh.Transparency==1)
    panel:SetAttribute("Powered",false) task.wait(.12)
    local before=view.CellarFuseBox_Switch.Position
    panel:SetAttribute("Powered",true) task.wait(.12)
    assert((view.CellarFuseBox_Switch.Position-before).Magnitude>.5,"Original lever must move with power state")
    assert(view.CellarFuseBox_Indicator.Material==Enum.Material.Neon)
    panel:SetAttribute("Powered",false) task.wait(.12)
    assert(view.CellarFuseBox_Indicator.Material==Enum.Material.SmoothPlastic)
    bell:SetAttribute("ReadyAt",0) task.wait(.12)
    local unpressed=view.ServiceBell_Press.Position
    bell:SetAttribute("ReadyAt",workspace:GetServerTimeNow()+Config.BellCooldownSeconds) task.wait(.05)
    assert(view.ServiceBell_Press.Position.Y<unpressed.Y-.02,"Successful ring must depress the plunger")
    task.wait(.35) assert((view.ServiceBell_Press.Position-unpressed).Magnitude<.005,"Bell must return")
    door.Transparency=0 task.wait(.12) assert(view.ExitDoorLock_Static.Transparency==0)
    door.Transparency=.8 task.wait(.12) assert(view.ExitDoorLock_Static.Transparency==1)
    marker:SetAttribute("Enabled",false) task.wait(.12)
    for _,p in view:GetChildren() do if p:GetAttribute("Placement")==marker.Name then assert(p.Transparency==1 and not p.CastShadow) end end
end)
key.CFrame,key.Transparency=keyCF,keyAlpha panel:SetAttribute("Powered",powered)
bell:SetAttribute("ReadyAt",ready) door.Transparency=doorAlpha marker:SetAttribute("Enabled",oldEnabled)
task.wait(.12)
assert(ok,tostring(err))
print("Original asset client: 164 placements, fixed-memory templates, key reveal/follow/hide, power lever/lens, bell press/return, exit fade and cosmetic webs passed")
