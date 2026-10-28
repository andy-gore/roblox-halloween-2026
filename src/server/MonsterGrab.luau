--!strict
-- A visible windup followed by a fresh reach check lets the player dodge a grab.
local Config = require(game.ReplicatedStorage:WaitForChild("HalloweenShared"):WaitForChild("Config"))
local Grab = {}
function Grab.new(clock: (() -> number)?)
    local time = clock or os.clock
    local mode, endsAt = "Ready", 0
    local contact = false
    local controller = {}
    function controller.reset() mode, endsAt, contact = "Ready", 0, false end
    function controller.step(inReach: boolean, touching: boolean?): string
        local now = time()
        -- Running through his body commits the grab; dodging around him still works.
        if mode == "Grab" and touching then contact = true end
        if mode == "Grab" and now >= endsAt then
            mode, endsAt = "Recover", now + Config.GrabRecoverySeconds
            if inReach or contact then return "Caught" end
        end
        if mode == "Recover" and now >= endsAt then mode = "Ready" end
        if mode == "Ready" and inReach then
            mode, endsAt = "Grab", now + Config.GrabWindupSeconds
            contact = touching == true
        end
        return mode
    end
    return controller
end
return Grab
