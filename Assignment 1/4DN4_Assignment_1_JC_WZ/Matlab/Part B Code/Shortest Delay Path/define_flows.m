% 4DN4, Assignment #1, 2015
% DEFINE THE TRAFFIC PATTERNS TO ROUTE

% store the src, destination, rate
% you can put this is a script file called �define_flows.m�
% and execute it

FLOW = zeros(36,3);
FLOW(1,1:3) = [1, 7, 800];
FLOW(2,1:3) = [2, 8, 800];
FLOW(3,1:3) = [3, 13, 800];
FLOW(4,1:3) = [4, 11, 800];
FLOW(5,1:3) = [5, 1, 800];
FLOW(6,1:3) = [6, 9, 800];
FLOW(7,1:3) = [7, 15, 800];
FLOW(8,1:3) = [8, 2, 800];
FLOW(9,1:3) = [9, 6, 800];
FLOW(10,1:3) = [10, 3, 800];
FLOW(11,1:3) = [11, 12, 800];
FLOW(12,1:3) = [12, 10, 800];
FLOW(13,1:3) = [13, 4, 800];
FLOW(14,1:3) = [14, 5, 800];  % corrected Feb 5
FLOW(15,1:3) = [15, 14, 800]; % corrected Feb 5
 
FLOW(16,1:3) = [1, 15, 800];
FLOW(17,1:3) = [2, 1, 800];
FLOW(18,1:3) = [3, 2, 800];
FLOW(19,1:3) = [4, 10, 800];
FLOW(20,1:3) = [5, 13, 800];  % corrected Feb 5
FLOW(21,1:3) = [6, 5, 800];   % corrected Feb 5
FLOW(22,1:3) = [7, 8, 800];
FLOW(23,1:3) = [8, 4, 800];
FLOW(24,1:3) = [9, 14, 800];
FLOW(25,1:3) = [10, 7, 800];
FLOW(26,1:3) = [11, 12, 800];
FLOW(27,1:3) = [12, 3, 800];
FLOW(28,1:3) = [13, 11, 800];
FLOW(29,1:3) = [14, 6, 800];
FLOW(30,1:3) = [15, 9, 800];

FLOW(31,1:3) = [1, 8, 800];
FLOW(32,1:3) = [2, 5, 800];
FLOW(33,1:3) = [7, 1, 800];
FLOW(34,1:3) = [8, 10, 800];
FLOW(35,1:3) = [14, 9, 800]; % corrected Feb 5
FLOW(36,1:3) = [15, 7, 800]; % corrected Feb 5
