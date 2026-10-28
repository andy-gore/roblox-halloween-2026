--!strict
-- Run health is separate from Humanoid health so a fatal hit can finish its holding scene.
local Config=require(game.ReplicatedStorage:WaitForChild("HalloweenShared"):WaitForChild("Config"))
local Survival={}
function Survival.new(clock: (() -> number)?)
    local time=clock or os.clock
    local health,phase,endsAt,protectedUntil=Config.PlayerMaxHealth,"Ready",0,0
    local controller={}
    function controller.reset()
        health,phase,endsAt,protectedUntil=Config.PlayerMaxHealth,"Ready",0,0
    end
    function controller.health(): number return health end
    function controller.phase(): string return phase end
    function controller.protected(): boolean return time()<protectedUntil end
    function controller.locked(): boolean return phase=="Held" or phase=="GameOver" end
    function controller.hit(): boolean
        if phase~="Ready" or health<=0 or time()<protectedUntil then return false end
        health-=1
        phase,endsAt="Held",time()+Config.PlayerHoldSeconds
        return true
    end
    function controller.step(): string?
        local now=time()
        if now<endsAt then return nil end
        if phase=="Held" then
            if health==0 then
                phase,endsAt="GameOver",now+Config.GameOverSeconds
                return "GameOver"
            end
            phase,endsAt="Recovery",now+Config.MonsterHitRecoverySeconds
            protectedUntil=now+Config.PlayerHitProtectionSeconds
            return "Release"
        elseif phase=="Recovery" then
            phase="Ready"
        elseif phase=="GameOver" then
            -- Deliver the restart event once; reset owns the next run.
            phase="Finished"
            return "Restart"
        end
        return nil
    end
    function controller.finish()
        phase,endsAt,protectedUntil="Ready",0,0
    end
    return controller
end
return Survival
