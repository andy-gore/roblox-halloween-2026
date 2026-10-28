--!strict
-- Authoritative reveal, drinking pauses and bounded threat progression.
local Config=require(game.ReplicatedStorage:WaitForChild("HalloweenShared"):WaitForChild("Config"))
local Encounter={}
function Encounter.new(root: BasePart, clock: (() -> number)?)
    local time = clock or os.clock
    local mode="Dormant"
    local endsAt,nextDrink,drinks=0,math.huge,0
    local function setMode(value: string)
        if mode==value and root:GetAttribute("MonsterMode")==value then return end
        mode=value
        root:SetAttribute("MonsterMode",value)
        root:SetAttribute("MonsterModeStarted",workspace:GetServerTimeNow())
    end
    local controller={}
    function controller.reset()
        drinks,endsAt,nextDrink=0,0,math.huge
        root:SetAttribute("DrinkCount",0)
        setMode("Dormant")
    end
    function controller.wake()
        setMode("Reveal") endsAt=time()+Config.MonsterRevealSeconds
    end
    function controller.stop() setMode("Stopped") end
    function controller.active(): boolean
        return mode~="Dormant" and mode~="Reveal" and mode~="Stopped"
    end
    function controller.speed(base: number): number
        return base+math.min(drinks,Config.MonsterMaxDrinkBoosts)*Config.MonsterDrinkSpeedBoost
    end
    function controller.step(activity: string): (boolean,string?)
        local now=time()
        if mode=="Dormant" or mode=="Stopped" then return false,nil end
        if mode=="Reveal" then
            if now<endsAt then return false,nil end
            nextDrink=now+Config.MonsterDrinkInterval
            setMode(activity) return true,"LAST ORDERS! Break his sight, then keep quiet."
        end
        -- Grabbing or investigating interrupts a drink without granting a boost.
        if activity=="Grab" or activity=="Recover" then
            if mode=="Chug" then nextDrink=now+Config.MonsterDrinkInterval end
            setMode(activity) return false,nil
        end
        if activity=="Investigate" and mode~="Investigate" then
            nextDrink=now+Config.MonsterDrinkInterval
            setMode(activity) return true,nil
        end
        if mode=="Chug" then
            if now<endsAt then return false,nil end
            local previous=drinks
            drinks=math.min(drinks+1,Config.MonsterMaxDrinkBoosts)
            root:SetAttribute("DrinkCount",drinks)
            nextDrink=now+Config.MonsterDrinkInterval
            setMode(activity)
            return true,if drinks>previous then "The Chuggernaught is getting faster." else "He finished his drink. Keep moving."
        end
        if now>=nextDrink then
            endsAt=now+Config.MonsterChugSeconds setMode("Chug") return false,nil
        end
        setMode(activity)
        return true,nil
    end
    controller.reset()
    return controller
end
return Encounter
