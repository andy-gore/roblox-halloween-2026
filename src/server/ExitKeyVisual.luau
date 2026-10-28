--!strict
-- Native brass key geometry follows the authoritative pickup; all cues respect walls.
local Visual={}
function Visual.new(key: BasePart)
    key.Size,key.Color,key.Material=Vector3.new(1.9,0.2,0.2),Color3.fromRGB(240,190,65),Enum.Material.Metal
    key.CastShadow=false
    local model=Instance.new("Model") model.Name="BrassKey" model.Parent=key
    local pieces: {{part: BasePart, offset: CFrame}}={}
    local function piece(name: string,size: Vector3,offset: CFrame)
        local p=Instance.new("Part") p.Name,p.Size,p.Color,p.Material=name,size,key.Color,Enum.Material.Metal
        p.Anchored,p.CanCollide,p.CanTouch,p.CanQuery,p.CastShadow=true,false,false,false,false
        p.Transparency,p.Parent=1,model
        table.insert(pieces,{part=p,offset=offset})
    end
    for i=0,11 do
        local angle=i*math.pi/6
        local position=Vector3.new(-1.55+math.cos(angle)*0.6,0,math.sin(angle)*0.6)
        piece("KeyBow",Vector3.new(0.34,0.2,0.16),CFrame.new(position)*CFrame.Angles(0,-angle-math.pi/2,0))
    end
    for _,x in {0.45,0.8} do piece("KeyTooth",Vector3.new(0.18,0.2,0.55),CFrame.new(x,0,0.25)) end
    local light=Instance.new("PointLight") light.Name="ExitKeyGlow"
    light.Color,light.Range,light.Brightness,light.Enabled=key.Color,7,0.65,false light.Parent=key
    local tag=Instance.new("BillboardGui") tag.Name,tag.Adornee="ExitKeyLabel",key
    tag.Size,tag.StudsOffsetWorldSpace,tag.MaxDistance=UDim2.fromOffset(110,26),Vector3.new(0,1,0),18
    tag.AlwaysOnTop,tag.Enabled,tag.Parent=false,false,key
    local textLabel=Instance.new("TextLabel") textLabel.Size,textLabel.BackgroundTransparency=UDim2.fromScale(1,1),1
    textLabel.Text,textLabel.Font,textLabel.TextSize="EXIT KEY",Enum.Font.GothamBold,16
    textLabel.TextColor3,textLabel.TextStrokeTransparency,textLabel.Parent=key.Color,0.2,tag
    local controller={}
    function controller.refresh(visible: boolean)
        for _,entry in pieces do
            entry.part.CFrame=key.CFrame*entry.offset
            entry.part.Transparency=if visible then 0 else 1
        end
        light.Enabled,tag.Enabled=visible,visible
    end
    controller.refresh(false)
    return controller
end
return Visual
