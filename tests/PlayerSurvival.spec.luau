--!strict
-- Studio Edit server Command Bar. No real waits; two grabs are required for a restart.
local server=game.ServerScriptService.HalloweenServer
local Config=require(game.ReplicatedStorage.HalloweenShared.Config)
local now=0
local survival=require(server.PlayerSurvival).new(function() return now end)
assert(survival.health()==2 and survival.phase()=="Ready")
assert(survival.hit() and survival.health()==1 and survival.locked())
assert(not survival.hit(),"One hold must not consume both hits")
now=Config.PlayerHoldSeconds-0.01
assert(survival.step()==nil and survival.locked())
now+=0.02
assert(survival.step()=="Release" and survival.phase()=="Recovery")
assert(not survival.locked() and survival.protected() and not survival.hit())
now+=Config.MonsterHitRecoverySeconds
survival.step()
assert(survival.phase()=="Ready" and survival.protected() and not survival.hit(),"Protection must outlast the monster's pause")
now+=Config.PlayerHitProtectionSeconds
assert(not survival.protected() and survival.hit() and survival.health()==0)
assert(survival.phase()=="Held" and not survival.hit(),"Fatal hit must still show the hold first")
now+=Config.PlayerHoldSeconds
assert(survival.step()=="GameOver" and survival.locked())
now+=Config.GameOverSeconds-0.01
assert(survival.step()==nil)
now+=0.02
assert(survival.step()=="Restart" and survival.step()==nil,"One fatal hit must request exactly one restart")
survival.reset()
assert(survival.health()==2 and not survival.locked() and not survival.protected())
survival.hit() now+=Config.PlayerHoldSeconds survival.step()
survival.finish()
assert(survival.health()==1 and survival.phase()=="Ready" and not survival.protected(),"Victory should keep surviving health and clear recovery")
survival.reset()
survival.hit() survival.reset()
assert(survival.health()==2 and survival.step()==nil,"Reset during a hold must cancel the old sequence")
local root=Instance.new("Part")
local ok,err=pcall(function()
    local encounter=require(server.MonsterEncounter).new(root,function() return now end)
    encounter.wake() now+=Config.MonsterRevealSeconds encounter.step("Chase")
    now+=Config.MonsterDrinkInterval encounter.step("Chase") now+=Config.MonsterChugSeconds encounter.step("Chase")
    local drinks=root:GetAttribute("DrinkCount")
    for _,phase in {"Hold","Stunned","Defeat"} do
        assert(not encounter.step(phase) and root:GetAttribute("MonsterMode")==phase)
        assert(root:GetAttribute("DrinkCount")==drinks,"Hit presentation must preserve drink progression")
    end
end)
root:Destroy()
assert(ok,tostring(err))
print("Survival: two hits, hold/release, recovery/protection, fatal sequence, reset and preserved drink count passed")
