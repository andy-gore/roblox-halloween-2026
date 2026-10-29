--!strict
-- Only completed cinematic flags persist. Studio never touches live data stores.
local RunService=game:GetService("RunService")
local DataStoreService=game:GetService("DataStoreService")
local History={}
local keys={Arrival=true,Awakening=true,Escape=true}
local pending=0
local store=if RunService:IsStudio() then nil else DataStoreService:GetDataStore("LastOrdersSceneHistory_v1")
function History.merge(old: any,seen: {[string]: boolean}): {[string]: boolean}
    local merged: {[string]: boolean}={}
    for name in keys do if seen[name] or (typeof(old)=="table" and old[name]==true) then merged[name]=true end end
    return merged
end
function History.load(userId: number): {[string]: boolean}
    local result: {[string]: boolean}={}
    if not store or userId<=0 then return result end
    local ok,value=pcall(function() return store:GetAsync(tostring(userId)) end)
    if ok and typeof(value)=="table" then
        result=History.merge(value,{})
    elseif not ok then warn("Scene history unavailable; first-view rules used for this session") end
    return result
end
function History.save(userId: number,seen: {[string]: boolean})
    if not store or userId<=0 then return end
    local snapshot=table.clone(seen)
    pending+=1
    task.spawn(function()
        local ok=pcall(function()
            store:UpdateAsync(tostring(userId),function(old)
                return History.merge(old,snapshot)
            end)
        end)
        pending-=1
        if not ok then warn("Completed scene flags could not be saved; session flags remain available") end
    end)
end
if store then game:BindToClose(function()
    local deadline=os.clock()+12
    while pending>0 and os.clock()<deadline do task.wait(.1) end
end) end
return History
