--!strict
-- Edit-mode regression: preserve content/physics and permit safe repeat styling.
local server=game.ServerScriptService.HalloweenServer:Clone()
server.Name="TavernSignsSpecServer" server.Parent=game.ServerScriptService
local map: Folder?=nil
local ok,err=pcall(function()
    map=require(server.PrototypeMap).build()
    local fixture=map :: Folder
    fixture.Name="TavernSignsSpec"
    local labels: {[TextLabel]: string}={}
    local boards: {[BasePart]: {any}}={}
    local count=0
    for _,gui in fixture:GetDescendants() do
        if not gui:IsA("SurfaceGui") then continue end
        local board=gui.Parent
        if not board or not board:IsA("BasePart") then continue end
        if gui:GetAttribute("SignFinish")=="RefinedTavern" then
            count+=1
            boards[board]={board.CFrame,board.Size,board.CanCollide,board.CanQuery,board.CanTouch}
            for _,label in gui:GetChildren() do
                if label:IsA("TextLabel") then labels[label]=label.Text end
            end
        elseif board.Name=="Warning" or board.Name=="CellarInstructions" then
            assert(not gui:FindFirstChild("RefinedSignFace"),"Instructional paper was restyled")
        end
    end
    assert(count>=78,"Sign faces missing")
    require(server.TavernSigns).build(fixture)
    for label,text in labels do
        assert(label.Text==text,"Wording/direction changed")
        assert(label.BackgroundTransparency==1 and label.TextColor3==Color3.fromRGB(240,223,188))
        local roots=0
        for _,child in label.Parent:GetChildren() do if child.Name=="RefinedSignFace" then roots+=1 end end
        assert(roots==1,"Repeated styling duplicated the finish")
    end
    for board,original in boards do
        assert(board.CFrame==original[1] and board.Size==original[2],"Sign placement changed")
        assert(board.CanCollide==original[3] and board.CanQuery==original[4] and board.CanTouch==original[5],"Sign physics changed")
    end
    local numbers={}
    local plaques=0
    for _,marker in fixture.AssetPlacements:GetChildren() do
        if marker:GetAttribute("AssetName")=="BedroomNumberBlank" then plaques+=1 end
        if marker:IsA("BasePart") and marker.Name=="BedroomPlaqueLettering" then
            numbers[marker:GetAttribute("RoomNumber")]=true
            assert(not marker.CanCollide and not marker.CanQuery and not marker.CanTouch)
            local gui=marker:FindFirstChildOfClass("SurfaceGui") :: SurfaceGui
            assert((gui:FindFirstChildOfClass("TextLabel") :: TextLabel).Text==tostring(marker:GetAttribute("RoomNumber")))
        end
    end
    assert(plaques==8,"Eight instances must share the same original plaque mesh")
    for i=1,8 do assert(numbers[i],"Bedroom number missing") end
    require(server.MonsterNavigation).new(fixture.ChuggernaughtPlaceholder).validate()
    print("Tavern signs: "..count.." faces; wording, repeat styling, physics, eight plaques and navigation passed")
end)
if map then map:Destroy() end
server:Destroy()
assert(ok,tostring(err))
