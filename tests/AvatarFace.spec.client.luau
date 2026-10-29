--!strict
-- Studio Client Command Bar: test local visual repair without changing the real avatar.
local Visual=require(game.Players.LocalPlayer.PlayerScripts.HalloweenClient.AvatarFaceVisual)
local model=Instance.new("Model")
local head=Instance.new("Part")
head.Name="Head" head.Transparency=0.2 head.Parent=model
local face=Instance.new("Decal")
face.Face=Enum.NormalId.Front face.Transparency=0.3 face.Parent=head
model.Parent=workspace
local visual=Visual.new(model,head)
local ok,err=pcall(function()
    assert(not model:FindFirstChild("UnavailableHeadFallback"))
    visual.show(true)
    local fallback=model:FindFirstChild("UnavailableHeadFallback") :: Part
    assert(fallback and not fallback.CanCollide and not fallback.CanQuery)
    assert(head.Transparency==1 and fallback:FindFirstChild("LocalClassicFace"))
    head.CFrame=CFrame.new(10,20,30) head.LocalTransparencyModifier=1
    visual.update()
    assert(fallback.CFrame==head.CFrame and fallback.LocalTransparencyModifier==1)
    visual.clear()
    assert(math.abs(head.Transparency-0.2)<0.001 and not model:FindFirstChild("UnavailableHeadFallback"))
    visual.show(false)
    assert(face.Transparency==1 and head:FindFirstChild("LocalClassicFace"))
    visual.clear()
    assert(math.abs(face.Transparency-0.3)<0.001 and not head:FindFirstChild("LocalClassicFace"))
end)
visual.clear() model:Destroy()
assert(ok,err)
return "Avatar face visual repair passed"
