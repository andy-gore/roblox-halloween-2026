--!strict
-- Distance-weighted routes and local search branches, using only the pub's known layout.
local Routes = {}
function Routes.new(nodes: {Vector3}, neighbours: {{number}}, stops: {[number]: boolean}?)
    local function distances(first: number)
        local costs: {[number]: number} = {[first] = 0}
        local parents: {[number]: number} = {[first] = 0}
        local closed: {[number]: boolean} = {}
        for _=1,#nodes do
            local current: number? = nil
            local best = math.huge
            for node,cost in costs do
                if not closed[node] and cost<best then current,best=node,cost end
            end
            if not current then break end
            closed[current]=true
            for _,other in neighbours[current] do
                local cost=best+(nodes[other]-nodes[current]).Magnitude
                if cost<(costs[other] or math.huge) then costs[other],parents[other]=cost,current end
            end
        end
        return costs,parents
    end
    local controller = {}
    function controller.path(first: number, last: number): {number}
        local _,parents=distances(first)
        local result: {number}={}
        if parents[last]==nil then return result end
        local current=last
        while current~=0 do table.insert(result,1,current) current=parents[current] end
        return result
    end
    function controller.search(first: number, direction: Vector3): {number}
        local costs,parents=distances(first)
        local flat=Vector3.new(direction.X,0,direction.Z)
        local heading=if flat.Magnitude>0.1 then flat.Unit else Vector3.zero
        local branches: {[number]: {node: number, score: number}}={}
        for node,cost in costs do
            if cost>=6 and cost<=48 and (not stops or stops[node]) then
                local branch=node
                while parents[branch] and parents[branch]~=first and parents[branch]~=0 do branch=parents[branch] end
                local delta=nodes[node]-nodes[first]
                local horizontal=Vector3.new(delta.X,0,delta.Z)
                local alignment=if horizontal.Magnitude>0.1 then heading:Dot(horizontal.Unit) else 0
                local feature=if #neighbours[node]==1 then 5 elseif #neighbours[node]>=3 then 3 else 0
                local score=alignment*18+math.min(cost,24)*0.3-math.max(0,cost-24)*0.4+feature
                local previous=branches[branch]
                if not previous or score>previous.score then branches[branch]={node=node,score=score} end
            end
        end
        local ranked: {{node: number, score: number}}={}
        for _,candidate in branches do table.insert(ranked,candidate) end
        table.sort(ranked,function(a,b) return if a.score==b.score then a.node<b.node else a.score>b.score end)
        local result: {number}={}
        for i=1,math.min(3,#ranked) do table.insert(result,ranked[i].node) end
        return result
    end
    return controller
end
return Routes
