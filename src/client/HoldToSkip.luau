--!strict
local Input=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local UI=require(script.Parent.TavernUI)
local Hold={}
function Hold.new(gui: ScreenGui,player: Player)
    local remote=game.ReplicatedStorage.HalloweenShared:WaitForChild("SceneRequest") :: RemoteEvent
    local button=Instance.new("TextButton") button.Name="HoldToSkip" button.Text=""
    button.Size,button.Position=UDim2.fromOffset(200,48),UDim2.new(1,-212,0,12)
    button.BackgroundColor3,button.BackgroundTransparency,button.BorderSizePixel=UI.Ink,.04,0 button.Visible=false button.Parent=gui
    local label=Instance.new("TextLabel") label.Name="Label" label.Size,label.Position=UDim2.new(1,-52,1,0),UDim2.fromOffset(48,0)
    label.BackgroundTransparency,label.FontFace,label.TextSize,label.TextColor3=1,UI.Body,17,UI.Ivory
    label.Text,label.Parent="Hold to skip",button
    local segments: {Frame}={}
    for i=1,32 do
        local a=(i-1)/32*math.pi*2
        local s=Instance.new("Frame") s.Name="Progress"..i s.AnchorPoint=Vector2.new(.5,.5)
        s.Position,s.Size=UDim2.fromOffset(24+math.sin(a)*14,24-math.cos(a)*14),UDim2.fromOffset(3,4)
        s.Rotation,s.BorderSizePixel,s.BackgroundColor3,s.Parent=math.deg(a),0,UI.Muted,button table.insert(segments,s)
    end
    local held: InputObject?=nil
    local started=0
    local heldScene=""
    local sent=false
    local connections: {RBXScriptConnection}={}
    local function eligible(): boolean
        return player:GetAttribute("LastOrdersSceneSkippable")==true and player:GetAttribute("LastOrdersScene")~=""
    end
    local function cancel()
        if held then remote:FireServer("Cancel",heldScene) end
        held=nil started=0 sent=false
    end
    local function begin(input: InputObject)
        if held or not eligible() then return end
        held=input started=os.clock() sent=false heldScene=player:GetAttribute("LastOrdersScene") :: string
        remote:FireServer("Begin",heldScene)
    end
    table.insert(connections,button.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then begin(input) end
    end))
    table.insert(connections,Input.InputBegan:Connect(function(input,processed)
        if not processed and (input.KeyCode==Enum.KeyCode.Space or input.KeyCode==Enum.KeyCode.ButtonB) then begin(input) end
    end))
    table.insert(connections,Input.InputEnded:Connect(function(input)
        if input==held or (held and input.KeyCode==held.KeyCode and input.KeyCode~=Enum.KeyCode.Unknown) then cancel() end
    end))
    table.insert(connections,Input.InputChanged:Connect(function(input)
        if input==held and input.UserInputState==Enum.UserInputState.Cancel then cancel() end
        if input==held and input.UserInputType==Enum.UserInputType.Touch then
            local pos,size=button.AbsolutePosition,button.AbsoluteSize
            if input.Position.X<pos.X or input.Position.X>pos.X+size.X or input.Position.Y<pos.Y or input.Position.Y>pos.Y+size.Y then cancel() end
        end
    end))
    table.insert(connections,Input.WindowFocusReleased:Connect(cancel))
    table.insert(connections,player:GetAttributeChangedSignal("LastOrdersScene"):Connect(cancel))
    table.insert(connections,RunService.RenderStepped:Connect(function()
        button.Visible=eligible()
        if not button.Visible then cancel() end
        local progress=if held then math.clamp((os.clock()-started)/1.05,0,1) else 0
        for i,s in segments do s.BackgroundColor3=if i<=math.floor(progress*32) then UI.Brass else Color3.fromRGB(70,62,55) end
        if held and progress>=1 and not sent then sent=true remote:FireServer("Finish",heldScene) end
    end))
    return function() cancel() for _,c in connections do c:Disconnect() end button:Destroy() end
end
return Hold
