--!strict
local RunState = {}
export type State = { stage: number }
function RunState.new(): State
    return { stage = 1 }
end
function RunState.advance(state: State, expected: number): boolean
    if state.stage ~= expected or expected < 1 or expected > 5 then
        return false
    end
    state.stage += 1
    return true
end
return RunState
