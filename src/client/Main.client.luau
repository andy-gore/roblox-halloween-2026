--!strict
local Players = game:GetService("Players")
local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("HalloweenShared"):WaitForChild("Config"))
local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "LastOrdersHUD"
gui.ResetOnSpawn = false
local label = Instance.new("TextLabel")
label.Size = UDim2.new(0.9, 0, 0, 130)
label.Position = UDim2.fromScale(0.05, 0.02)
label.BackgroundColor3 = Color3.fromRGB(24, 20, 28)
label.BackgroundTransparency = 0.15
label.TextColor3 = Color3.fromRGB(255, 224, 170)
label.Font = Enum.Font.GothamMedium
label.TextSize = 18
label.TextWrapped = true
label.Parent = gui
local function update()
    local stage = player:GetAttribute("LastOrdersStage")
    local objective = if typeof(stage) == "number" then Config.Objectives[stage] else "Waiting for the local prototype…"
    local message = player:GetAttribute("LastOrdersMessage")
    label.Size=UDim2.new(0.9,0,0,if stage==2 then 180 else 130)
    if stage==2 then
        local progress=player:GetAttribute("CellarBreakerProgress")
        if typeof(progress)=="number" then
            objective=(objective or "").."\nCircuits: "..progress.."/3. "..(if progress==3 then "MAIN LEVER READY." else "Read the card, then flip the switches.")
        end
    end
    label.Text = Config.Title .. "\n" .. (objective or "") .. "\n" .. (if typeof(message) == "string" then message else "")
end
player:GetAttributeChangedSignal("LastOrdersStage"):Connect(update)
player:GetAttributeChangedSignal("LastOrdersMessage"):Connect(update)
player:GetAttributeChangedSignal("CellarBreakerProgress"):Connect(update)
update()
gui.Parent = player:WaitForChild("PlayerGui")
