--!strict
-- Only use the bundled face when the avatar's original head/face content actually fails.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local ContentProvider=game:GetService("ContentProvider")
if workspace:GetAttribute("LastOrdersGreybox")~=true then return end
local player=Players.LocalPlayer
local Visual=require(script.Parent.AvatarFaceVisual)
local generation=0
local connections: {RBXScriptConnection}={}
local assetConnections: {RBXScriptConnection}={}
local visual: any=nil
local function clear()
    generation+=1
    for _,c in connections do c:Disconnect() end connections={}
    for _,c in assetConnections do c:Disconnect() end assetConnections={}
    if visual then visual.clear() visual=nil end
end
local function attach(character: Model)
    clear() local token=generation
    local head=character:WaitForChild("Head",10)
    if not head or not head:IsA("BasePart") or character~=player.Character or token~=generation then return end
    visual=Visual.new(character,head)
    local revision=0
    local function watch()
        revision+=1 local currentRevision=revision
        for _,c in assetConnections do c:Disconnect() end assetConnections={}
        local meshId=""
        if head:IsA("MeshPart") then meshId=head.MeshId
        else local mesh=head:FindFirstChildOfClass("SpecialMesh") if mesh and mesh.MeshType==Enum.MeshType.FileMesh then meshId=mesh.MeshId end end
        local faceIds: {string}={}
        for _,face in head:GetChildren() do
            if face:IsA("Decal") and face.Face==Enum.NormalId.Front and face.Name~="LocalClassicFace" and face.Texture~="" then table.insert(faceIds,face.Texture) end
        end
        local ids=table.clone(faceIds) if meshId~="" then table.insert(ids,meshId) end
        local function failed(id: string): boolean
            local ok,status=pcall(function() return ContentProvider:GetAssetFetchStatus(id) end)
            return ok and (status.Name=="Failure" or status.Name=="TimedOut")
        end
        local function check()
            if currentRevision~=revision or token~=generation or not visual or character~=player.Character then return end
            if meshId~="" and failed(meshId) then visual.show(true) return end
            for _,id in faceIds do if failed(id) then visual.show(false) return end end
            visual.clear()
        end
        for _,id in ids do table.insert(assetConnections,ContentProvider:GetAssetFetchStatusChangedSignal(id):Connect(check)) end
        check()
        if #ids>0 then task.spawn(function() pcall(function() ContentProvider:PreloadAsync(ids) end) check() end) end
    end
    if head:IsA("MeshPart") then table.insert(connections,head:GetPropertyChangedSignal("MeshId"):Connect(watch)) end
    table.insert(connections,head.ChildAdded:Connect(function(child) if child:IsA("Decal") and child.Name~="LocalClassicFace" then watch() end end))
    table.insert(connections,head.AncestryChanged:Connect(function() if not head:IsDescendantOf(character) then clear() end end))
    watch()
end
local added=player.CharacterAdded:Connect(attach)
local removed=player.CharacterRemoving:Connect(clear)
RunService:BindToRenderStep("LastOrdersAvatarFace",Enum.RenderPriority.Camera.Value+15,function() if visual then visual.update() end end)
if player.Character then task.spawn(attach,player.Character) end
script.Destroying:Connect(function() added:Disconnect() removed:Disconnect() clear() RunService:UnbindFromRenderStep("LastOrdersAvatarFace") end)
