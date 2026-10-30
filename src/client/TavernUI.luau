--!strict
-- Shared presentation primitives; gameplay and restart timing remain server-owned.
local UI={}
UI.Ink=Color3.fromRGB(23,19,22)
UI.Ivory=Color3.fromRGB(240,223,188)
UI.Brass=Color3.fromRGB(188,161,106)
UI.Muted=Color3.fromRGB(188,177,159)
UI.Crimson=Color3.fromRGB(196,59,71)
UI.Heading=Font.new("rbxasset://fonts/families/Fondamento.json")
UI.Body=Font.new("rbxasset://fonts/families/Nunito.json")
UI.Defeat=Font.new("rbxasset://fonts/families/Creepster.json")
function UI.frame(parent: Instance,name: string): Frame
    local frame=Instance.new("Frame") frame.Name,frame.BackgroundColor3,frame.BorderSizePixel=name,UI.Ink,0
    frame.BackgroundTransparency=.03 frame.Parent=parent
    local stroke=Instance.new("UIStroke") stroke.Color,stroke.Transparency,stroke.Thickness,stroke.Parent=UI.Brass,.45,1,frame
    local corner=Instance.new("UICorner") corner.CornerRadius,corner.Parent=UDim.new(0,5),frame
    return frame
end
function UI.stack(frame: Frame,padding: number,gap: number)
    local inset=Instance.new("UIPadding")
    inset.PaddingLeft,inset.PaddingRight=UDim.new(0,padding),UDim.new(0,padding)
    inset.PaddingTop,inset.PaddingBottom=UDim.new(0,padding),UDim.new(0,padding) inset.Parent=frame
    local layout=Instance.new("UIListLayout") layout.SortOrder,layout.Padding=Enum.SortOrder.LayoutOrder,UDim.new(0,gap) layout.Parent=frame
end
function UI.text(parent: Instance,name: string,text: string,font: Font,size: number,color: Color3,order: number): TextLabel
    local label=Instance.new("TextLabel") label.Name,label.Text=name,text
    label.Size,label.AutomaticSize=UDim2.new(1,0,0,0),Enum.AutomaticSize.Y
    label.BackgroundTransparency,label.FontFace,label.TextSize,label.TextColor3=1,font,size,color
    label.TextWrapped,label.TextXAlignment,label.TextYAlignment=true,Enum.TextXAlignment.Left,Enum.TextYAlignment.Top
    label.LayoutOrder,label.Parent=order,parent
    return label
end
function UI.rule(parent: Instance,order: number)
    local line=Instance.new("Frame") line.Name,line.Size="BrassRule",UDim2.new(1,0,0,1)
    line.BackgroundColor3,line.BackgroundTransparency,line.BorderSizePixel=UI.Brass,.6,0 line.LayoutOrder,line.Parent=order,parent
end
-- Vector-like local crest: no image download or asset permission dependency.
function UI.crest(parent: Instance,size: number,order: number): Frame
    local holder=Instance.new("Frame") holder.Name="FireflyCrest"
    holder.Size,holder.BackgroundTransparency,holder.LayoutOrder=UDim2.new(1,0,0,size),1,order
    holder.Parent=parent
    local function shape(name: string,x: number,y: number,w: number,h: number,rotation: number,color: Color3)
        local f=Instance.new("Frame") f.Name=name f.AnchorPoint=Vector2.new(.5,.5)
        f.Position,f.Size=UDim2.new(.5,x*size,0,y*size),UDim2.fromOffset(w*size,h*size)
        f.Rotation,f.BackgroundColor3,f.BorderSizePixel=rotation,color,0
        local c=Instance.new("UICorner") c.CornerRadius,c.Parent=UDim.new(1,0),f f.Parent=holder
    end
    for _,side in {-1,1} do
        shape("Wing",side*.18,.37,.32,.12,side*-30,UI.Brass)
        shape("Wing",side*.16,.52,.27,.10,side*30,UI.Brass)
    end
    shape("Body",0,.52,.09,.34,0,UI.Brass)
    shape("Light",0,.64,.08,.12,0,UI.Ivory)
    shape("Head",0,.29,.12,.12,0,UI.Ivory)
    return holder
end
function UI.title(parent: Instance): Frame
    local card=UI.frame(parent,"TitleCard")
    card.Size,card.AutomaticSize=UDim2.new(.88,0,0,0),Enum.AutomaticSize.Y
    card.AnchorPoint,card.Position=Vector2.new(.5,.5),UDim2.fromScale(.5,.43)
    local limit=Instance.new("UISizeConstraint") limit.MaxSize,limit.Parent=Vector2.new(480,1000),card
    UI.stack(card,18,5) UI.crest(card,52,0)
    local a=UI.text(card,"Title","THE CHUGGERNAUGHT",UI.Heading,30,UI.Ivory,1)
    local b=UI.text(card,"Subtitle","LAST ORDERS",UI.Heading,23,UI.Brass,2)
    UI.rule(card,3)
    local c=UI.text(card,"Location","THE FIREFLY TAVERN",UI.Body,14,UI.Muted,4)
    for _,label in {a,b,c} do label.TextXAlignment=Enum.TextXAlignment.Center end
    return card
end
function UI.ending(parent: Instance,defeat: boolean): Frame
    local card=UI.frame(parent,if defeat then "DefeatCard" else "VictoryCard")
    card.Size,card.AutomaticSize=UDim2.new(.88,0,0,0),Enum.AutomaticSize.Y
    card.AnchorPoint,card.Position=Vector2.new(.5,.5),UDim2.fromScale(.5,.5)
    local limit=Instance.new("UISizeConstraint") limit.MaxSize,limit.Parent=Vector2.new(520,1000),card
    UI.stack(card,18,7)
    UI.crest(card,48,0)
    local eyebrow=UI.text(card,"Eyebrow",if defeat then "YOU WERE" else "THE CHUGGERNAUGHT · LAST ORDERS",UI.Body,15,UI.Brass,1)
    local title=UI.text(card,"Headline",if defeat then "CAUGHT" else "You survived",if defeat then UI.Defeat else UI.Heading,if defeat then 44 else 34,if defeat then UI.Crimson else UI.Ivory,2)
    UI.rule(card,3)
    local detail=UI.text(card,"Detail",if defeat then "The Chuggernaught caught you." else "The Firefly Tavern is behind you.\nThe dare is over. Never again.",UI.Body,18,UI.Ivory,4)
    local status=UI.text(card,"Status",if defeat then "Restarting…" else "RESTORE THE LIGHTS. FIND THE KEY. ESCAPE.",UI.Body,15,UI.Muted,5)
    for _,label in {eyebrow,title,detail,status} do label.TextXAlignment=Enum.TextXAlignment.Center end
    return card
end
return UI
