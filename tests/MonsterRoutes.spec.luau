--!strict
-- Studio Edit server Command Bar: fewer edges must not outweigh a shorter walk.
local Routes=require(game.ServerScriptService.HalloweenServer.MonsterRoutes)
local nodes={Vector3.zero,Vector3.new(0,0,100),Vector3.new(3,0,0),Vector3.new(6,0,0),Vector3.new(10,0,0)}
local graph=Routes.new(nodes,{{2,3},{1,5},{1,4},{3,5},{2,4}})
local route=graph.path(1,5)
assert(#route==4 and route[2]==3 and route[3]==4,"Choose ten-stud route over two-edge detour")
local reverse=graph.path(5,1)
assert(#reverse==4 and reverse[2]==4 and reverse[3]==3)
local junction=Routes.new({Vector3.zero,Vector3.new(20,0,0),Vector3.new(-20,0,0),Vector3.new(0,0,20),Vector3.new(0,0,-20)},{{2,3,4,5},{1},{1},{1},{1}})
local checks=junction.search(1,Vector3.xAxis)
assert(#checks==3 and checks[1]==2,"Check the witnessed escape direction before alternative branches")
assert(checks[1]~=checks[2] and checks[2]~=checks[3],"Check distinct exits, not the same branch repeatedly")
local isolated=Routes.new({Vector3.zero,Vector3.xAxis},{{},{}})
assert(#isolated.path(1,2)==0 and #isolated.search(1,Vector3.xAxis)==0)
print("Routes: physical-distance shortcuts, reverse paths, directional search and disconnected routes passed")
