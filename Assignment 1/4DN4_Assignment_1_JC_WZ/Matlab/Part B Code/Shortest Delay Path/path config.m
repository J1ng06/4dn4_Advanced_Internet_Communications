%-------------------------------------------------------------------------------
% 4DN4: sample matlab code for  assignment #1. 
% put the next code into a matlab file called "MAIN_Assignment_1.m'
%-------------------------------------------------------------------------------

clear all;
clc;
close all;

N       = 15;
Lambda 	= zeros(N,N);   % create an 8x8 matrix of zeros
Mu        	= zeros(N,N);
Delay  		= zeros(N,N);

% call a matlab script to read in the topology matrix
script_SPRINT_TOPOLOGY
define_flows
% call a script to plot the graph
figure(1);
clf
set(gca,'FontSize', 15);

plot_graph

figure(2);
bar3(TOP);
title('Topology matrix')
%pause;
% create a lambda and mu matrix with one entry each
Mu = TOP * 100000;
    num_path_routed = 0;
    sequence = [6,19,25,9,10,2,28,32,7,12,15,18,34,21,1,13,11,23,3,17,16,22,27,14,29,4,33,8,35,5,24,20,36,30,31,26];
    for  i = sequence
            %get the shortest path
            flow_data = FLOW(i,1:3);
            [Dist,Pred]= Dijkstra_Shortest_Path_Tree(flow_data(1), TOP);

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
                fprintf('\nRouted flow #%g along path: ',i);
                fprintf('%g ', path);  % this statement prints all the nodes onto one line
                fprintf('. The Path Delay is %g \n', path_delay);
                fprintf('\n');
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

