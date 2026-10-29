--!strict
-- Two separated semicircles. Depleted health is outlined, not merely recoloured.
local UI=require(script.Parent.TavernUI)
local Dial={}
function Dial.new(gui: ScreenGui)
    local frame=UI.frame(gui,"HealthBar") frame.Size=UDim2.fromOffset(56,56) frame.AnchorPoint=Vector2.new(.5,1)
    local corner=frame:FindFirstChildOfClass("UICorner") if corner then corner.CornerRadius=UDim.new(.5,0) end
    local halves: {{Frame}}={{},{}}
    for half=1,2 do for i=1,22 do
        local angle=math.rad((half-1)*180+7+(i-1)*166/21)
        local segment=Instance.new("Frame") segment.Name="Half"..half.."Segment"..i
        segment.AnchorPoint,segment.Size=Vector2.new(.5,.5),UDim2.fromOffset(4,5)
        segment.Position,segment.Rotation=UDim2.fromOffset(28+math.sin(angle)*21,28-math.cos(angle)*21),math.deg(angle)
        segment.BorderSizePixel,segment.Parent=0,frame
        local stroke=Instance.new("UIStroke") stroke.Thickness,stroke.Color,stroke.Parent=1,UI.Muted,segment
        table.insert(halves[half],segment)
    end end
    local count=Instance.new("TextLabel") count.Name,count.Size,count.BackgroundTransparency="HealthCount",UDim2.fromScale(1,1),1
    count.FontFace,count.TextSize,count.TextColor3,count.Parent=UI.Body,18,UI.Ivory,frame
    local controller={frame=frame}
    function controller.update(health: number)
        count.Text=tostring(health)
        for half,segments in halves do for _,segment in segments do
            local filled=half<=health
            segment.BackgroundTransparency=if filled then 0 else 1
            segment.BackgroundColor3=UI.Crimson
            local stroke=segment:FindFirstChildOfClass("UIStroke")
            if stroke then stroke.Transparency=if filled then .8 else .3 end
        end end
    end
    return controller
end
return Dial
