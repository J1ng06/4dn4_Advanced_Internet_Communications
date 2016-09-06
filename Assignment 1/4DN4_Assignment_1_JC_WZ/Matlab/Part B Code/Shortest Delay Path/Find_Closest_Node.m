function next_node = Find_Closest_Node(U,Dist,W)
    min_dist = inf;
    next_node = 0;
    for u = U
        if(u~=0)
            if (Dist(u) < min_dist)
                min_dist = Dist(u);
                next_node = u;
            end
        end 
    end
end