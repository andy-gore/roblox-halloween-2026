--!strict
-- Recycled local rain columns. Roof hits are sampled before spawning each streak.
local Rain={}
function Rain.new(parent: Folder,count: number)
    local random=Random.new()
    local parts: {Part}={}
    local stops: {number}={}
    local valid: {boolean}={}
    local cast=RaycastParams.new()
    cast.FilterType=Enum.RaycastFilterType.Exclude
    for i=1,count do
        local p=Instance.new("Part") p.Name="RainStreak" p.Size=Vector3.new(0.025,1.8,0.025)
        p.Color,p.Material,p.Transparency=Color3.fromRGB(166,185,210),Enum.Material.Neon,1
        p.Anchored,p.CanCollide,p.CanTouch,p.CanQuery=true,false,false,false
        p.CastShadow,p.Parent=false,parent parts[i]=p valid[i]=false
    end
    local controller={}
    function controller.step(center: Vector3,character: Model?,dt: number)
        cast.FilterDescendantsInstances=if character then {parent,character} else {parent}
        for i,p in parts do
            local offset=p.Position-center
            if not valid[i] or p.Position.Y<=stops[i]+1.2 or Vector2.new(offset.X,offset.Z).Magnitude>44 then
                local x,z=center.X+random:NextNumber(-32,32),center.Z+random:NextNumber(-32,32)
                local hit=workspace:Raycast(Vector3.new(x,center.Y+100,z),Vector3.new(0,-200,0),cast)
                stops[i]=if hit then hit.Position.Y else -30
                local y=math.max(center.Y+random:NextNumber(16,32),stops[i]+random:NextNumber(4,18))
                p.Position=Vector3.new(x,y,z)
                p:SetAttribute("RainStopY",stops[i]) valid[i]=true
            else
                -- Fixed X/Z columns keep roof clipping valid; the streak shape suggests wind.
                p.Position-=Vector3.new(0,42*math.min(dt,0.05),0)
                if p.Position.Y<=stops[i]+1.2 then valid[i]=false end
            end
            p.Transparency=if valid[i] then 0.58 else 1
            p.CFrame=CFrame.lookAt(p.Position,p.Position+Vector3.new(5,-42,2))*CFrame.Angles(math.pi/2,0,0)
        end
    end
    return controller
end
return Rain
