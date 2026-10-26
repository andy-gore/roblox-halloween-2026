--!strict
-- In Studio's server Command Bar, run this body after syncing.
local RunState = require(game.ServerScriptService.HalloweenServer.RunState)
local state = RunState.new()
assert(not RunState.advance(state, 2), "Out-of-order action must fail")
assert(not RunState.advance(state, 0), "Invalid action must fail")
for stage = 1, 5 do
    assert(RunState.advance(state, stage), "Expected action must advance")
    assert(not RunState.advance(state, stage), "Repeated action must fail")
end
assert(state.stage == 6, "Theft must lead to escape objective")
assert(RunState.new().stage == 1, "A fresh run must start at the warning")
print("RunState checks passed")
