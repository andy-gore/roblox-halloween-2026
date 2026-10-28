--!strict
-- Sight, remembered movement and audible footsteps drive the hunt, never hidden live positions.
local Config = require(game.ReplicatedStorage:WaitForChild("HalloweenShared"):WaitForChild("Config"))
local Hunt = {}
type Planner = (Vector3, Vector3) -> {Vector3}
function Hunt.new(patrol: {Vector3}, clock: (() -> number)?, plan: Planner?)
    assert(#patrol > 0, "A hunt needs patrol destinations")
    local time = clock or os.clock
    local index = 1
    local lastKnown: Vector3? = nil
    local lastSight: Vector3? = nil
    local sightAt, chaseUntil, alertUntil = -math.huge, 0, 0
    local direction = Vector3.zero
    local checks: {Vector3} = {}
    local checkIndex, lookUntil, nextFootstep = 1, 0, 0
    local planned = false
    local noise: Vector3? = nil
    local noiseUntil, bellReady = 0, 0
    local mode = "Patrol"
    local controller = {}
    function controller.reset()
        index, lastKnown, lastSight, noise, mode = 1, nil, nil, nil, "Patrol"
        sightAt, chaseUntil, alertUntil = -math.huge, 0, 0
        direction, checks, checkIndex, lookUntil, nextFootstep = Vector3.zero, {}, 1, 0, 0
        planned, noiseUntil, bellReady = false, 0, 0
    end
    function controller.alert(): boolean
        return time() < alertUntil
    end
    function controller.ringBell(position: Vector3): boolean
        local now = time()
        if now < bellReady then return false end
        bellReady, noiseUntil = now + Config.BellCooldownSeconds, now + Config.DistractionSeconds
        noise, alertUntil = position, math.max(alertUntil, noiseUntil)
        return true
    end
    function controller.alarm(position: Vector3)
        lastKnown,noise,planned=position,nil,false
        direction=Vector3.new(0,0,1)
        chaseUntil,alertUntil=time()+Config.SightMemorySeconds,time()+40
    end
    function controller.bellCooldown(): number
        return math.max(0, bellReady - time())
    end
    function controller.hearFootstep(position: Vector3): boolean
        local now = time()
        if now < nextFootstep then return false end
        nextFootstep = now + Config.FootstepInterval
        lastKnown, noise, planned = position, nil, false
        chaseUntil = 0
        alertUntil = math.max(alertUntil, now + Config.FootstepMemorySeconds)
        return true
    end
    function controller.step(position: Vector3, playerPosition: Vector3, visible: boolean): (Vector3, string, boolean)
        local now = time()
        if visible then
            local previous = lastSight
            local elapsed = now - sightAt
            -- Replicated positions arrive in bursts; sample across several heartbeats.
            if previous and elapsed >= 0.1-0.00001 and elapsed < 0.5 then
                local movement = playerPosition - previous
                if movement.Magnitude > 0.05 and movement.Magnitude / elapsed < 30 then direction = movement.Unit end
                lastSight, sightAt = playerPosition, now
            elseif not previous or elapsed >= 0.5 then
                direction, lastSight, sightAt = Vector3.zero, playerPosition, now
            end
            lastKnown = playerPosition
            noise, planned = nil, false
            chaseUntil, alertUntil = now + Config.SightMemorySeconds, now + Config.SearchSeconds
            mode = "Chase"
            return playerPosition, mode, false
        end
        local heard = noise
        if heard and now < noiseUntil then
            lastKnown, planned, mode = nil, false, "Investigate"
            return heard, mode, (position - heard).Magnitude < 3
        end
        noise = nil
        local remembered = lastKnown
        if remembered and now < alertUntil then
            if now < chaseUntil then
                mode = "Chase"
                return remembered, mode, false
            end
            mode = "Search"
            if not planned then
                checks, checkIndex, lookUntil = {remembered}, 1, 0
                if plan then
                    for _,point in plan(remembered, direction) do
                        if (point - remembered).Magnitude > 4 then table.insert(checks, point) end
                    end
                end
                planned = true
            end
            while checkIndex <= #checks and (position - checks[checkIndex]).Magnitude < 3 do
                -- Keep moving through the last sighting; inspect subsequent exits briefly.
                if checkIndex > 1 then
                    if lookUntil == 0 then lookUntil = now + Config.SearchLookSeconds end
                    if now < lookUntil then return checks[checkIndex], mode, true end
                end
                checkIndex += 1
                lookUntil = 0
            end
            local target = checks[checkIndex]
            return target or checks[#checks], mode, target == nil
        end
        lastKnown, lastSight, planned = nil, nil, false
        -- Resume locally after a thorough search rather than walking back to the cellar.
        if mode ~= "Patrol" then
            local nearest = math.huge
            for i, destination in patrol do
                local distance = (destination - position).Magnitude
                if distance < nearest then index, nearest = i, distance end
            end
        end
        mode = "Patrol"
        if (position - patrol[index]).Magnitude < 3 then index = index % #patrol + 1 end
        return patrol[index], mode, false
    end
    return controller
end
return Hunt
