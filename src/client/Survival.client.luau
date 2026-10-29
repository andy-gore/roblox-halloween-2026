--!strict
-- Presentation/input only. Server attributes own health, holds and game-over timing.
local Players=game:GetService("Players")
local StarterGui=game:GetService("StarterGui")
if workspace:GetAttribute("LastOrdersGreybox")~=true then return end
local player=Players.LocalPlayer
local gui=Instance.new("ScreenGui") gui.Name,gui.ResetOnSpawn,gui.DisplayOrder="LastOrdersSurvival",false,20
local UI=require(script.Parent.TavernUI)
local dial=require(script.Parent.HealthDial).new(gui)
local bar=dial.frame
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
    dial.update(health)
    local driving=player:GetAttribute("LastOrdersDriving")==true
    overlay.Visible,bar.Visible=gameOver,not gameOver and not driving and player:GetAttribute("LastOrdersArrivalScene")~=true and player:GetAttribute("LastOrdersEntryScene")~=true and player:GetAttribute("LastOrdersRevealScene")~=true
    bar.AnchorPoint,bar.Position=Vector2.zero,UDim2.fromOffset(12,8)
    local locked=held or gameOver or driving or player:GetAttribute("LastOrdersEntryScene")==true or player:GetAttribute("LastOrdersArrivalScene")==true or player:GetAttribute("LastOrdersRevealScene")==true
    if locked~=movementLocked then
        movementLocked=locked
        if locked then controls:Disable() else controls:Enable() end
    end
end
for _,name in {"LastOrdersRevealScene","LastOrdersArrivalScene","LastOrdersDriving","LastOrdersEntryScene","LastOrdersHealth","LastOrdersHeld","LastOrdersGameOver","LastOrdersProtected"} do
    player:GetAttributeChangedSignal(name):Connect(update)
end
script.Destroying:Connect(function()
    if movementLocked then controls:Enable() end
    pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health,true) end)
    gui:Destroy()
end)
update()
