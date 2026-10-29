--!strict
-- Authoritative first-view eligibility, scene completion and uninterrupted skip holds.
local Director={}
type Flags={[string]: boolean}
function Director.new(player: Player,seen: Flags,onEnd: (string,boolean)->(),onSeen: (Flags)->(),clock: (() -> number)?)
    local time=clock or os.clock
    local scene=""
    local endsAt,holdAt=0,0
    local holding=false
    local function publish()
        player:SetAttribute("LastOrdersScene",scene)
        player:SetAttribute("LastOrdersSceneSkippable",scene~="" and seen[scene]==true)
    end
    local function finish(skipped: boolean)
        local name=scene
        if name=="" then return end
        scene="" holding=false publish()
        if not skipped and not seen[name] then seen[name]=true onSeen(table.clone(seen)) end
        onEnd(name,skipped)
    end
    local controller={}
    function controller.start(name: string,duration: number)
        scene=name endsAt=time()+duration holding=false
        player:SetAttribute("LastOrdersSceneStarted",workspace:GetServerTimeNow())
        player:SetAttribute("LastOrdersSceneDuration",duration)
        publish()
    end
    function controller.active(name: string?): boolean return scene~="" and (name==nil or scene==name) end
    function controller.step() if scene~="" and time()>=endsAt then finish(false) end end
    function controller.request(action: string,expected: string)
        if scene=="" or scene~=expected or not seen[scene] then return end
        if action=="Begin" then
            if not holding then holding=true holdAt=time() end
        elseif action=="Cancel" then holding=false
        elseif action=="Finish" and holding and time()-holdAt>=1 then finish(true) end
    end
    function controller.cancel() scene="" holding=false publish() end
    function controller.completed(name: string): boolean return seen[name]==true end
    publish()
    return controller
end
return Director
