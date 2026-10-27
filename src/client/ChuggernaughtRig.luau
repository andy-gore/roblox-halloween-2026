--!strict
-- Original GLB geometry in one client-only skinned mesh. No asset uploads.
local AssetService=game:GetService("AssetService")
local HttpService=game:GetService("HttpService")
local Shared=game:GetService("ReplicatedStorage"):WaitForChild("HalloweenShared")
local Rig={}
export type Group={name: string,center: {number},joint: {number},size: {number},color: number,
    positions: {number},normals: {number},faces: {number},colors: {number}}
local function vector(values: {number}): Vector3 return Vector3.new(values[1],values[2],values[3]) end
local function configure(part: BasePart)
    part.Anchored,part.CanCollide,part.CanTouch,part.CanQuery=true,false,false,false
    part.CastShadow=true
end
function Rig.new()
    local data=HttpService:JSONDecode(require(Shared:WaitForChild("ChuggernaughtMeshData")))
    local model=Instance.new("Model") model.Name="Chuggernaught" model:SetAttribute("Rendering","Loading")
    local fallback: {[string]: BasePart}={}
    local groups: {[string]: Group}={}
    local liveBones: {[string]: Bone}={}
    local editable: EditableMesh?=nil
    local skin: MeshPart?=nil
    local center=Vector3.zero
    local alive=true
    for _,group: Group in data.groups do
        groups[group.name]=group
        local part=Instance.new("Part") part.Name,part.Size=group.name,vector(group.size)
        part.Color=Color3.new(table.unpack(data.palette[group.color]))
        part.Material,part.Transparency=Enum.Material.SmoothPlastic,1
        configure(part) part.Parent=model fallback[group.name]=part
    end
    model.Parent=workspace
    local controller={model=model}
    function controller.pose(frames: {[string]: CFrame},transparency: number,feet: CFrame)
        local mesh,part=editable,skin
        if mesh and part then
            part.CFrame,part.Transparency=feet*CFrame.new(center),transparency
            -- Keep EditableMesh bind-pose data fixed during animation.
            -- Named Bone instances drive the visible skin through their Transform property.
            for name,bone in liveBones do
                bone.Transform=bone.CFrame:ToObjectSpace(part.CFrame:ToObjectSpace(frames[name]))
            end
        else
            for name,partFallback in fallback do
                local group=groups[name]
                partFallback.CFrame=frames[name]*CFrame.new(vector(group.center)-vector(group.joint))
                partFallback.Transparency=transparency
            end
        end
    end
    function controller.destroy()
        alive=false model:Destroy()
        if editable then editable:Destroy() editable=nil end
    end
    task.spawn(function()
        local part: MeshPart?=nil
        local ok,err=pcall(function()
            local lo,hi=Vector3.new(math.huge,math.huge,math.huge),Vector3.new(-math.huge,-math.huge,-math.huge)
            for _,group: Group in data.groups do
                local c,s=vector(group.center),vector(group.size)/2
                lo=lo:Min(c-s) hi=hi:Max(c+s)
            end
            center=(lo+hi)/2
            local mesh=AssetService:CreateEditableMesh()
            assert(mesh,"Local editable mesh budget exhausted") editable=mesh
            local colors: {number}={}
            for _,rgb in data.palette do table.insert(colors,mesh:AddColor(Color3.new(table.unpack(rgb)),1)) end
            local uv=mesh:AddUV(Vector2.zero)
            local normalCache: {[string]: number}={}
            for _,group: Group in data.groups do
                if not alive then return end
                model:SetAttribute("BuildingGroup",group.name)
                local bone=mesh:AddBone({Name=group.name,CFrame=CFrame.new(vector(group.joint)-center),Virtual=false})
                local ids: {number},normals: {number}={},{}
                local vertexCache: {[string]: number}={}
                local c=vector(group.center)-center
                for i=1,#group.positions,3 do
                    local p,n=group.positions,group.normals
                    local pk=string.format("%.6f,%.6f,%.6f",p[i],p[i+1],p[i+2])
                    local nk=string.format("%.6f,%.6f,%.6f",n[i],n[i+1],n[i+2])
                    local id=vertexCache[pk]
                    if not id then
                        id=mesh:AddVertex(Vector3.new(p[i],p[i+1],p[i+2])+c)
                        vertexCache[pk]=id
                        mesh:SetVertexBones(id,{bone}) mesh:SetVertexBoneWeights(id,{1})
                    end
                    if not normalCache[nk] then normalCache[nk]=mesh:AddNormal(Vector3.new(n[i],n[i+1],n[i+2])) end
                    table.insert(ids,id) table.insert(normals,normalCache[nk])
                end
                for i=1,#group.faces,3 do
                    local a,b,cIndex=group.faces[i],group.faces[i+1],group.faces[i+2]
                    local face=mesh:AddTriangle(ids[a],ids[b],ids[cIndex])
                    mesh:SetFaceNormals(face,{normals[a],normals[b],normals[cIndex]})
                    mesh:SetFaceColors(face,{colors[group.colors[a]],colors[group.colors[b]],colors[group.colors[cIndex]]})
                    mesh:SetFaceUVs(face,{uv,uv,uv})
                end
                task.wait() -- one bounded group per frame
            end
            if not alive then return end
            mesh:RemoveUnused()
            part=AssetService:CreateMeshPartAsync(Content.fromObject(mesh),{CollisionFidelity=Enum.CollisionFidelity.Box})
            local built=part :: MeshPart
            built.Name,built.Size,built.Color="OriginalCharacterMesh",hi-lo,Color3.new(1,1,1)
            built.Material,built.DoubleSided,built.Transparency=Enum.Material.SmoothPlastic,true,1
            configure(built)
            for _,group: Group in data.groups do
                local bone=Instance.new("Bone")
                bone.Name=group.name
                bone.CFrame=CFrame.new(vector(group.joint)-center)
                bone.Parent=built
                liveBones[group.name]=bone
            end
        end)
        if not alive then if part then part:Destroy() end return end
        if not ok then
            if part then part:Destroy() end
            if editable then editable:Destroy() editable=nil end
            model:SetAttribute("Rendering","Fallback") model:SetAttribute("MeshError",tostring(err))
            warn("Chuggernaught mesh presentation unavailable; keeping fallback rig: "..tostring(err))
            return
        end
        assert(part)
        skin=part skin.Parent=model
        for _,old in fallback do old:Destroy() end table.clear(fallback)
        model:SetAttribute("Rendering","OriginalMesh")
        model:SetAttribute("TriangleCount",6449) model:SetAttribute("BoneCount",9)
    end)
    return controller
end
return Rig
