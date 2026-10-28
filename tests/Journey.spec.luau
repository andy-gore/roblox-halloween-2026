local modules=game.ServerScriptService.HalloweenServer:Clone()
modules.Name='JourneyReview' modules.Main.Enabled=false
local cfg=game.ReplicatedStorage.HalloweenShared.Config:Clone() cfg.Name='ReviewConfig' cfg.Parent=modules
for _,s in modules:GetDescendants() do if s:IsA('ModuleScript') and s~=cfg then s.Source=s.Source:gsub('require%(game.ReplicatedStorage:WaitForChild%("HalloweenShared"%):WaitForChild%("Config"%)%)','require(script.Parent.ReviewConfig)') end end
modules.Parent=game.ServerScriptService
local m=require(modules.PrototypeMap).build()
local ok,err=pcall(function()
local t=0 local j=require(modules.Journey).new(m,function() return t end)
assert(not j.crossed(Vector3.new(6,3,84))) j.openEntrance()
assert(not j.crossed(Vector3.new(6,3,90))) assert(j.crossed(Vector3.new(6,3,84)))
j.collapse() assert(m.FrontEntranceBlocker.CanCollide) j.reset() assert(not m.FrontEntranceBlocker.CanCollide)
local n=require(modules.MonsterNavigation).new(m.ChuggernaughtPlaceholder) n.validate() j.openExit() n.refresh() n.validate()
local monster=m.ChuggernaughtPlaceholder monster.CFrame=CFrame.new(-36,4.5,34)
for _,point in {Vector3.new(-36,.5,61),Vector3.new(-26,.5,80),Vector3.new(-46,.5,80),Vector3.new(-46,.5,101)} do
    for i=1,150 do n.step(point,20,.1) end
    assert((monster.Position-(point+Vector3.new(0,4,0))).Magnitude<.2,'Outside traversal failed')
end
local rig=Instance.new('Model') local r=Instance.new('Part') r.Name='HumanoidRootPart' r.Parent=rig local h=Instance.new('Humanoid') h.Parent=rig rig.Parent=workspace
local orig=r.CFrame local car=m.Exterior.BrokenDownCar local parked=car:GetPivot()
j.beginDrive(rig,r,h) assert(r.Anchored) t=5 assert(j.stepDrive()) assert((car:GetPivot().Position-parked.Position).Magnitude>200)
j.reset() assert(not r.Anchored) assert((r.Position-orig.Position).Magnitude<.01) assert((car:GetPivot().Position-parked.Position).Magnitude<.01)
rig:Destroy()
end)
m:Destroy() modules:Destroy() assert(ok,err)
return 'threshold, closed/open routes, drive and reset passed'
