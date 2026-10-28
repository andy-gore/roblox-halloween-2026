--!strict
-- Presentation/input only. Server attributes own health, holds and game-over timing.
local Players=game:GetService("Players")
local StarterGui=game:GetService("StarterGui")
if workspace:GetAttribute("LastOrdersGreybox")~=true then return end
local player=Players.LocalPlayer
local gui=Instance.new("ScreenGui") gui.Name,gui.ResetOnSpawn,gui.DisplayOrder="LastOrdersSurvival",false,20
local bar=Instance.new("Frame") bar.Name,bar.AnchorPoint,bar.Position="HealthBar",Vector2.new(0.5,1),UDim2.fromScale(0.5,0.97)
bar.Size,bar.BackgroundColor3,bar.BackgroundTransparency=UDim2.fromOffset(260,65),Color3.fromRGB(24,20,28),0.1
bar.Parent=gui
local title=Instance.new("TextLabel") title.Name,title.Size,title.Position="Status",UDim2.fromScale(0.96,0.45),UDim2.fromScale(0.02,0.05)
title.BackgroundTransparency,title.Font,title.TextSize=1,Enum.Font.GothamBold,16 title.Parent=bar
local segments: {Frame}={}
for i=1,2 do
    local segment=Instance.new("Frame") segment.Name="Hit"..i
    segment.Size,segment.Position=UDim2.fromScale(0.46,0.26),UDim2.fromScale(0.025+(i-1)*0.49,0.61)
    segment.BorderSizePixel,segment.Parent=0,bar
    table.insert(segments,segment)
end
local overlay=Instance.new("Frame") overlay.Name,overlay.Size="GameOver",UDim2.fromScale(1,1)
overlay.BackgroundColor3,overlay.BackgroundTransparency,overlay.Visible=Color3.fromRGB(14,11,18),0.08,false
overlay.Parent=gui
local ending=Instance.new("TextLabel") ending.Size,ending.Position=UDim2.fromScale(0.9,0.4),UDim2.fromScale(0.05,0.3)
ending.BackgroundTransparency,ending.Font,ending.TextSize,ending.TextWrapped=1,Enum.Font.GothamBold,28,true
ending.TextColor3,ending.Text,ending.Parent=Color3.fromRGB(255,224,170),"YOU WERE CAUGHT\nTwo hits. Last orders!\n\nRestarting…",overlay
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
    title.TextColor3=if health==2 then Color3.fromRGB(220,230,185) else Color3.fromRGB(255,185,100)
    for i,segment in segments do
        segment.BackgroundColor3=if i>health then Color3.fromRGB(60,47,48)
            elseif health==2 then Color3.fromRGB(155,185,110) else Color3.fromRGB(231,159,70)
    end
    local driving=player:GetAttribute("LastOrdersDriving")==true
    overlay.Visible,bar.Visible=gameOver,not gameOver and not driving
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
