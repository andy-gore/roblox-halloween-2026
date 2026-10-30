--!strict
-- Brief presentation while replicated run state arrives; no extra start gate or fake progress.
local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
if workspace:GetAttribute("LastOrdersGreybox")~=true then return end
local player=Players.LocalPlayer
local UI=require(script.Parent.TavernUI)
local gui=Instance.new("ScreenGui") gui.Name,gui.ResetOnSpawn,gui.DisplayOrder="LastOrdersLoading",false,80
local group=Instance.new("CanvasGroup") group.Size,group.BackgroundColor3=UDim2.fromScale(1,1),UI.Ink group.Parent=gui
local card=UI.title(group)
local status=UI.text(card,"LoadingStatus","Preparing the tavern…",UI.Body,16,UI.Muted,5)
status.TextXAlignment=Enum.TextXAlignment.Center
gui.Parent=player:WaitForChild("PlayerGui")
while player:GetAttribute("LastOrdersStage")==nil or not player.Character do
    task.wait(.1)
    if not gui.Parent then return end
end
local fade=TweenService:Create(group,TweenInfo.new(.35),{GroupTransparency=1})
fade:Play() fade.Completed:Wait() gui:Destroy()
