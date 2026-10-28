--!strict
-- Cosmetic finishes only: no collision, ray queries or changes to objective surfaces.
local Props=require(script.Parent.PubProps)
local Finish={}
local oak=Color3.fromRGB(43,29,27)
local brass=Color3.fromRGB(137,104,59)
function Finish.build(map: Folder)
    local decor=Instance.new("Folder") decor.Name="InteriorFinishes"
    local function part(name: string,size: Vector3,cf: CFrame,color: Color3,material: Enum.Material?): Part
        return Props.part(decor,name,size,cf,color,material)
    end
    -- Thin surfaces follow the existing wall segments, including the bedroom doorways.
    -- Outer window walls are deliberately left alone so the storm views remain open.
    for _,wall in map:GetChildren() do
        if wall:IsA("BasePart") and (wall.Name=="BedroomDoorWall" or wall.Name=="BedroomPartition"
            or wall.Name=="RoomFrontWall" or wall.Name=="OfficeSnugPartition" or wall.Name=="LoungeWestWall") then
            local alongX=wall.Size.X>wall.Size.Z
            local length=if alongX then wall.Size.X else wall.Size.Z
            local floor=if wall.Position.Y>16 then 16.5 else 0.5
            for _,side in {-1,1} do
                local cf=wall.CFrame*CFrame.new(if alongX then 0 else side*(wall.Size.X/2+0.04),0,if alongX then side*(wall.Size.Z/2+0.04) else 0)
                local yaw=if alongX then 0 else math.pi/2
                local origin=CFrame.new(cf.Position.X,floor,cf.Position.Z)*CFrame.Angles(0,yaw,0)
                part("OakWainscot",Vector3.new(length,3,0.08),origin*CFrame.new(0,1.5,0),oak)
                for _,y in {0.18,2.95} do part("DadoMoulding",Vector3.new(length,0.16,0.16),origin*CFrame.new(0,y,0),brass,Enum.Material.Metal) end
                local count=math.max(1,math.floor(length/3))
                for i=1,count do
                    part("PanelStile",Vector3.new(0.1,2.5,0.13),origin*CFrame.new(-length/2+(i-.5)*length/count,1.5,0),Color3.fromRGB(71,45,34))
                end
                -- A low-contrast repeat reads as aged wallpaper rather than a glowing sign.
                local paper=part("FadedWallpaper",Vector3.new(length,6.5,0.025),origin*CFrame.new(0,6.3,0),Color3.fromRGB(70,67,65),Enum.Material.Fabric)
                local gui=Instance.new("SurfaceGui") gui.Face=if side==1 then Enum.NormalId.Back else Enum.NormalId.Front
                gui.SizingMode,gui.PixelsPerStud,gui.LightInfluence=Enum.SurfaceGuiSizingMode.PixelsPerStud,32,1 gui.Parent=paper
                for i=1,math.floor(length/2) do
                    local diamond=Instance.new("Frame") diamond.AnchorPoint=Vector2.new(.5,.5)
                    diamond.Position,diamond.Size=UDim2.fromScale((i-.5)/math.floor(length/2),.5),UDim2.fromOffset(13,45)
                    diamond.Rotation,diamond.BorderSizePixel,diamond.BackgroundColor3,diamond.BackgroundTransparency=45,0,Color3.fromRGB(109,94,73),.55
                    diamond.Parent=gui
                end
            end
        end
    end
    local function rug(cf: CFrame,width: number,length: number,color: Color3)
        part("WornRugBorder",Vector3.new(width,.025,length),cf,Color3.fromRGB(104,78,49),Enum.Material.Fabric)
        part("WornRugField",Vector3.new(width-.4,.028,length-.4),cf*CFrame.new(0,.018,0),color,Enum.Material.Fabric)
        for _,z in {-length/2+.6,length/2-.6} do
            part("RugWovenBand",Vector3.new(width-.7,.03,.12),cf*CFrame.new(0,.035,z),Color3.fromRGB(151,114,75),Enum.Material.Fabric)
        end
        for _,z in {-length*.25,0,length*.25} do
            part("RugDiamond",Vector3.new(.65,.03,.65),cf*CFrame.new(0,.04,z)*CFrame.Angles(0,math.pi/4,0),Color3.fromRGB(132,97,65),Enum.Material.Fabric)
        end
    end
    rug(CFrame.new(6,.55,66),8,25,Color3.fromRGB(74,34,42))
    rug(CFrame.new(-8,.55,23),7,17,Color3.fromRGB(61,58,48))
    local colours={Color3.fromRGB(66,58,52),Color3.fromRGB(52,65,62),Color3.fromRGB(68,49,59),Color3.fromRGB(55,58,76)}
    for sideIndex,side in {-1,1} do
        for i,z in {-30,-10,10,30} do
            local number=(sideIndex-1)*4+i
            rug(CFrame.new(side*31,16.55,z+2),5,10,colours[i])
            -- Small room-specific finish on the existing headboard; no new furniture volume.
            part("UpholsteredHeadboard",Vector3.new(4.2,1.5,.08),CFrame.new(side*40,19.3,z-.28),colours[i],Enum.Material.Fabric)
            part("BedroomCeilingBeam",Vector3.new(38,.28,.35),CFrame.new(side*28,29.7,z),oak)
            -- Brass cap over the doorway, kept above head height and clear of the number.
            part("DoorHeaderMoulding",Vector3.new(.18,.2,12),CFrame.new(side*7.4,27,z),brass,Enum.Material.Metal)
        end
    end
    for _,z in {48,64,80} do
        part("LoungeCeilingTie",Vector3.new(55,.4,.5),CFrame.new(20,29.6,z),oak)
    end
    -- Frame existing signs in place, retaining their text, dimensions and orientation.
    for _,object in map:GetDescendants() do
        if object:IsA("BasePart") and (object.Name=="GuestSign" or object.Name=="PubName" or object.Name=="SnugLabel" or object.Name=="HallLabel") then
            local size=object.Size
            for _,y in {-1,1} do part("SignFrame",Vector3.new(size.X+.3,.13,size.Z+.12),object.CFrame*CFrame.new(0,y*(size.Y/2+.08),0),brass,Enum.Material.Metal) end
            for _,x in {-1,1} do part("SignFrame",Vector3.new(.13,size.Y+.3,size.Z+.12),object.CFrame*CFrame.new(x*(size.X/2+.08),0,0),oak) end
        end
    end
    decor.Parent=map
end
return Finish
