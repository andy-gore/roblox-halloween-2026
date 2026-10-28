--!strict
-- Local light sources inside the window reveals; shadowing contains light to connected rooms.
local TweenService=game:GetService("TweenService")
local Lightning={}
function Lightning.new(map: Folder,folder: Folder)
    local lights: {PointLight}={}
    local function source(position: Vector3)
        local p=Instance.new("Part") p.Name="WindowLightningSource" p.Size=Vector3.one*.1
        p.Position,p.Anchored,p.Transparency=position,true,1
        p.CanCollide,p.CanTouch,p.CanQuery=false,false,false p.Parent=folder
        local l=Instance.new("PointLight") l.Name="WindowFlash" l.Color=Color3.fromRGB(185,207,255)
        l.Range,l.Brightness,l.Shadows,l.Parent=38,0,true,p table.insert(lights,l)
    end
    local windows=map:WaitForChild("StormViewWindows")
    for _,p in windows:GetChildren() do
        if p:IsA("BasePart") and p.Name=="WindowBarrier" then
            source(Vector3.new(p.Position.X-math.sign(p.Position.X)*2,p.Position.Y,p.Position.Z))
        end
    end
    -- Front facade windows overlook the tall lounge and two southern bedrooms.
    for _,x in {6,25,40} do source(Vector3.new(x,24,86)) end
    for _,x in {-40,-18} do source(Vector3.new(x,24,38)) end
    local controller={}
    function controller.flash()
        for _,l in lights do
            l.Brightness=3.5
            TweenService:Create(l,TweenInfo.new(.32,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Brightness=0}):Play()
        end
    end
    return controller
end
return Lightning
