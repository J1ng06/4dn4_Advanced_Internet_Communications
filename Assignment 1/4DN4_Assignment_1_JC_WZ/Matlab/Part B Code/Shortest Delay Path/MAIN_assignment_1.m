
%-------------------------------------------------------------------------------
% 4DN4: sample matlab code for  assignment #1. 
% put the next code into a matlab file called "MAIN_Assignment_1.m'
%-------------------------------------------------------------------------------

clear all;
clc;
close all;

N       = 15;

Lambda 	= zeros(N,N);   % create an 8x8 matrix of zeros
Nq = zeros(N,N);
Mu        	= zeros(N,N);
Delay  		= zeros(N,N);

% call a matlab script to read in the topology matrix
script_SPRINT_TOPOLOGY
define_flows
% Loop different combination and find the better solution
Loop_number = 20;
BEST_SEQ = Find_Best_Solution(FLOW,TOP,Loop_number);
% re-initialize all the matrices
Lambda 	= zeros(N,N); 
Mu        	= zeros(N,N);
Delay  		= zeros(N,N);
% call a script to plot the graph
figure(1);
clf
set(gca,'FontSize', 15);

plot_graph

figure(2);
bar3(TOP);
title('Topology matrix')
% create a lambda and mu matrix with one entry each
num_path_routed = 0;
Mu = TOP * 1000;
num_path_routed = 0;
for  i = BEST_SEQ
        %get the shortest path
        flow_data = FLOW(i,1:3);
        % Find Delay matrix
        [Delay]  = find_network_delay(Lambda, Mu);
        % Find the shorest Delay path
        [Dist,Pred]= Dijkstra_Shortest_Path_Tree(flow_data(1), Delay,TOP);

        % Based on the Pred vector and the source and destination of
        % each flow, we retrive the path that is taken
        path = [];
        prev_node = Pred(flow_data(2));
        while (prev_node ~= flow_data(1))
            path = [prev_node path];
            prev_node = Pred(prev_node);
        end
        path = [flow_data(1) path];
        path = [path flow_data(2)];

        % test the path delay
        path_delay = test_path(path, 800, Lambda, Mu);
        % route the traffic
        if (path_delay <= 0.05)
            [path_delay, Lambda] = route_path(path, 800, Lambda, Mu);
            fprintf('\nRouted flow #%g along path: ',i);
            fprintf('%g ', path);  % this statement prints all the nodes onto one line
            fprintf('. The Path Delay is %g \n', path_delay);
            fprintf('\n');
            num_path_routed = num_path_routed + 1;
        end  
end
    
fprintf('number of path routed: %g\n',num_path_routed);
    
Delay  = find_network_delay(Lambda, Mu);
%compute Nq matrix
Nq = Compute_Nq(Lambda, Mu);
fprintf('Here is the Lambda matrix  (rates in 1000 pps) \n');
print_matrix ( Lambda/1000 );

fprintf('Here is the Mu matrix  (rates in 1000 pps) \n');
print_matrix ( Mu/1000 );

fprintf('Here is the Delay matrix  (in millisec) \n');
print_matrix ( Delay*1000 );

fprintf('Here is the Nq matrix  (in millisec) \n');
print_matrix ( Nq );