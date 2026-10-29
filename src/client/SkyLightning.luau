--!strict
-- One brief distant bolt per storm event. Outdoor fill restores after the flash/cleanup.
local TweenService=game:GetService("TweenService")
local Lighting=game:GetService("Lighting")
local Sky={}
function Sky.new(folder: Folder)
    local ambient=Lighting.OutdoorAmbient
    local tween: Tween?=nil
    local random=Random.new()
    local controller={}
    function controller.flash()
        if tween then tween:Cancel() end
        Lighting.OutdoorAmbient=Color3.fromRGB(165,184,224)
        tween=TweenService:Create(Lighting,TweenInfo.new(.38),{OutdoorAmbient=ambient}) tween:Play()
        local origin=Vector3.new(random:NextNumber(-100,100),130,random:NextNumber(-90,30))
        local previous=origin
        local function segment(a: Vector3,b: Vector3,width: number)
            local p=Instance.new("Part") p.Name="DistantLightningBolt" p.Size=Vector3.new(width,width,(b-a).Magnitude)
            p.CFrame,p.Anchored,p.Material=CFrame.lookAt((a+b)/2,b),true,Enum.Material.Neon
            p.CanCollide,p.CanQuery,p.CanTouch=false,false,false
            p.Color,p.Parent=Color3.fromRGB(210,228,255),folder
            TweenService:Create(p,TweenInfo.new(.35),{Transparency=1}):Play()
            task.delay(.45,function() p:Destroy() end)
        end
        for i=1,5 do
            local point=origin+Vector3.new(random:NextNumber(-8,8),-i*12,random:NextNumber(-4,4))
            segment(previous,point,.32)
            if i==3 then segment(point,point+Vector3.new(16,-16,3),.16) end
            previous=point
        end
    end
    function controller.destroy()
        if tween then tween:Cancel() end
        Lighting.OutdoorAmbient=ambient
    end
    return controller
end
return Sky
