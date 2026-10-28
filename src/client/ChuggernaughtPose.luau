--!strict
-- Joint poses in the original model's floor-centred coordinate space; no uploaded animations.
local Pose = {}
local function smooth(value: number): number
    local t=math.clamp(value,0,1)
    return t*t*(3-2*t)
end
local function rotation(from: Vector3, to: Vector3): CFrame
    local a,b=from.Unit,to.Unit
    local axis=a:Cross(b)
    if axis.Magnitude<0.00001 then return CFrame.identity end
    return CFrame.fromAxisAngle(axis.Unit,math.acos(math.clamp(a:Dot(b),-1,1)))
end
local function rightArm(hand: Vector3): (CFrame,CFrame)
    local shoulder=Vector3.new(1.5,6,0)
    local upperBind,lowerBind=Vector3.new(0.5,-1.15,0),Vector3.new(0.05,-1.37,-0.09)
    local delta=hand-shoulder
    local distance=math.clamp(delta.Magnitude,0.1,upperBind.Magnitude+lowerBind.Magnitude-0.001)
    local direction=delta.Unit
    local outward=Vector3.xAxis-direction*direction:Dot(Vector3.xAxis)
    if outward.Magnitude<0.01 then outward=Vector3.zAxis end
    local along=(upperBind.Magnitude^2+distance^2-lowerBind.Magnitude^2)/(2*distance)
    local height=math.sqrt(math.max(0,upperBind.Magnitude^2-along^2))
    local elbow=shoulder+direction*along+outward.Unit*height
    return CFrame.new(shoulder)*rotation(upperBind,elbow-shoulder), CFrame.new(elbow)*rotation(lowerBind,hand-elbow)
end
local function leftArm(hand: Vector3): (CFrame,CFrame)
    local shoulder=Vector3.new(-1.5,6,0)
    local upperBind,lowerBind=Vector3.new(-0.5,-1.15,0),Vector3.new(-0.05,-1.37,-0.09)
    local delta=hand-shoulder
    if delta.Magnitude<0.01 then delta=Vector3.new(0,-1,0) end
    local distance=math.clamp(delta.Magnitude,0.1,upperBind.Magnitude+lowerBind.Magnitude-0.001)
    local direction=delta.Unit
    local outward=-Vector3.xAxis+direction*direction:Dot(Vector3.xAxis)
    if outward.Magnitude<0.01 then outward=Vector3.zAxis end
    local along=(upperBind.Magnitude^2+distance^2-lowerBind.Magnitude^2)/(2*distance)
    local height=math.sqrt(math.max(0,upperBind.Magnitude^2-along^2))
    local elbow=shoulder+direction*along+outward.Unit*height
    local reached=shoulder+direction*distance
    return CFrame.new(shoulder)*rotation(upperBind,elbow-shoulder),CFrame.new(elbow)*rotation(lowerBind,reached-elbow)
end
function Pose.frames(feet: CFrame, phase: number, moving: boolean, mode: string, elapsed: number, duration: number, heldChest: Vector3?): {[string]: CFrame}
    local gait=if moving and mode~="Hold" and mode~="Defeat" then math.sin(phase) else 0
    local drink=0
    if mode=="Reveal" or mode=="Chug" then
        local amount=math.clamp(math.min(elapsed/0.8,(duration-elapsed)/0.7),0,1)
        drink=amount*amount*(3-2*amount)
    end
    local breath=math.sin(elapsed*2)*0.02
    local body=feet*CFrame.new(0,3.5+math.abs(gait)*0.035+breath,0)*CFrame.Angles(0,gait*0.025,-gait*0.015)*CFrame.new(0,-3.5,0)
    if mode=="Hold" then
        local reach=smooth(elapsed/0.24)
        local lift=smooth((elapsed-0.24)/0.31)
        local lower=smooth((elapsed-duration+0.4)/0.4)
        body*=CFrame.new(0,3.5,0)*CFrame.Angles(-0.13*reach*(1-lift)+0.06*lift*(1-lower),0,-0.035*reach*(1-lower))*CFrame.new(0,-3.5,0)
    end
    local standing=CFrame.new(3.4,2.35,-0.09)
    local drinking=CFrame.new(0.3,6.9,-0.8)*CFrame.Angles(0,math.pi,0)*CFrame.Angles(-1.1+math.sin(elapsed*12)*0.035,0,0)*CFrame.new(0,-2.15,0)
    local mug=standing:Lerp(drinking,drink)+Vector3.new(0,0,-math.sin(drink*math.pi)*0.6)
    local upper,lower=rightArm(mug:PointToWorldSpace(Vector3.new(-1.35,1.13,0)))
    local grab=if mode=="Grab" then math.clamp(elapsed/duration,0,1)
        elseif mode=="Recover" then 1-math.clamp(elapsed/duration,0,1) else 0
    local left=body*CFrame.new(-1.5,6,0)*CFrame.Angles(-gait*0.4+grab*1.5,0,0.04)
    local lowerLeft=left*CFrame.new(-0.5,-1.15,0)*CFrame.Angles(0.1,0,0)
    if mode=="Hold" or mode=="Defeat" then
        local target=if heldChest then body:PointToObjectSpace(heldChest) else Vector3.new(-1.7,5.4,-2.1)
        local upperHold,lowerHold=leftArm(target)
        local reach=body*CFrame.new(-1.5,6,0)*CFrame.Angles(1.5,0,0.04)
        local blend=if mode=="Defeat" then 1 else smooth(elapsed/0.18)
        left,lowerLeft=reach:Lerp(body*upperHold,blend),(reach*CFrame.new(-0.5,-1.15,0)*CFrame.Angles(0.1,0,0)):Lerp(body*lowerHold,blend)
    elseif mode=="Stunned" then
        left=body*CFrame.new(-1.5,6,0)*CFrame.Angles(0.25,0,0.15+math.sin(elapsed*5)*0.05)
        lowerLeft=left*CFrame.new(-0.5,-1.15,0)*CFrame.Angles(0.25,0,0)
        if heldChest and elapsed<0.3 then
            local upperRelease,lowerRelease=leftArm(body:PointToObjectSpace(heldChest))
            left,lowerLeft=(body*upperRelease):Lerp(left,smooth(elapsed/0.3)),(body*lowerRelease):Lerp(lowerLeft,smooth(elapsed/0.3))
        end
    end
    return {
        Torso=body*CFrame.new(0,3.5,0),
        Head=body*CFrame.new(0,6.2,0)*CFrame.Angles(drink*0.14,0,0),
        UpperArmLeft=left,
        LowerArmLeft=lowerLeft,
        UpperArmRight=body*upper,LowerArmRight=body*lower,
        LegLeft=feet*CFrame.new(-0.73,3.3,0)*CFrame.Angles(gait*0.4,0,0),
        LegRight=feet*CFrame.new(0.73,3.3,0)*CFrame.Angles(-gait*0.4,0,0),
        Tankard=body*mug,
    }
end
return Pose
