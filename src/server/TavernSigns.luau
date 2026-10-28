--!strict
-- Shared sign finish; preserves wording, prompts and physical board placement.
local Signs={}
local brass=Color3.fromRGB(188,161,106)
local ivory=Color3.fromRGB(240,223,188)
local oak=Color3.fromRGB(33,26,25)
local function shape(parent: Instance,name: string,pos: UDim2,size: UDim2,color: Color3,rotation: number?): Frame
    local f=Instance.new("Frame") f.Name,f.Position,f.Size=name,pos,size
    f.AnchorPoint,f.BorderSizePixel,f.BackgroundColor3=Vector2.new(.5,.5),0,color
    f.Rotation,f.Parent=rotation or 0,parent
    local round=Instance.new("UICorner") round.CornerRadius=UDim.new(.5,0) round.Parent=f
    return f
end
local function firefly(surface: SurfaceGui)
    local art=Instance.new("Frame") art.Name="FireflyIllustration"
    art.Position,art.Size,art.BackgroundTransparency=UDim2.fromScale(.1,.17),UDim2.fromScale(.28,.66),1 art.Parent=surface
    -- Symmetric engraved wings, dark thorax and a luminous golden abdomen.
    for _,side in {-1,1} do
        local wing=shape(art,"EngravedWing",UDim2.fromScale(.5+side*.2,.4),UDim2.fromScale(.27,.57),brass,side*28)
        local line=Instance.new("UIStroke") line.Color,line.Thickness,line.Parent=ivory,1,wing
        shape(art,"Antenna",UDim2.fromScale(.5+side*.09,.08),UDim2.fromScale(.025,.18),brass,side*35)
    end
    shape(art,"AbdomenGlow",UDim2.fromScale(.5,.78),UDim2.fromScale(.24,.28),Color3.fromRGB(224,193,94))
    shape(art,"Thorax",UDim2.fromScale(.5,.42),UDim2.fromScale(.13,.42),Color3.fromRGB(63,51,35))
    shape(art,"Head",UDim2.fromScale(.5,.19),UDim2.fromScale(.16,.15),ivory)
end
function Signs.build(map: Folder)
    for _,gui in map:GetDescendants() do
        if not gui:IsA("SurfaceGui") then continue end
        local board=gui.Parent
        if not board or not board:IsA("BasePart") then continue end
        -- Papers and active control displays retain their own instructional treatment.
        if board.Name=="Warning" or board.Name=="CellarInstructions" or board.Name=="FadedWallpaper" then continue end
        local labels: {TextLabel}={}
        for _,child in gui:GetChildren() do if child:IsA("TextLabel") then table.insert(labels,child) end end
        if #labels==0 then continue end
        board.Color,board.Material=oak,Enum.Material.Wood
        gui.LightInfluence,gui.Brightness=0,.9
        local field=Instance.new("Frame") field.Name="OakSignFace" field.Size=UDim2.fromScale(1,1)
        field.BackgroundColor3,field.BorderSizePixel,field.ZIndex=oak,0,0 field.Parent=gui
        local border=Instance.new("Frame") border.Name="BrassBorder" border.Size,border.Position=UDim2.fromScale(.94,.82),UDim2.fromScale(.03,.09)
        border.BackgroundTransparency,border.ZIndex,border.Parent=1,1,gui
        local stroke=Instance.new("UIStroke") stroke.Color,stroke.Thickness,stroke.Parent=brass,2,border
        for _,label in labels do
            label.BackgroundTransparency,label.TextColor3,label.TextStrokeTransparency=1,ivory,1
            label.Position,label.Size=UDim2.fromScale(.07,.17),UDim2.fromScale(.86,.66)
            label.TextWrapped,label.TextScaled,label.ZIndex=true,true,2
            local brand=board.Name=="PubName" or board.Name=="FrontPubName" or board.Name=="SignBoard" or board.Name=="OutsideSign"
            label.FontFace=Font.new(if brand then "rbxasset://fonts/families/Fondamento.json" else "rbxasset://fonts/families/Nunito.json",Enum.FontWeight.Bold)
            if board.Name=="SignBoard" then
                label.Text="THE FIREFLY\nTAVERN"
                label.Position,label.Size=UDim2.fromScale(.42,.19),UDim2.fromScale(.5,.62)
                firefly(gui)
            end
        end
    end
end
return Signs
