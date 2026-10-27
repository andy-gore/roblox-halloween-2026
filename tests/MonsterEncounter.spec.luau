--!strict
-- Studio server Command Bar, in Edit mode. Controlled time avoids waiting through drinks.
local server=game.ServerScriptService:WaitForChild("HalloweenServer")
local Config=require(game.ReplicatedStorage.HalloweenShared.Config)
local now=0
local root=Instance.new("Part")
local ok,err=pcall(function()
    local encounter=require(server.MonsterEncounter).new(root,function() return now end)
    assert(root:GetAttribute("MonsterMode")=="Dormant")
    assert(not encounter.step(false))
    encounter.wake()
    assert(root:GetAttribute("MonsterMode")=="Reveal" and not encounter.step(false))
    now=Config.MonsterRevealSeconds
    local move,message=encounter.step(false)
    assert(move and message=="LAST ORDERS! Run!" and root:GetAttribute("MonsterMode")=="Hunt")
    for _=1,Config.MonsterMaxDrinkBoosts+2 do
        now+=Config.MonsterDrinkInterval
        assert(not encounter.step(false) and root:GetAttribute("MonsterMode")=="Chug")
        now+=Config.MonsterChugSeconds
        assert(encounter.step(false))
    end
    assert(root:GetAttribute("DrinkCount")==Config.MonsterMaxDrinkBoosts)
    assert(encounter.speed(Config.ChaseSpeed)==Config.ChaseSpeed+Config.MonsterMaxDrinkBoosts*Config.MonsterDrinkSpeedBoost)
    now+=Config.MonsterDrinkInterval
    assert(not encounter.step(false))
    assert(encounter.step(true) and root:GetAttribute("MonsterMode")=="Distracted", "Bell must interrupt chugging")
    assert(encounter.step(false) and root:GetAttribute("MonsterMode")=="Hunt")
    encounter.stop()
    assert(not encounter.step(false) and root:GetAttribute("MonsterMode")=="Stopped")
    encounter.reset()
    assert(root:GetAttribute("DrinkCount")==0 and root:GetAttribute("MonsterMode")=="Dormant")
    assert(encounter.speed(Config.ChaseSpeed)==Config.ChaseSpeed)
end)
root:Destroy()
assert(ok,tostring(err))
print("Monster reveal, chug, distraction, speed cap and reset checks passed")
