--!strict
-- Studio Edit server Command Bar. Use actual Humanoid/root and structural blockers.
local server=game.ServerScriptService.HalloweenServer
local folder=Instance.new("Folder") folder.Name="PlayerHoldTest" folder.Parent=workspace
local offset=Vector3.new(14000,0,0)
local function part(name: string,size: Vector3,position: Vector3,parent: Instance): Part
    local p=Instance.new("Part") p.Name,p.Size,p.Position=name,size,offset+position
    p.Anchored,p.Parent=true,parent return p
end
local ok,err=pcall(function()
    part("Floor",Vector3.new(30,1,30),Vector3.zero,folder)
    local monster=part("Monster",Vector3.new(4,8,4),Vector3.new(0,4.5,0),folder)
    local character=Instance.new("Model") character.Parent=folder
    local root=part("HumanoidRootPart",Vector3.new(2,2,1),Vector3.new(0,3.5,-5),character)
    local head=part("Head",Vector3.one,Vector3.new(0,5,-5),character) head.CanCollide=false
    local humanoid=Instance.new("Humanoid") humanoid.Parent=character
    humanoid.WalkSpeed,humanoid.JumpPower,humanoid.JumpHeight=19,47,6
    local now=0
    local hold=require(server.PlayerHold).new(monster,function() return now end)
    local original=root.CFrame
    hold.begin(character,root,humanoid)
    assert(root.Anchored and humanoid.WalkSpeed==0 and not root.CanCollide)
    assert(root.CFrame==original,"Grab must start with a reach, not an instant teleport")
    now=0.15 hold.step()
    assert((root.Position-original.Position).Magnitude>0.1,"Reach must move progressively into the grip")
    now=0.8 hold.step()
    local raised=root.Position.Y
    assert(raised>original.Position.Y+1,"Clear space should visibly lift the player")
    now=1.45 hold.step()
    assert(root.Position.Y<raised,"Release must visibly lower the player")
    now=require(game.ReplicatedStorage.HalloweenShared.Config).PlayerHoldSeconds hold.step()
    assert((root.Position-original.Position).Magnitude<0.01,"Lowering must end at the safe original position")
    assert(typeof(monster:GetAttribute("HeldChestPosition"))=="Vector3")
    hold.release()
    assert(root.CFrame==original and root.Anchored and root.CanCollide and not head.CanCollide)
    assert(humanoid.WalkSpeed==19 and humanoid.JumpPower==47 and humanoid.JumpHeight==6 and humanoid.AutoRotate)
    assert(root.AssemblyLinearVelocity==Vector3.zero and monster:GetAttribute("HeldChestPosition")==nil)
    hold.release()
    local wall=part("Obstacle",Vector3.new(2,8,2),Vector3.new(-1.6,4.5,-2.2),folder)
    hold.begin(character,root,humanoid)
    now+=0.8 hold.step()
    assert(root.CFrame==original,"Blocked grip must keep the player safe in place")
    hold.release()
    wall:Destroy()
    hold.begin(character,root,humanoid,true)
    now+=3 hold.step()
    assert(root.Position.Y>original.Position.Y+1 and root.Anchored,"Fatal hold must retain the grip until reset")
    hold.release()
    hold.begin(character,root,humanoid)
    character:Destroy()
    hold.release()
end)
folder:Destroy()
assert(ok,tostring(err))
print("Holding: safe lift, original release position/state, collision restoration, obstruction and destroyed-character cleanup passed")
