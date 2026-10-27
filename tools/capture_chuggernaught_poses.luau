--!strict
-- Studio Edit Command Bar: save the printed JSON to build/chuggernaught-pose-frames.json.
local pose=require(game.StarterPlayer.StarterPlayerScripts.HalloweenClient.ChuggernaughtPose)
local result: {[string]: {[string]: {number}}}={}
for _,name in {"Idle","Hunt","Chug"} do
    local frames=pose.frames(CFrame.identity,if name=="Hunt" then math.pi/2 else 0,name=="Hunt",if name=="Chug" then "Chug" else "Hunt",if name=="Chug" then 1.4 else 5,2.8)
    local out: {[string]: {number}}={}
    for joint,cf in frames do out[joint]={cf:GetComponents()} end
    result[name]=out
end
print(game:GetService("HttpService"):JSONEncode(result))
