--!strict
-- Studio server Command Bar, in Edit mode. Controlled time avoids waiting through drinks.
local server=game.ServerScriptService:WaitForChild("HalloweenServer")
local Config=require(game.ReplicatedStorage.HalloweenShared.Config)
local now=0
local root=Instance.new("Part")
local ok,err=pcall(function()
    local encounter=require(server.MonsterEncounter).new(root,function() return now end)
    assert(root:GetAttribute("MonsterMode")=="Dormant")
    assert(not encounter.step("Chase"))
    encounter.wake()
    assert(root:GetAttribute("MonsterMode")=="Reveal" and not encounter.step("Chase"))
    now=Config.MonsterRevealSeconds
    local move,message=encounter.step("Chase")
    assert(move and message=="LAST ORDERS! Break his sight, then keep quiet." and root:GetAttribute("MonsterMode")=="Chase")
    for _=1,Config.MonsterMaxDrinkBoosts+2 do
        now+=Config.MonsterDrinkInterval
        assert(not encounter.step("Chase") and root:GetAttribute("MonsterMode")=="Chug")
        now+=Config.MonsterChugSeconds
        assert(encounter.step("Chase"))
    end
    assert(root:GetAttribute("DrinkCount")==Config.MonsterMaxDrinkBoosts)
    assert(encounter.speed(Config.ChaseSpeed)==Config.ChaseSpeed+Config.MonsterMaxDrinkBoosts*Config.MonsterDrinkSpeedBoost)
    now+=Config.MonsterDrinkInterval
    assert(not encounter.step("Chase"))
    assert(encounter.step("Investigate") and root:GetAttribute("MonsterMode")=="Investigate", "Bell must interrupt chugging")
    assert(encounter.step("Chase") and root:GetAttribute("MonsterMode")=="Chase")
    encounter.stop()
    assert(not encounter.step("Chase") and root:GetAttribute("MonsterMode")=="Stopped")
    encounter.reset()
    assert(root:GetAttribute("DrinkCount")==0 and root:GetAttribute("MonsterMode")=="Dormant")
    assert(encounter.speed(Config.ChaseSpeed)==Config.ChaseSpeed)
end)
root:Destroy()
assert(ok,tostring(err))
print("Monster reveal, chug, distraction, speed cap and reset checks passed")
