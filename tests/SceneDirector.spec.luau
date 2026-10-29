--!strict
-- Studio server Command Bar; no live data store calls or real player changes.
local server=game.ServerScriptService.HalloweenServer
local attrs: {[string]: any}={}
local fake={SetAttribute=function(_: any,k: string,v: any) attrs[k]=v end}
local t=0
local saves,ended=0,0
local d=require(server.SceneDirector).new(fake :: any,{},function() ended+=1 end,function() saves+=1 end,function() return t end)
d.start("Arrival",10)
d.request("Begin","Arrival") t=2 d.request("Finish","Arrival")
assert(d.active() and not attrs.LastOrdersSceneSkippable,"First scene cannot be skipped")
t=10 d.step() assert(d.completed("Arrival") and saves==1)
d.start("Arrival",10) assert(attrs.LastOrdersSceneSkippable)
d.request("Finish","Arrival") assert(d.active(),"Finish without begin must fail")
d.request("Begin","Awakening") t=11.1 d.request("Finish","Arrival") assert(d.active(),"Wrong scene begin must fail")
d.request("Begin","Arrival") t=11.6 d.request("Finish","Arrival") assert(d.active())
d.request("Cancel","Arrival") t=12 d.request("Begin","Arrival") t=12.9 d.request("Finish","Arrival") assert(d.active(),"Partial holds cannot accumulate")
t=13.01 d.request("Finish","Arrival") assert(not d.active() and ended==2 and saves==1)
d.start("Awakening",4.5) d.cancel() assert(not d.completed("Awakening"),"Interrupted scenes remain unseen")
local history=require(server.SceneHistory)
local merged=history.merge({Arrival=true,Inventory="ignored",Escape=false},{Awakening=true})
assert(merged.Arrival and merged.Awakening and not merged.Escape and merged.Inventory==nil)
assert(next(history.merge("invalid",{}))==nil)
print("Scene completion, mandatory viewing, continuous holds, cancellation and history merge passed")
