--!strict
-- Real openings in disposable runtime walls; invisible panes preserve solid/sight boundaries.
local Props=require(script.Parent.PubProps)
local Windows={}
type Add=(string,CFrame,Vector3?,{Instance}?,Instance?,string?)->Part
function Windows.build(map: Folder,add: Add)
    local folder=Instance.new("Folder") folder.Name,folder.Parent="StormViewWindows",map
    local oldNames={WindowRecess=true,StainedGlass=true,PointedGlass=true,LeadMullion=true,LeadCrossbar=true,
        GlassDiamond=true,PointedWindowFrame=true,WarmWindow=true,PointedWindow=true,WindowLead=true}
    for _,p in map:GetDescendants() do
        if p:IsA("BasePart") and math.abs(p.Position.X)>46.8 and p.Position.Y<31 and (oldNames[p.Name] or (p.Name=="GothicTimber" and p.Position.Y>8 and p.Position.Y<14 and p.Color==Color3.fromRGB(158,113,51))) then p:Destroy() end
    end
    local function split(wall: BasePart,holes: {{number}})
        local bottom,top=wall.Position.Y-wall.Size.Y/2,wall.Position.Y+wall.Size.Y/2
        local start,finish=wall.Position.Z-wall.Size.Z/2,wall.Position.Z+wall.Size.Z/2
        local function panel(z0: number,z1: number,y0: number,y1: number)
            if z1-z0<0.01 or y1-y0<0.01 then return end
            local p=wall:Clone() p.Name=wall.Name.."Segment"
            p.Size,p.Position=Vector3.new(wall.Size.X,y1-y0,z1-z0),Vector3.new(wall.Position.X,(y0+y1)/2,(z0+z1)/2)
            p:SetAttribute("BlocksNavigation",true) p.Parent=map
        end
        table.sort(holes,function(a,b) return a[1]<b[1] end)
        local cursor=start
        for _,h in holes do
            local z0,z1=h[1]-h[2]/2,h[1]+h[2]/2
            panel(cursor,z0,bottom,top) panel(z0,z1,bottom,h[3]) panel(z0,z1,h[4],top)
            -- Preserve original collision and monster sight semantics while allowing the camera view.
            local barrier=wall:Clone() barrier.Name="WindowBarrier"
            barrier.Size,barrier.Position=Vector3.new(wall.Size.X,h[4]-h[3],h[2]),Vector3.new(wall.Position.X,(h[3]+h[4])/2,h[1])
            barrier.Transparency,barrier.CanCollide,barrier.CanQuery=1,true,true
            barrier:SetAttribute("BlocksNavigation",true) barrier.Parent=folder
            cursor=z1
        end
        panel(cursor,finish,bottom,top) wall:Destroy()
    end
    local function window(prefix: string,side: number,z: number,base: number)
        local w,h,columns=if prefix=="Bedroom" then 4.4 else 6.6,if prefix=="Bedroom" then 5.4 else 5.8,if prefix=="Bedroom" then 2 else 3
        local cf=CFrame.new(side*48,base,z)*CFrame.Angles(0,-side*math.pi/2,0)
        -- Extend just the native reveal to match the existing one-stud wall thickness.
        local fallback: {Instance}={}
        for _,x in {-w/2+0.14,w/2-0.14} do
            local p=Props.part(folder,"FallbackWindowFrame",Vector3.new(0.28,h,0.7),cf*CFrame.new(x,0.25+h/2,0),Color3.fromRGB(66,34,20)) table.insert(fallback,p)
        end
        for _,y in {0.39,0.25+h-0.14} do
            local p=Props.part(folder,"FallbackWindowFrame",Vector3.new(w,0.28,0.7),cf*CFrame.new(0,y,0),Color3.fromRGB(66,34,20)) table.insert(fallback,p)
        end
        for _,x in {-w/2+0.06,w/2-0.06} do
            Props.part(folder,"WindowReveal",Vector3.new(0.12,h,1),cf*CFrame.new(x,0.25+h/2,0),Color3.fromRGB(80,43,25))
        end
        add(prefix.."WindowFrame",cf,nil,fallback,nil,nil)
        add(prefix.."CurtainPair",cf,nil,nil,nil,nil)
        local iw,ih=w-0.56,h-0.56
        for i=0,columns-1 do for j=0,2 do
            local glass=Props.part(folder,"ClearWindowPane",Vector3.new(iw/columns-0.07,ih/3-0.07,0.025),
                cf*CFrame.new(-iw/2+iw*(i+0.5)/columns,0.53+ih*(j+0.5)/3,-0.065),Color3.fromRGB(190,207,216),Enum.Material.Glass)
            glass.Transparency,glass.Reflectance,glass.CastShadow=0.9,0.02,false
        end end
    end
    local ground={}
    for _,p in map:GetChildren() do
        if p:IsA("BasePart") and (p.Name=="WestWall" or p.Name=="EastWall") then table.insert(ground,p) end
    end
    for _,wall in ground do
        local side=if wall.Position.X<0 then -1 else 1
        local a,b=if side<0 then -28 else -27,if side<0 then 26 else 27
        split(wall,{{a,4.4,4.05,9.45},{b,6.6,4.05,9.85}})
        window("Bedroom",side,a,3.8) window("Pub",side,b,3.8)
    end
    local upper={}
    for _,p in map:GetChildren() do if p:IsA("BasePart") and p.Name=="GuestOuterWall" then table.insert(upper,p) end end
    for _,wall in upper do
        local side=if wall.Position.X<0 then -1 else 1
        local holes={}
        for _,z in {-30,-10,10,30} do table.insert(holes,{z,4.4,20.25,25.65}) end
        split(wall,holes)
        for _,z in {-30,-10,10,30} do window("Bedroom",side,z,20) end
    end
    folder:SetAttribute("WindowCount",12)
end
return Windows
