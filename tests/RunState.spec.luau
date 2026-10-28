--!strict
local RunState=require(game.ServerScriptService.HalloweenServer.RunState)
local state=RunState.new()
assert(state.stage==0)
assert(not RunState.advance(state,1))
assert(not RunState.advance(state,-1))
for stage=0,6 do
    assert(RunState.advance(state,stage))
    assert(not RunState.advance(state,stage))
end
assert(state.stage==7)
assert(not RunState.advance(state,7))
assert(RunState.new().stage==0)
print("RunState checks passed")
