--!strict
-- A cheap listener-to-monster occlusion sample preserves spatial cues through the pub.
local Audio={}
function Audio.new(root: BasePart,sounds: {Sound})
    local filters: {[Sound]: EqualizerSoundEffect}={}
    local base: {[Sound]: number}={}
    for _,sound in sounds do
        base[sound]=sound.Volume
        local eq=Instance.new("EqualizerSoundEffect") eq.Name="PubOcclusion" eq.Parent=sound filters[sound]=eq
    end
    local elapsed=0
    return function(character: Model?,dt: number)
        elapsed+=dt if elapsed<.2 then return end elapsed=0
        local listener=if character then character:FindFirstChild("Head") else nil
        if not listener or not listener:IsA("BasePart") then return end
        local cast=RaycastParams.new() cast.FilterType=Enum.RaycastFilterType.Exclude cast.FilterDescendantsInstances={root,character :: Model}
        local blocked=workspace:Raycast(listener.Position,root.Position-listener.Position,cast)~=nil
        local otherFloor=math.abs(listener.Position.Y-root.Position.Y)>9
        local gain=if otherFloor then .28 elseif blocked then .48 else 1
        for sound,eq in filters do
            sound.Volume=base[sound]*gain
            eq.HighGain,eq.MidGain=if blocked then -16 else 0,if otherFloor then -8 elseif blocked then -3 else 0
        end
    end
end
return Audio
