--!strict
-- Studio Edit server Command Bar. Controlled time tests memory, sound and dodge windows.
local server=game.ServerScriptService.HalloweenServer
local Config=require(game.ReplicatedStorage.HalloweenShared.Config)
local now=0
local a,b=Vector3.new(0,0.5,0),Vector3.new(30,0.5,0)
local hidden=Vector3.new(500,16.5,500)
local hunt=require(server.MonsterHunt).new({a,b},function() return now end)
local target,mode=hunt.step(a,hidden,false)
assert(mode=="Patrol" and target==b,"Hidden player must not attract patrol")
target,mode=hunt.step(a,b,true)
assert(mode=="Chase" and target==b)
target,mode=hunt.step(a,hidden,false)
assert(mode=="Chase" and target==b,"A corner must not immediately drop pursuit speed")
now=Config.SightMemorySeconds+0.01
target,mode=hunt.step(a,hidden,false)
assert(mode=="Search" and target==b,"Search must retain last sighting, not unseen position")
now+=0.1
local looking
target,mode,looking=hunt.step(b,hidden,false)
assert(mode=="Search" and looking)
now+=Config.SearchSeconds+0.01
target,mode=hunt.step(b,hidden,false)
assert(mode=="Patrol" and target~=hidden,"Search must eventually give up")
assert(hunt.ringBell(a) and not hunt.ringBell(b),"Bell spam must not refresh/retarget investigation")
target,mode=hunt.step(b,hidden,false)
assert(mode=="Investigate" and target==a)
target,mode=hunt.step(b,b,true)
assert(mode=="Chase" and target==b,"Visible player must override bell")
target,mode=hunt.step(b,hidden,false)
assert(mode=="Chase" and target==b,"Bell must not clear recent chase memory")
now+=Config.SightMemorySeconds+0.01
target,mode=hunt.step(b,hidden,false)
assert(mode=="Search" and target==b,"Bell must not grant a safe period after being seen")
now+=Config.BellCooldownSeconds
assert(hunt.ringBell(a),"Bell must become reusable")
now+=Config.DistractionSeconds+0.01
target,mode=hunt.step(b,hidden,false)
assert(mode=="Patrol","Investigation must expire")
hunt.reset()
assert(hunt.bellCooldown()==0 and hunt.ringBell(b),"Reset must clear bell cooldown")
-- Search branches follow observed movement, even when the unseen player goes elsewhere.
local forward,alternate=Vector3.new(20,0.5,0),Vector3.new(0,0.5,20)
local plannedAt,plannedDirection=Vector3.zero,Vector3.zero
local searching=require(server.MonsterHunt).new({a,b},function() return now end,function(position,direction)
    plannedAt,plannedDirection=position,direction
    return {forward,alternate}
end)
searching.step(a,a,true)
now+=0.1
local last=Vector3.new(1,0.5,0)
searching.step(a,last,true)
now+=Config.SightMemorySeconds+0.01
target,mode=searching.step(a,hidden,false)
assert(mode=="Search" and target==forward,"Search must continue beyond the last sighting")
assert(plannedAt==last and plannedDirection:Dot(Vector3.xAxis)>0.9,"Plan must use witnessed heading")
target,mode,looking=searching.step(forward,hidden,false)
assert(looking and target==forward)
now+=Config.SearchLookSeconds+0.01
target,mode=searching.step(forward,hidden,false)
assert(target==alternate and mode=="Search","He must check another escape branch")
assert(searching.alert(),"Search must retain heightened awareness")
assert(searching.hearFootstep(b) and not searching.hearFootstep(hidden),"Only sampled footsteps may retarget")
target,mode=searching.step(a,hidden,false)
assert(target==b and mode=="Search","An audible footstep must supply a fresh known position")
local rememberedTarget=target
target,mode=searching.step(a,Vector3.new(-500,16.5,500),false)
assert(target==rememberedTarget,"Silent unseen movement must not update the trail")
now+=Config.SearchSeconds+0.01
target,mode=searching.step(a,hidden,false)
assert(mode=="Patrol" and not searching.alert(),"Even an expanded search must eventually end")
searching.reset()
assert(not searching.alert())
local burstDirection=Vector3.zero
local burst=require(server.MonsterHunt).new({a,b},function() return now end,function(_,heading)
    burstDirection=heading return {forward}
end)
burst.step(a,a,true)
for frame=1,15 do
    now+=1/60
    burst.step(a,Vector3.new(math.floor(frame/3),0.5,0),true)
end
now+=Config.SightMemorySeconds+0.01
burst.step(a,hidden,false)
assert(burstDirection:Dot(Vector3.xAxis)>0.9,"Replicated movement bursts must retain observed direction")
local grab=require(server.MonsterGrab).new(function() return now end)
assert(grab.step(false)=="Ready")
assert(grab.step(true)=="Grab","Close player must trigger a signalled windup")
now+=Config.GrabWindupSeconds*0.5
assert(grab.step(true)=="Grab","No capture before windup completes")
now+=Config.GrabWindupSeconds
assert(grab.step(false)=="Recover","Leaving reach must dodge the grab")
assert(grab.step(true)=="Recover","Recovery must offer an escape window")
now+=Config.GrabRecoverySeconds+0.01
assert(grab.step(true)=="Grab")
now+=Config.GrabWindupSeconds
assert(grab.step(true)=="Caught","Staying in reach must capture")
grab.reset()
assert(grab.step(false)=="Ready")
assert(grab.step(true)=="Grab")
now+=Config.GrabWindupSeconds/2
assert(grab.step(true,true)=="Grab")
now+=Config.GrabWindupSeconds
assert(grab.step(false)=="Caught","Running through his body must not dodge the grab")
grab.reset()
local root=Instance.new("Part")
local ok,err=pcall(function()
    local encounter=require(server.MonsterEncounter).new(root,function() return now end)
    encounter.wake()
    assert(not encounter.active())
    now+=Config.MonsterRevealSeconds
    encounter.step("Chase")
    assert(encounter.active())
    now+=Config.MonsterDrinkInterval
    assert(not encounter.step("Chase") and root:GetAttribute("MonsterMode")=="Chug")
    assert(encounter.active(),"A drinking monster must remain eligible to grab")
    assert(not encounter.step("Grab") and root:GetAttribute("MonsterMode")=="Grab")
    assert(root:GetAttribute("DrinkCount")==0,"Interrupted drink must not grant strength")
    encounter.step("Recover")
    assert(encounter.step("Search"))
    encounter.reset()
    assert(not encounter.active())
end)
root:Destroy()
assert(ok,tostring(err))
print("Hunt: sight memory, patrol, bell priority/cooldown, dodge, capture and drink interruption passed")
