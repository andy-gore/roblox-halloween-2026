--!strict
-- Studio Client Command Bar: controlled structural occlusion, no live character changes.
local Audio=require(game.Players.LocalPlayer.PlayerScripts.HalloweenClient.MonsterAudio)
local folder=Instance.new("Folder") folder.Name="AudioReview" folder.Parent=workspace
local function part(name: string,position: Vector3,size: Vector3): Part
    local p=Instance.new("Part") p.Name,p.Position,p.Size,p.Anchored,p.Parent=name,position,size,true,folder return p
end
local ok,err=pcall(function()
    local root=part("Source",Vector3.new(16000,4,0),Vector3.one)
    local character=Instance.new("Model") character.Parent=folder
    local head=part("Head",Vector3.new(16000,4,10),Vector3.one) head.Parent=character
    local sound=Instance.new("Sound") sound.Volume,sound.Parent=.5,root
    local update=Audio.new(root,{sound})
    update(character,.2) assert(sound.Volume==.5)
    local wall=part("Wall",Vector3.new(16000,4,5),Vector3.new(8,8,1))
    update(character,.2) assert(math.abs(sound.Volume-.24)<.001 and sound.PubOcclusion.HighGain<0)
    wall:Destroy() head.Position+=Vector3.new(0,16,0)
    update(character,.2) assert(math.abs(sound.Volume-.14)<.001 and sound.PubOcclusion.MidGain<0)
end)
folder:Destroy() assert(ok,err)
print("Monster audio: clear, obstructed and different-floor mix passed")
