--!strict
-- Local visual repair only; preserve the real head, joints, accessories and server hitbox.
local Visual={}
function Visual.new(character: Model,head: BasePart)
    local part: Part?=nil
    local decal: Decal?=nil
    local originalAlpha: number?=nil
    local hidden: {[Decal]: number}={}
    local mode: boolean?=nil
    local controller={}
    function controller.clear()
        if part then part:Destroy() part=nil end
        if decal then decal:Destroy() decal=nil end
        if originalAlpha~=nil and head.Parent then head.Transparency=originalAlpha end
        originalAlpha=nil
        for old,alpha in hidden do if old.Parent then old.Transparency=alpha end end
        hidden={} mode=nil
    end
    function controller.show(fullHead: boolean)
        if mode==fullHead and decal and decal.Parent then return end
        controller.clear() mode=fullHead
        local parent: Instance=head
        if fullHead then
            originalAlpha=head.Transparency head.Transparency=1
            local replacement=Instance.new("Part") replacement.Name="UnavailableHeadFallback"
            replacement.Anchored,replacement.CanCollide,replacement.CanTouch,replacement.CanQuery=true,false,false,false
            replacement.Size,replacement.Color,replacement.CFrame=head.Size,head.Color,head.CFrame
            replacement.Transparency,replacement.Massless=originalAlpha,true
            local mesh=Instance.new("SpecialMesh") mesh.MeshType,mesh.Scale,mesh.Parent=Enum.MeshType.Head,Vector3.one*1.25,replacement
            replacement.Parent=character part=replacement parent=replacement
        else
            for _,old in head:GetChildren() do
                if old:IsA("Decal") and old.Face==Enum.NormalId.Front then hidden[old]=old.Transparency old.Transparency=1 end
            end
        end
        local face=Instance.new("Decal") face.Name,face.Face,face.Texture="LocalClassicFace",Enum.NormalId.Front,"rbxasset://textures/face.png"
        face.Parent=parent decal=face
    end
    function controller.update()
        if part and part.Parent and head.Parent then
            part.CFrame,part.Color,part.Size=head.CFrame,head.Color,head.Size
            part.LocalTransparencyModifier=head.LocalTransparencyModifier
        end
    end
    return controller
end
return Visual
