--!strict
-- Presentation/input only. Server attributes own health, holds and game-over timing.
local Players=game:GetService("Players")
local StarterGui=game:GetService("StarterGui")
if workspace:GetAttribute("LastOrdersGreybox")~=true then return end
local player=Players.LocalPlayer
local UserInputService=game:GetService("UserInputService")
local gui=Instance.new("ScreenGui") gui.Name,gui.ResetOnSpawn,gui.DisplayOrder="LastOrdersSurvival",false,20
local UI=require(script.Parent.TavernUI)
local bar=UI.frame(gui,"HealthBar")
bar.AnchorPoint,bar.Position=Vector2.new(.5,1),UDim2.new(.5,0,1,-20)
bar.Size=UDim2.fromOffset(244,62)
local title=Instance.new("TextLabel") title.Name,title.Size,title.Position="Status",UDim2.new(1,-20,0,26),UDim2.fromOffset(10,5)
title.BackgroundTransparency,title.FontFace,title.TextSize=1,UI.Body,15 title.Parent=bar
local segments: {Frame}={}
for i=1,2 do
    local segment=Instance.new("Frame") segment.Name="Hit"..i
    segment.Size,segment.Position=UDim2.new(.5,-15,0,9),UDim2.new((i-1)*.5,10,0,40)
    segment.BorderSizePixel,segment.Parent=0,bar
    local round=Instance.new("UICorner") round.CornerRadius,round.Parent=UDim.new(0,2),segment
    table.insert(segments,segment)
end
local overlay=Instance.new("Frame") overlay.Name,overlay.Size="GameOver",UDim2.fromScale(1,1)
overlay.BackgroundColor3,overlay.BackgroundTransparency,overlay.Visible=UI.Ink,.02,false overlay.BorderSizePixel=0
UI.ending(overlay,true)
overlay.Parent=gui
gui.Parent=player:WaitForChild("PlayerGui")
local controls=require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls()
local movementLocked=false
pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health,false) end)
local function update()
    local value=player:GetAttribute("LastOrdersHealth")
    local health=if typeof(value)=="number" then math.clamp(value,0,2) else 2
    local held=player:GetAttribute("LastOrdersHeld")==true
    local gameOver=player:GetAttribute("LastOrdersGameOver")==true
    local protected=player:GetAttribute("LastOrdersProtected")==true
    title.Text=if held then (if health>0 then "CAUGHT — ONE HIT LEFT" else "CAUGHT AGAIN")
        elseif protected then "1/2 HEALTH — GET AWAY!" else "HEALTH "..health.."/2"
    title.TextColor3=if health==2 then UI.Ivory else Color3.fromRGB(255,185,100)
    for i,segment in segments do
        segment.BackgroundColor3=if i>health then Color3.fromRGB(60,47,48)
            elseif health==2 then UI.Brass else Color3.fromRGB(231,159,70)
    end
    local driving=player:GetAttribute("LastOrdersDriving")==true
    overlay.Visible,bar.Visible=gameOver,not gameOver and not driving
    bar.Position=UDim2.new(.5,0,1,if UserInputService.TouchEnabled then -90 else -20)
    local locked=held or gameOver or driving or player:GetAttribute("LastOrdersEntryScene")==true
    if locked~=movementLocked then
        movementLocked=locked
        if locked then controls:Disable() else controls:Enable() end
    end
end
for _,name in {"LastOrdersDriving","LastOrdersEntryScene","LastOrdersHealth","LastOrdersHeld","LastOrdersGameOver","LastOrdersProtected"} do
    player:GetAttributeChangedSignal(name):Connect(update)
end
script.Destroying:Connect(function()
    if movementLocked then controls:Enable() end
    pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health,true) end)
    gui:Destroy()
end)
update()
