--!strict
-- Studio CLIENT Command Bar during Play. Checks the actual loaded mesh and pose invariants.
local client=game.Players.LocalPlayer.PlayerScripts:WaitForChild("HalloweenClient")
local view=workspace:WaitForChild("Chuggernaught",10)
assert(view,"Chuggernaught presentation must start")
local deadline=os.clock()+12
while view:GetAttribute("Rendering")=="Loading" and os.clock()<deadline do task.wait(0.1) end
assert(view:GetAttribute("Rendering")=="OriginalMesh","Original character mesh must load; inspect MeshError on fallback")
assert(view:GetAttribute("TriangleCount")==6449 and view:GetAttribute("BoneCount")==9)
local count=0
for _,part in view:GetChildren() do
    if part:IsA("BasePart") then
        count+=1
        assert(part:IsA("MeshPart") and part.Anchored and not part.CanCollide and not part.CanQuery)
    end
end
assert(count==1,"Use one skinned mesh to fit the client memory budget")
-- Metadata and offline pose maths alone do not prove the rendered skin is animated.
task.wait(0.1)
local skin=view:FindFirstChild("OriginalCharacterMesh") :: MeshPart
local liveBones: {[string]: Bone}={}
for _,bone in skin:GetChildren() do
    if bone:IsA("Bone") then liveBones[bone.Name]=bone end
end
local boneCount=0
for _ in liveBones do boneCount+=1 end
assert(boneCount==9,"The mesh needs nine named LIVE Bone instances, not just EditableMesh bind definitions")
assert(liveBones.Tankard and liveBones.LowerArmRight and liveBones.LegLeft)
local liveHand=liveBones.LowerArmRight.TransformedWorldCFrame:PointToWorldSpace(Vector3.new(0.05,-1.37,-0.09))
local liveGrip=liveBones.Tankard.TransformedWorldCFrame:PointToWorldSpace(Vector3.new(-1.35,1.13,0))
assert((liveHand-liveGrip).Magnitude<0.3,"Rendered tankard must actually be held, not left at the origin")
assert(liveBones.Tankard.Transform.Position.Magnitude>1,"Tankard needs a runtime pose")
local pose=require(client.ChuggernaughtPose)
for i=0,28 do
    local frames=pose.frames(CFrame.identity,i/4,true,"Chug",i/10,2.8)
    for _,cf in frames do
        for _,n in {cf:GetComponents()} do assert(n==n and math.abs(n)<10000,"Pose must remain finite") end
    end
    local hand=frames.LowerArmRight:PointToWorldSpace(Vector3.new(0.05,-1.37,-0.09))
    local grip=frames.Tankard:PointToWorldSpace(Vector3.new(-1.35,1.13,0))
    assert((hand-grip).Magnitude<0.3,"Tankard handle must stay within the fist")
end
print("Original character mesh, client collision isolation and tankard grip checks passed")
