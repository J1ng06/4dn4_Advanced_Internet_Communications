%-------------------------------------------------------------------------------
% 4DN4: sample matlab code for  assignment #1. 
% put the next code into a matlab file called "MAIN_Assignment_1.m'
%-------------------------------------------------------------------------------

function [BEST_SEQ] = Find_Best_Solutions(FLOW,TOP);

N       = 15;
Lambda 	= zeros(N,N);   % create an 8x8 matrix of zeros
Mu        	= zeros(N,N);
Delay  		= zeros(N,N);

% call a matlab script to read in the topology matrix

% create a lambda and mu matrix with one entry each
prev_num_path_routed = 0;
num_path_routed = 0;
Mu = TOP * 1000;
for perm_loop = 1:20
    num_path_routed = 0;
    sequence = randperm(36);
    Lambda 	= zeros(N,N);
    Delay  		= zeros(N,N);
    for  i = sequence
        
            %get the shortest path
            flow_data = FLOW(i,1:3);
            [Delay]  = find_network_delay(Lambda, Mu);
            [Dist,Pred]= Dijkstra_Shortest_Path_Tree(flow_data(1), Delay,TOP);

            path = [];
            prev_node = Pred(flow_data(2));
            while (prev_node ~= flow_data(1))
                path = [prev_node path];
                prev_node = Pred(prev_node);
            end
            path = [flow_data(1) path];
            path = [path flow_data(2)];

            %path = [1, 2, 6];

            path_delay = test_path(path, 800, Lambda, Mu);

            if (path_delay <= 0.05)
                [path_delay, Lambda] = route_path(path, 800, Lambda, Mu);
                %fprintf('\nRouted flow #%g along path: ',i);
                %fprintf('%g ', path);  % this statement prints all the nodes onto one line
                %fprintf('. The Path Delay is %g \n', path_delay);
                %fprintf('loop number: %g \n', perm_loop);
                num_path_routed = num_path_routed + 1;
            end
    
    % found a better solution
    if (num_path_routed > prev_num_path_routed)
        % print the number of flows that have been routed now
        fprintf('best num of flows routed: %g \n', num_path_routed);
        prev_num_path_routed = num_path_routed;
        % record the bast solution
        BEST_SEQ = sequence;
    end
   
    end
end
% path = [1, 2, 6];
% 
% path_delay = test_path(path, 800, Lambda, Mu);
% 
% if (path_delay <= 0.05)
%     [path_delay, Lambda] = route_path(path, 800, Lambda, Mu);
%     fprintf('\nRouted flow #%g along path: ',i);
%     fprintf('%g ', path);  % this statement prints all the nodes onto one line
%     fprintf('\n');               % this statement starts a new line
% end;
% % route a second path
% path = [1,9, 8, 11];
% path_delay = test_path(path, 800, Lambda, Mu);
% 
% if (path_delay <= 0.05)
% 	[path_delay, Lambda] = route_path(path, 800, Lambda, Mu);
% 	fprintf('\nRouted flow #2 along path: ');
% 	fprintf('%g ', path);  % this statement prints all the nodes onto one line
% 	fprintf('\n');               % this statement starts a new line
% end;
% pause;

% Delay  = find_network_delay(Lambda, Mu);
% 
% fprintf('Here is the Lambda matrix  (rates in 1000 pps) \n');
% print_matrix ( Lambda/1000 );
% 
% fprintf('Here is the Mu matrix  (rates in 1000 pps) \n');
% print_matrix ( Mu/1000 );
% 
% fprintf('Here is the Delay matrix  (in millisec) \n');
% print_matrix ( Delay*1000 );
% figure(3);
% bar3(Delay);
% title('Delay matrix')
% pause;

% % the rest is up to you

