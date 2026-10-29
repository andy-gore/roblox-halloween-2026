--!strict
-- Display only: cooldown and noise decisions remain on the server.
if workspace:GetAttribute("LastOrdersGreybox") ~= true then return end
local bell = workspace:WaitForChild("LastOrdersPrototype"):WaitForChild("Bell")
local prompt = bell:WaitForChild("ProximityPrompt") :: ProximityPrompt
while bell:IsDescendantOf(workspace) do
    local readyAt = bell:GetAttribute("ReadyAt")
    local remaining = if typeof(readyAt) == "number" then math.max(0, math.ceil(readyAt - workspace:GetServerTimeNow())) else 0
    prompt.ObjectText = if remaining > 0 then "Bell · distraction ready in " .. remaining .. "s" else "Service bell"
    task.wait(0.2)
end
