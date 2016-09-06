function [Dist,Pred]= Dijkstra_Shortest_Path_Tree(src, W)
    N = size(W,1);
    U = linspace(1,N,N);
    Dist(1:N) = inf;
    Pred(1:N) = inf;
    Dist(src) = 0;
    while(sum(U) ~=0)   
        v = Find_Closest_Node(U,Dist,W);
        % remove the new v from U
        U(v) = 0;
        %fprintf('new v = %g\n', v);
        %pause;
        for u = U
            if ((u ~=0)&&(W(v,u) ~=0))
                if(Dist(v) + W(v,u) < Dist(u))
                    Dist(u) = Dist(v)+W(v,u);
                    Pred(u) = v;
                end
            end
        end
    end  
end
