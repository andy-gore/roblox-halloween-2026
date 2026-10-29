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
local function firefly(surface: SurfaceGui,fascia: boolean?)
    local art=Instance.new("Frame") art.Name="FireflyIllustration"
    art.Position,art.Size,art.BackgroundTransparency=UDim2.fromScale(if fascia then .04 else .1,.18),UDim2.fromScale(if fascia then .12 else .28,.64),1 art.Parent=surface
    local ratio=Instance.new("UIAspectRatioConstraint") ratio.AspectRatio,ratio.DominantAxis,ratio.Parent=1,Enum.DominantAxis.Height,art
    -- Symmetric engraved wings, dark thorax and a luminous golden abdomen.
    for _,side in {-1,1} do
        local wing=shape(art,"EngravedWing",UDim2.fromScale(.5+side*.2,.4),UDim2.fromScale(.27,.57),brass,side*28)
        local line=Instance.new("UIStroke") line.Color,line.Thickness,line.Parent=ivory,2,wing
        shape(art,"Antenna",UDim2.fromScale(.5+side*.09,.08),UDim2.fromScale(.025,.18),brass,side*35)
    end
    shape(art,"AbdomenGlow",UDim2.fromScale(.5,.78),UDim2.fromScale(.24,.28),Color3.fromRGB(224,193,94))
    shape(art,"Thorax",UDim2.fromScale(.5,.42),UDim2.fromScale(.13,.42),Color3.fromRGB(63,51,35))
    shape(art,"Head",UDim2.fromScale(.5,.19),UDim2.fromScale(.16,.15),ivory)
end
-- Native version of the refined Blender cartouche, keeping live sign text editable.
local function frame(parent: Instance,name: string,pos: UDim2,size: UDim2,color: Color3,z: number): Frame
    local f=Instance.new("Frame")
    f.Name,f.Position,f.Size,f.BackgroundColor3=name,pos,size,color
    f.BorderSizePixel,f.ZIndex,f.Parent=0,z,parent
    return f
end
local function finish(surface: SurfaceGui,board: BasePart)
    local previous=surface:FindFirstChild("RefinedSignFace")
    if previous then previous:Destroy() end
    -- Remove the previous native finish, including its separate firefly art.
    for _,name in {"OakSignFace","BrassBorder","FireflyIllustration"} do
        local old=surface:FindFirstChild(name) if old then old:Destroy() end
    end
    local root=frame(surface,"RefinedSignFace",UDim2.fromScale(0,0),UDim2.fromScale(1,1),Color3.fromRGB(66,34,20),0)
    frame(root,"OakMoulding",UDim2.fromScale(.012,.045),UDim2.fromScale(.976,.91),Color3.fromRGB(93,52,30),0)
    frame(root,"EnamelInset",UDim2.fromScale(.025,.09),UDim2.fromScale(.95,.82),Color3.fromRGB(31,25,29),0)
    local width,height=board.Size.X*80,board.Size.Y*80
    -- Pixel-space lengths preserve chamfer angles on both broad and narrow boards.
    local function line(name: string,x1: number,y1: number,x2: number,y2: number,thickness: number)
        local dx,dy=(x2-x1)*width,(y2-y1)*height
        local f=frame(root,name,UDim2.fromOffset((x1+x2)*width/2,(y1+y2)*height/2),UDim2.fromOffset(math.sqrt(dx*dx+dy*dy),thickness),brass,1)
        f.AnchorPoint,f.Rotation=Vector2.new(.5,.5),math.deg(math.atan2(dy,dx))
    end
    local x,y,cut=.045,.15,math.min(height*.07,width*.02)
    local cx,cy=cut/width,cut/height
    local points={{x+cx,y},{1-x-cx,y},{1-x,y+cy},{1-x,1-y-cy},{1-x-cx,1-y},{x+cx,1-y},{x,1-y-cy},{x,y+cy}}
    for i,p in points do
        local q=points[i%#points+1] line("CartoucheEdge",p[1],p[2],q[1],q[2],1.5)
    end
    for _,side in {-1,1} do
        local screw=frame(root,"BrassFixing",UDim2.fromScale(.5+side*.44,.5),UDim2.fromOffset(5,5),brass,1)
        screw.AnchorPoint=Vector2.new(.5,.5)
        local round=Instance.new("UICorner") round.CornerRadius,round.Parent=UDim.new(.5,0),screw
    end
    surface:SetAttribute("SignFinish","RefinedTavern")
    return root,line
end
function Signs.build(map: Folder)
    for _,gui in map:GetDescendants() do
        if not gui:IsA("SurfaceGui") then continue end
        local board=gui.Parent
        if not board or not board:IsA("BasePart") then continue end
        -- Papers and active control displays retain their own instructional treatment.
        if board.Name=="Warning" or board.Name=="CellarInstructions" or board.Name=="FadedWallpaper" or board.Name=="BedroomPlaqueLettering" then continue end
        local labels: {TextLabel}={}
        for _,child in gui:GetChildren() do if child:IsA("TextLabel") then table.insert(labels,child) end end
        if #labels==0 then continue end
        board.Color,board.Material=oak,Enum.Material.Wood
        gui.SizingMode,gui.PixelsPerStud=Enum.SurfaceGuiSizingMode.PixelsPerStud,80
        gui.LightInfluence,gui.Brightness=0,.9
        local root,line=finish(gui,board)
        for _,label in labels do
            label.BackgroundTransparency,label.TextColor3,label.TextStrokeTransparency=1,ivory,1
            label.Position,label.Size=UDim2.fromScale(.085,.27),UDim2.fromScale(.83,.46)
            label.TextWrapped,label.TextScaled,label.ZIndex=true,true,2
            local brand=board.Name=="PubName" or board.Name=="FrontPubName" or board.Name=="SignBoard" or board.Name=="OutsideSign"
            local short=not string.find(label.Text,"\n") and not string.find(label.Text,"/") and utf8.len(label.Text)<=20
            label.FontFace=Font.new(if brand or short then "rbxasset://fonts/families/Fondamento.json" else "rbxasset://fonts/families/Nunito.json",Enum.FontWeight.Regular)
            if short and not brand then
                for _,y in {.23,.77} do
                    line("OrnamentRule",.17,y,.47,y,1)
                    line("OrnamentRule",.53,y,.83,y,1)
                    local diamond=frame(root,"DiamondInlay",UDim2.fromScale(.5,y),UDim2.fromOffset(4,4),brass,1)
                    diamond.AnchorPoint,diamond.Rotation=Vector2.new(.5,.5),45
                end
            end
            if board.Name=="SignBoard" then
                label.Text="THE FIREFLY\nTAVERN"
                label.Position,label.Size=UDim2.fromScale(.43,.25),UDim2.fromScale(.46,.45)
                firefly(gui)
                local closed=Instance.new("TextLabel") closed.Name="ClosedCaption"
                closed.BackgroundTransparency,closed.FontFace,closed.TextColor3=1,Font.new("rbxasset://fonts/families/Nunito.json"),brass
                closed.Text,closed.TextScaled,closed.Size,closed.Position="CLOSED",true,UDim2.fromScale(.28,.1),UDim2.fromScale(.52,.76)
                closed.ZIndex,closed.Parent=2,gui
            elseif board.Name=="FrontPubName" then
                label.Position,label.Size=UDim2.fromScale(.15,.27),UDim2.fromScale(.76,.46)
                firefly(gui,true)
            elseif not short then
                label.Position,label.Size=UDim2.fromScale(.085,.23),UDim2.fromScale(.83,.54)
            end
        end
    end
end
return Signs
