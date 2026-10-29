--!strict
local Players=game:GetService("Players")
local Config=require(game.ReplicatedStorage:WaitForChild("HalloweenShared"):WaitForChild("Config"))
local UI=require(script.Parent.TavernUI)
local player=Players.LocalPlayer
local gui=Instance.new("ScreenGui") gui.Name,gui.ResetOnSpawn="LastOrdersHUD",false
local panel=UI.frame(gui,"ObjectivePanel") panel.Position=UDim2.fromOffset(16,12)
panel.Size,panel.AutomaticSize=UDim2.new(1,-32,0,0),Enum.AutomaticSize.Y
local limit=Instance.new("UISizeConstraint") limit.MaxSize,limit.Parent=Vector2.new(380,900),panel
UI.stack(panel,16,7)
UI.text(panel,"Eyebrow","LAST ORDERS",UI.Body,13,UI.Brass,1)
local heading=UI.text(panel,"ObjectiveHeading","The Halloween dare",UI.Heading,28,UI.Ivory,2)
local detail=UI.text(panel,"ObjectiveDetail","",UI.Body,18,UI.Ivory,3)
local circuits=UI.text(panel,"Circuits","",UI.Body,16,UI.Brass,4)
local rule=Instance.new("Frame") rule.Name,rule.Size="FeedbackRule",UDim2.new(1,0,0,1)
rule.BackgroundColor3,rule.BackgroundTransparency,rule.BorderSizePixel=UI.Brass,.6,0 rule.LayoutOrder,rule.Parent=5,panel
local feedback=UI.text(panel,"Feedback","",UI.Body,18,UI.Muted,6)
local headings={[0]="The Halloween dare","Find another way out","Bring back the lights","Find the exit key","Unlock the exit","Run for the car","Leave the tavern","You survived"}
local messageVersion=0
local function message()
    messageVersion+=1
    local version=messageVersion
    local value=player:GetAttribute("LastOrdersMessage")
    local text=if typeof(value)=="string" then value else ""
    feedback.Text=text feedback.Visible=text~="" rule.Visible=feedback.Visible
    -- Leave longer notes up long enough to read; objectives remain after feedback fades.
    if text~="" then task.delay(math.clamp(#text/14,8,22),function()
        if version==messageVersion then feedback.Visible=false rule.Visible=false end
    end) end
end
local function update()
    local stage=player:GetAttribute("LastOrdersStage")
    local valid=typeof(stage)=="number"
    heading.Text=if valid then headings[stage] or "Last orders" else "The Firefly Tavern"
    detail.Text=if valid then Config.Objectives[stage] or "" else "Waiting for the local prototype…"
    circuits.Visible=stage==2
    if stage==2 then
        local progress=player:GetAttribute("CellarBreakerProgress")
        local count=if typeof(progress)=="number" then progress else 0
        circuits.Text="CIRCUITS "..count.." / 3  ·  "..(if count==3 then "MAIN LEVER READY" else "CELLAR → GUEST ROOMS → BAR")
    end
    panel.Visible=player:GetAttribute("LastOrdersGameOver")~=true and player:GetAttribute("LastOrdersDriving")~=true
        and player:GetAttribute("LastOrdersEntryScene")~=true and player:GetAttribute("LastOrdersArrivalScene")~=true
end
for _,name in {"LastOrdersArrivalScene","LastOrdersStage","CellarBreakerProgress","LastOrdersGameOver","LastOrdersDriving","LastOrdersEntryScene"} do player:GetAttributeChangedSignal(name):Connect(update) end
player:GetAttributeChangedSignal("LastOrdersMessage"):Connect(message)
script.Destroying:Connect(function() messageVersion+=1 gui:Destroy() end)
update() message() gui.Parent=player:WaitForChild("PlayerGui")
