--!strict
-- Compact objective strip, opt-in detail, and a separate short-lived feedback card.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local Input=game:GetService("UserInputService")
local Config=require(game.ReplicatedStorage:WaitForChild("HalloweenShared"):WaitForChild("Config"))
local UI=require(script.Parent.TavernUI)
local player=Players.LocalPlayer
local gui=Instance.new("ScreenGui") gui.Name,gui.ResetOnSpawn="LastOrdersHUD",false
local panel=UI.frame(gui,"ObjectivePanel") panel.Position,panel.Size=UDim2.fromOffset(76,8),UDim2.new(1,-88,0,48)
local limit=Instance.new("UISizeConstraint") limit.MaxSize,limit.Parent=Vector2.new(340,48),panel
local heading=Instance.new("TextLabel") heading.Name="ObjectiveHeading"
heading.Size,heading.Position=UDim2.new(1,-62,1,0),UDim2.fromOffset(12,0)
heading.BackgroundTransparency,heading.FontFace,heading.TextSize,heading.TextColor3=1,UI.Heading,21,UI.Ivory
heading.TextXAlignment,heading.TextWrapped,heading.Parent=Enum.TextXAlignment.Left,true,panel
local toggle=Instance.new("TextButton") toggle.Name,toggle.Text="DetailsToggle","+"
toggle.Size,toggle.Position=UDim2.fromOffset(44,44),UDim2.new(1,-46,0,2)
toggle.BackgroundTransparency,toggle.FontFace,toggle.TextSize,toggle.TextColor3=1,UI.Body,26,UI.Brass toggle.Parent=panel
local icon=UI.frame(gui,"ObjectiveIcon") icon.Size,icon.Position=UDim2.fromOffset(56,56),UDim2.fromOffset(76,8)
local iconButton=Instance.new("TextButton") iconButton.Name,iconButton.Text,iconButton.Size="Objectives","",UDim2.fromScale(1,1)
iconButton.BackgroundTransparency,iconButton.Parent=1,icon
local page=Instance.new("Frame") page.Size,page.Position=UDim2.fromOffset(22,28),UDim2.fromOffset(17,14)
page.BackgroundTransparency,page.Parent=1,iconButton
local border=Instance.new("UIStroke") border.Color,border.Thickness,border.Parent=UI.Brass,2,page
for i=1,3 do
    local line=Instance.new("Frame") line.Size,line.Position=UDim2.fromOffset(13,2),UDim2.fromOffset(4,5+i*5)
    line.BackgroundColor3,line.BorderSizePixel,line.Parent=UI.Ivory,0,page
end
local details=UI.frame(gui,"ObjectiveDetails") details.Size,details.AutomaticSize=UDim2.new(1,-24,0,0),Enum.AutomaticSize.Y
details.Position=UDim2.fromOffset(12,76)
local detailLimit=Instance.new("UISizeConstraint") detailLimit.MaxSize,detailLimit.Parent=Vector2.new(340,600),details
UI.stack(details,12,6)
local drawerHeading=UI.text(details,"ObjectiveHeading","",UI.Heading,24,UI.Brass,0)
local detail=UI.text(details,"ObjectiveDetail","",UI.Body,18,UI.Ivory,1)
local circuits=UI.text(details,"Circuits","",UI.Body,16,UI.Brass,2)
local feedbackPanel=UI.frame(gui,"FeedbackCard") feedbackPanel.Size,feedbackPanel.AutomaticSize=UDim2.new(1,-24,0,0),Enum.AutomaticSize.Y
local feedbackLimit=Instance.new("UISizeConstraint") feedbackLimit.MaxSize,feedbackLimit.Parent=Vector2.new(340,600),feedbackPanel
UI.stack(feedbackPanel,12,0)
local feedback=UI.text(feedbackPanel,"Feedback","",UI.Body,17,UI.Ivory,1)
-- Notes are explicitly dismissed; reading them never freezes the hunt.
local note=UI.frame(gui,"ReadingPanel") note.AnchorPoint,note.Position=Vector2.new(.5,.5),UDim2.fromScale(.5,.5)
note.Size,note.AutomaticSize=UDim2.new(.88,0,0,0),Enum.AutomaticSize.Y note.Visible=false
local noteLimit=Instance.new("UISizeConstraint") noteLimit.MaxSize,noteLimit.Parent=Vector2.new(480,700),note
UI.stack(note,18,12)
UI.text(note,"Heading","A note from the tavern",UI.Heading,26,UI.Brass,1)
local noteText=UI.text(note,"Writing","",UI.Body,20,UI.Ivory,2)
local close=Instance.new("TextButton") close.Name,close.Text,close.Size="CloseNote","Close",UDim2.new(1,0,0,44)
close.FontFace,close.TextSize,close.TextColor3,close.BackgroundColor3=UI.Body,18,UI.Ivory,Color3.fromRGB(70,48,35)
close.LayoutOrder,close.Parent=3,note
local headings={[0]="Enter the tavern","Read the staff note","Restore power","Find the exit key","Unlock the exit","Run for the car","Leave the tavern","You survived"}
local expanded=false
local lastFeedback=""
local expandUntil,feedbackUntil=0,0
local oldStage: any=nil
local wasHidden=true
local noteSerial: any=nil
local function hidden(): boolean
    return player:GetAttribute("LastOrdersGameOver")==true or player:GetAttribute("LastOrdersDriving")==true
        or player:GetAttribute("LastOrdersEntryScene")==true or player:GetAttribute("LastOrdersArrivalScene")==true
        or player:GetAttribute("LastOrdersRevealScene")==true
end
local function update()
    local stage=player:GetAttribute("LastOrdersStage")
    if stage~=oldStage then oldStage=stage expanded=false expandUntil=os.clock()+4 note.Visible=false end
    heading.Text=if typeof(stage)=="number" then headings[stage] or "Last orders" else "The Firefly Tavern"
    detail.Text=if typeof(stage)=="number" then Config.Objectives[stage] or "" else "Waiting for the local prototype…"
    local character=player.Character
    local root=if character then character:FindFirstChild("HumanoidRootPart") else nil
    local map=workspace:FindFirstChild("LastOrdersPrototype")
    local panelPart=if map then map:FindFirstChild("CellarFuseBox") else nil
    circuits.Visible=stage==2 and root~=nil and root:IsA("BasePart") and panelPart~=nil and panelPart:IsA("BasePart") and (root.Position-panelPart.Position).Magnitude<20
    if circuits.Visible then
        local value=player:GetAttribute("CellarBreakerProgress")
        local count=if typeof(value)=="number" then value else 0
        circuits.Text="CIRCUITS "..count.." / 3  ·  "..(if count==3 then "MAIN LEVER READY" else "TRY THE CIRCUITS")
    end
    local phone=Input.TouchEnabled or (workspace.CurrentCamera~=nil and workspace.CurrentCamera.ViewportSize.X<600)
    local blocked=hidden()
    if wasHidden and not blocked then
        expandUntil=os.clock()+4
        if lastFeedback~="" then feedbackUntil=os.clock()+5 end
    end
    wasHidden=blocked
    panel.Visible=not blocked and not phone
    icon.Visible=not blocked and phone
    drawerHeading.Text,drawerHeading.Visible=heading.Text,phone
    details.Visible=not blocked and (expanded or (not phone and (os.clock()<expandUntil or circuits.Visible)))
    toggle.Text=if expanded then "−" else "+"
    local held=player:GetAttribute("LastOrdersHeld")==true
    local protected=player:GetAttribute("LastOrdersProtected")==true
    if held then note.Visible=false end
    local health=player:GetAttribute("LastOrdersHealth")
    local combat=if held then (if health==0 then "CAUGHT AGAIN" else "ONE HIT LEFT · GET READY TO RUN") elseif protected then "ONE HIT LEFT · GET AWAY!" else ""
    feedback.Text=if combat~="" then combat else lastFeedback
    feedbackPanel.Visible=not blocked and not note.Visible and (combat~="" or os.clock()<feedbackUntil)
    feedbackPanel.Position=UDim2.fromOffset(12,if details.Visible then 84+details.AbsoluteSize.Y else 76)
    if blocked then note.Visible=false end
end
local function message()
    local value=player:GetAttribute("LastOrdersMessage")
    lastFeedback=if typeof(value)=="string" then value else ""
    feedbackUntil=if lastFeedback~="" then os.clock()+5 else 0
    update()
end
local function toggleDetails() expanded=not expanded expandUntil=0 update() end
toggle.Activated:Connect(toggleDetails)
iconButton.Activated:Connect(toggleDetails)
close.Activated:Connect(function() note.Visible=false update() end)
local function readNote()
    local serial=player:GetAttribute("LastOrdersNoteSerial")
    if serial==noteSerial then return end noteSerial=serial
    local text=player:GetAttribute("LastOrdersNoteText")
    if typeof(text)=="string" and text~="" then task.defer(function() noteText.Text=text note.Visible=true feedbackUntil=0 end) end
end
for _,name in {"LastOrdersHealth","LastOrdersHeld","LastOrdersProtected","LastOrdersArrivalScene","LastOrdersStage","CellarBreakerProgress","LastOrdersGameOver","LastOrdersDriving","LastOrdersEntryScene","LastOrdersRevealScene"} do player:GetAttributeChangedSignal(name):Connect(update) end
player:GetAttributeChangedSignal("LastOrdersMessage"):Connect(message)
player:GetAttributeChangedSignal("LastOrdersNoteSerial"):Connect(readNote)
local elapsed=0
local connection=RunService.Heartbeat:Connect(function(dt) elapsed+=dt if elapsed>.15 then elapsed=0 update() end end)
script.Destroying:Connect(function() connection:Disconnect() gui:Destroy() end)
update() message() gui.Parent=player:WaitForChild("PlayerGui")
