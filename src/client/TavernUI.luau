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
function UI.ending(parent: Instance,defeat: boolean): Frame
    local card=UI.frame(parent,if defeat then "DefeatCard" else "VictoryCard")
    card.Size,card.AutomaticSize=UDim2.new(.88,0,0,0),Enum.AutomaticSize.Y
    card.AnchorPoint,card.Position=Vector2.new(.5,.5),UDim2.fromScale(.5,.5)
    local limit=Instance.new("UISizeConstraint") limit.MaxSize,limit.Parent=Vector2.new(520,1000),card
    UI.stack(card,22,12)
    local eyebrow=UI.text(card,"Eyebrow",if defeat then "YOU WERE" else "THE CHUGGERNAUGHT · LAST ORDERS",UI.Body,15,UI.Brass,1)
    local title=UI.text(card,"Headline",if defeat then "CAUGHT" else "You survived",if defeat then UI.Defeat else UI.Heading,if defeat then 64 else 44,if defeat then UI.Crimson else UI.Ivory,2)
    UI.rule(card,3)
    local detail=UI.text(card,"Detail",if defeat then "Two hits. Last orders!" else "The Firefly Tavern is behind you.\nThe dare is over. Never again.",UI.Body,20,UI.Ivory,4)
    local status=UI.text(card,"Status",if defeat then "Restarting…" else "YOU SURVIVED LAST ORDERS!",UI.Body,15,UI.Muted,5)
    for _,label in {eyebrow,title,detail,status} do label.TextXAlignment=Enum.TextXAlignment.Center end
    return card
end
return UI
