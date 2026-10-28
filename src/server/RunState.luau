--!strict
local RunState = {}
export type State = { stage: number }
function RunState.new(): State
    return { stage = 0 }
end
function RunState.advance(state: State, expected: number): boolean
    if state.stage ~= expected or expected < 0 or expected > 6 then
        return false
    end
    state.stage += 1
    return true
end
return RunState
