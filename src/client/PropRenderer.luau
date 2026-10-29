--!strict
-- Original uploaded-free GLB geometry. Fixed-size templates are shared between repeated props.
local AssetService=game:GetService("AssetService")
local HttpService=game:GetService("HttpService")
local Shared=game.ReplicatedStorage:WaitForChild("HalloweenShared")
local Data=Shared:WaitForChild("PropMeshData")
local Renderer={}
local function vector(v: {number}): Vector3 return Vector3.new(v[1],v[2],v[3]) end
local function configure(p: BasePart,web: boolean)
    p.Anchored,p.CanCollide,p.CanTouch,p.CanQuery=true,false,false,false
    p.CastShadow=not web
end
function Renderer.new(map: Folder)
    local markers=map:WaitForChild("AssetPlacements")
    while not markers:GetAttribute("PlacementCount") do task.wait() end
    local model=Instance.new("Folder") model.Name="OriginalAssetVisuals" model.Parent=workspace
    model:SetAttribute("Rendering","Loading") model:SetAttribute("LoadedPlacements",0) model:SetAttribute("FailedAssets",0)
    local alive=true
    local fixedMeshes: {EditableMesh}={}
    local templates: {MeshPart}={}
    local dynamic: {any}={}
    local hidden: {[BasePart]: number}={}
    local function hide(p: BasePart)
        if hidden[p]==nil then hidden[p]=p.LocalTransparencyModifier end
        p.LocalTransparencyModifier=1
    end
    local function buildGroup(group: any,palette: any): MeshPart
        local mesh=AssetService:CreateEditableMesh()
        assert(mesh,"Editable mesh memory unavailable")
        local fixed: EditableMesh?=nil
        local part: MeshPart?=nil
        local ok,err=pcall(function()
            local ids: {number},normalIds: {number}={},{}
            local positions: {[string]: number},normals: {[string]: number}={},{}
            local colorIds: {number}={}
            for _,rgb in palette do table.insert(colorIds,mesh:AddColor(Color3.new(table.unpack(rgb)),1)) end
            local uv=mesh:AddUV(Vector2.zero)
            for i=1,#group.positions,3 do
                local p,n=group.positions,group.normals
                local pk=string.format("%.6f,%.6f,%.6f",p[i],p[i+1],p[i+2])
                local nk=string.format("%.6f,%.6f,%.6f",n[i],n[i+1],n[i+2])
                if not positions[pk] then positions[pk]=mesh:AddVertex(Vector3.new(p[i],p[i+1],p[i+2])) end
                if not normals[nk] then normals[nk]=mesh:AddNormal(Vector3.new(n[i],n[i+1],n[i+2])) end
                table.insert(ids,positions[pk]) table.insert(normalIds,normals[nk])
            end
            for i=1,#group.faces,3 do
                local a,b,c=group.faces[i],group.faces[i+1],group.faces[i+2]
                local face=mesh:AddTriangle(ids[a],ids[b],ids[c])
                mesh:SetFaceNormals(face,{normalIds[a],normalIds[b],normalIds[c]})
                mesh:SetFaceColors(face,{colorIds[group.colors[a]],colorIds[group.colors[b]],colorIds[group.colors[c]]})
                mesh:SetFaceUVs(face,{uv,uv,uv})
                if i%6000==1 then task.wait() end
            end
            mesh:RemoveUnused()
            fixed=AssetService:CreateEditableMeshAsync(Content.fromObject(mesh),{FixedSize=true})
            assert(fixed,"Fixed-size mesh memory unavailable")
            mesh:Destroy()
            part=AssetService:CreateMeshPartAsync(Content.fromObject(fixed :: EditableMesh),{CollisionFidelity=Enum.CollisionFidelity.Box})
            local built=part :: MeshPart
            built.Name,built.Size,built.Color=group.name,vector(group.size),Color3.new(1,1,1)
            built.DoubleSided,built.Material=true,Enum.Material.SmoothPlastic
            built.Transparency=group.transparency or 0
            built.CastShadow=(group.transparency or 0)==0
        end)
        if not ok then
            pcall(function() mesh:Destroy() end)
            if fixed then fixed:Destroy() end
            if part then part:Destroy() end
            error(tostring(err))
        end
        assert(fixed and part)
        table.insert(fixedMeshes,fixed) table.insert(templates,part)
        return part
    end
    local function pose(entry: any)
        local marker=entry.marker :: BasePart
        if not marker:IsDescendantOf(map) then return end
        local target=entry.target :: BasePart?
        local mode=entry.mode :: string
        local origin=marker.CFrame
        if target and target:IsDescendantOf(map) and mode~="Power" then
            origin=target.CFrame*(marker:GetAttribute("FollowOffset") :: CFrame)
        end
        local visible=marker:GetAttribute("Enabled")~=false
        if mode=="Key" and target then
            visible=visible and target.Transparency<0.5
            hide(target)
            local fallback=target:FindFirstChild("BrassKey")
            if fallback then for _,p in fallback:GetDescendants() do if p:IsA("BasePart") then hide(p) end end end
        end
        if mode=="Door" and target and target.Transparency>0.5 then visible=false end
        for _,piece in entry.pieces do
            local data=piece.data
            local offset=CFrame.new(vector(data.center)*entry.scale)
            if mode=="Power" and data.name=="Switch" then
                local pivot=vector(data.pivot)*entry.scale
                local powered=target and target:GetAttribute("Powered")==true
                offset=CFrame.new(pivot)*CFrame.Angles(if powered then -math.pi else 0,0,0)*CFrame.new((vector(data.center)-vector(data.pivot))*entry.scale)
            elseif mode=="Power" and data.name=="Indicator" and target then
                local on=target:GetAttribute("Powered")==true
                piece.part.Color=if on then Color3.new(1,1,1) else Color3.new(0.18,0.18,0.18)
                piece.part.Material=if on then Enum.Material.Neon else Enum.Material.SmoothPlastic
            elseif mode=="Bell" and data.name=="Press" and target then
                local ready=target:GetAttribute("ReadyAt")
                local age=if typeof(ready)=="number" and ready>0 then workspace:GetServerTimeNow()-(ready-entry.cooldown) else math.huge
                local press=if age>=0 then 0.065*math.max(0,1-age/0.25) else 0
                offset=CFrame.new(0,-press,0)*offset
            end
            piece.part.CFrame=origin*offset
            piece.part.Transparency=if visible then piece.data.transparency or 0 else 1
        end
    end
    task.spawn(function()
        -- Reserve the established monster's mesh budget before loading optional scenery.
        for _=1,100 do
            local character=workspace:FindFirstChild("Chuggernaught")
            if character and character:GetAttribute("Rendering")~="Loading" then break end
            task.wait(0.1)
        end
        local byAsset: {[string]: {BasePart}}={}
        for _,marker in markers:GetChildren() do
            if marker:IsA("BasePart") and typeof(marker:GetAttribute("AssetName"))=="string" then
                local name=marker:GetAttribute("AssetName") :: string
                if not byAsset[name] then byAsset[name]={} end
                table.insert(byAsset[name],marker)
            end
        end
        local names={} for name in byAsset do table.insert(names,name) end
        -- Build large scratch meshes first; later small templates need less peak memory.
        table.sort(names,function(a,b)
            local left,right=#require(Data:WaitForChild(a)),#require(Data:WaitForChild(b))
            return if left==right then a<b else left>right
        end)
        local failures,loaded=0,0
        for _,name in names do
            if not alive then return end
            model:SetAttribute("BuildingAsset",name)
            local data=HttpService:JSONDecode(require(Data:WaitForChild(name)))
            local built={}
            local ok,err=pcall(function()
                for _,group in data.groups do table.insert(built,{template=buildGroup(group,data.palette),data=group}) end
            end)
            if ok then
                for _,marker in byAsset[name] do
                    local scale=marker:GetAttribute("AssetScale") :: Vector3
                    local targetValue=marker:FindFirstChild("Target") :: ObjectValue?
                    local target=if targetValue then targetValue.Value else nil
                    local entry={marker=marker,scale=scale,target=target,mode=marker:GetAttribute("Mode"),pieces={},cooldown=require(Shared.Config).BellCooldownSeconds}
                    for _,piece in built do
                        local part=piece.template:Clone() part.Name=name.."_"..piece.data.name
                        part.Size=vector(piece.data.size)*scale configure(part,marker:GetAttribute("CobwebCandidate")==true or (piece.data.transparency or 0)>0)
                        part:SetAttribute("SourceAsset",name) part:SetAttribute("Placement",marker.Name)
                        table.insert(entry.pieces,{part=part,data=piece.data})
                    end
                    pose(entry)
                    for _,piece in entry.pieces do piece.part.Parent=model end
                    for _,reference in marker:GetChildren() do
                        if reference:IsA("ObjectValue") and string.sub(reference.Name,1,11)=="Replacement" then
                            local old=reference.Value
                            if old and old:IsA("BasePart") then hide(old) end
                        end
                    end
                    if entry.mode~="Static" or marker:GetAttribute("CobwebCandidate") then table.insert(dynamic,entry) end
                    marker:SetAttribute("VisualLoaded",true)
                    loaded+=1 model:SetAttribute("LoadedPlacements",loaded)
                end
            else
                failures+=1 model:SetAttribute("FailedAssets",failures) model:SetAttribute("LastError",name..": "..tostring(err))
                warn("Original prop kept fallback for "..name..": "..tostring(err))
            end
            task.wait()
        end
        model:SetAttribute("Rendering",if failures==0 then "OriginalMeshes" else "PartialFallback")
        model:SetAttribute("FixedMeshCount",#fixedMeshes)
    end)
    local connection=game:GetService("RunService").Heartbeat:Connect(function()
        for _,entry in dynamic do pose(entry) end
    end)
    local controller={model=model}
    function controller.destroy()
        alive=false connection:Disconnect() model:Destroy()
        for p,old in hidden do if p.Parent then p.LocalTransparencyModifier=old end end
        for _,p in templates do p:Destroy() end
        for _,mesh in fixedMeshes do mesh:Destroy() end
    end
    map.Destroying:Once(controller.destroy)
    return controller
end
return Renderer
