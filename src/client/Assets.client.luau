--!strict
if workspace:GetAttribute("LastOrdersGreybox")~=true then return end
local map=workspace:WaitForChild("LastOrdersPrototype") :: Folder
require(script.Parent.PropRenderer).new(map)
