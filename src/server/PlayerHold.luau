--!strict
-- Authoritative reach/lift/lower path; release restores the original safe position.
local Config=require(game.ReplicatedStorage:WaitForChild("HalloweenShared"):WaitForChild("Config"))
local Hold={}
local function smooth(value: number): number
    local t=math.clamp(value,0,1)
    return t*t*(3-2*t)
end
function Hold.new(monster: BasePart, clock: (() -> number)?)
    local time=clock or os.clock
    local release: (() -> ())?=nil
    local animate: (() -> ())?=nil
    local controller={}
    function controller.step()
        if animate then animate() end
    end
    function controller.release()
        local restore=release
        release,animate=nil,nil
        if restore then restore() end
        monster:SetAttribute("HeldChestPosition",nil)
    end
    function controller.begin(character: Model,root: BasePart,humanoid: Humanoid,fatal: boolean?)
        controller.release()
        local original,anchored=root.CFrame,root.Anchored
        local speed,jumpPower,jumpHeight,rotate=humanoid.WalkSpeed,humanoid.JumpPower,humanoid.JumpHeight,humanoid.AutoRotate
        local collisions: {[BasePart]: boolean}={}
        local ray=RaycastParams.new() ray.FilterType=Enum.RaycastFilterType.Exclude
        ray.FilterDescendantsInstances,ray.RespectCanCollide={character,monster},true
        local overlap=OverlapParams.new() overlap.FilterType=Enum.RaycastFilterType.Exclude
        overlap.FilterDescendantsInstances,overlap.RespectCanCollide={character,monster},true
        local basis=CFrame.new(monster.Position-Vector3.new(0,4,0))*monster.CFrame.Rotation
        local function target(height: number): CFrame
            local position=basis:PointToWorldSpace(Vector3.new(-1.7,height,-2.1))
            return CFrame.lookAt(position,Vector3.new(monster.Position.X,position.Y,monster.Position.Z))
        end
        local low,raised=target(3.7),target(4.6)
        local size=Vector3.new(3,5.4,2.5)
        local function clear(a: CFrame,b: CFrame): boolean
            local delta=b.Position-a.Position
            return #workspace:GetPartBoundsInBox(b,size,overlap)==0
                and (delta.Magnitude<0.01 or workspace:Blockcast(a,size,delta,ray)==nil)
        end
        -- Validate every leg of the motion, including overhead clearance for the lift.
        if not clear(original,low) or not clear(low,raised) then low,raised=original,original end
        for _,part in character:GetDescendants() do
            if part:IsA("BasePart") then collisions[part]=part.CanCollide part.CanCollide=false end
        end
        root.Anchored=true
        root.AssemblyLinearVelocity,root.AssemblyAngularVelocity=Vector3.zero,Vector3.zero
        humanoid.WalkSpeed,humanoid.JumpPower,humanoid.JumpHeight,humanoid.AutoRotate=0,0,0,false
        humanoid.Jump=false
        local started=time()
        animate=function()
            if not root.Parent then return end
            local elapsed=time()-started
            if elapsed<0.24 then root.CFrame=original:Lerp(low,smooth(elapsed/0.24))
            elseif elapsed<0.55 then root.CFrame=low:Lerp(raised,smooth((elapsed-0.24)/0.31))
            elseif fatal or elapsed<Config.PlayerHoldSeconds-0.4 then root.CFrame=raised
            else root.CFrame=raised:Lerp(original,smooth((elapsed-Config.PlayerHoldSeconds+0.4)/0.4)) end
            monster:SetAttribute("HeldChestPosition",root.Position+Vector3.new(0,0.8,0))
        end
        controller.step()
        release=function()
            for part,collidable in collisions do if part.Parent then part.CanCollide=collidable end end
            if root.Parent then
                root.CFrame=original
                root.AssemblyLinearVelocity,root.AssemblyAngularVelocity=Vector3.zero,Vector3.zero
                root.Anchored=anchored
                if not anchored then pcall(function() root:SetNetworkOwnershipAuto() end) end
            end
            if humanoid.Parent then
                humanoid.WalkSpeed,humanoid.JumpPower,humanoid.JumpHeight,humanoid.AutoRotate=speed,jumpPower,jumpHeight,rotate
            end
        end
    end
    return controller
end
return Hold
