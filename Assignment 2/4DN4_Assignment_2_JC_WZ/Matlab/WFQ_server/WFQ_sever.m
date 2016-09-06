%---------------------SAMPLE CODE TO GET STARTED -------------------------------------------- 
%----------------------------------------------------------------  
% MAIN_WRR_2015.m
% 4DN4 class demo, Wed,Thurs. March 4,5, 2015
% this programs implements a basic Weighted Round Robin scheduler
%----------------------------------------------------------------

clear all;      % clear all variables
close all;      % close all figures
clc;            % clear command window

global NUM_FLOWS;
NUM_FLOWS = 4;


TX_start   = 0; % transmission start time
TX_end     = 0; % transmission end time
TX_busy    = 0; % transmission status
TX_flow    = 0; % flow being transmitted
TX_pkt_num = 0; % packet number being transmitted
% define some global data-structures, visible in the functions
global NUM_PKTS;
global PACKET_ATIMES;
global PACKET_BITS;
global LINK_RATE;
global VFT;
global FLOW;
NUM_PKTS     = 100;
LINK_RATE    = 1000;  % 1 kbits per second
%-------------------------------------------------------------------------------
% define several matrices, to store data on packets and flows 
% store packet arrival times, bits per packet,
%---------------------------------------------------------
PACKET_ATIMES   = zeros(NUM_FLOWS, NUM_PKTS); 
PACKET_BITS      = zeros(NUM_FLOWS, NUM_PKTS);
 
FLOW_MEAN_RATES     = zeros(1, NUM_FLOWS);
FLOW_MEAN_BITS      = zeros(1, NUM_FLOWS); 
FLOW_WEIGHTS        = zeros(1, NUM_FLOWS); 
VFT                 = (inf)*ones(3,NUM_PKTS);

FLOW_MEAN_RATES     = [100   200  55 30]; 
FLOW_MEAN_BITS      = [20   15  40   60]; 
%FLOW_WEIGHTS        = [ 2   2   1     1];
FLOW_WEIGHTS        = [ 1   1   1     1];  % Equal Weight


%figure(1);

% initialize the  packet arrivals on each flow 
for flow=1:NUM_FLOWS
    
    flow_rate = FLOW_MEAN_RATES(1, flow);
    flow_bits = FLOW_MEAN_BITS(1, flow);
    % generate packet arrivals for 4 flows.
    [atimes, bits] = generate_packets(NUM_PKTS, flow_rate, flow_bits);
    
   PACKET_ATIMES(flow,:) = atimes ;
   PACKET_BITS(flow,:)   = bits  ;
   
   % create a FLOW structure to store the queue and queue size and total
   % number of bits that have been transmitted.
   FLOW(flow).Queue = [];       % Queue
   FLOW(flow).QSIZE = 0;        % Queue Size
   FLOW(flow).total_bits = 0;   % Total number of bits transmitted
   plot_arrivals(flow, atimes, bits);
    %figure(1);  % bring window to front of screen
end;

figure(2);

round = 1;
% implement using realtime
for real_time = 0:3000
    
    for flow = 1: NUM_FLOWS
        pkt_num = check_for_arrivals(flow,real_time/1000);
        
        if (pkt_num > 0)
            bits = PACKET_BITS(flow, pkt_num);  
            weight = FLOW_WEIGHTS(flow);
            if(FLOW(flow).QSIZE == 0)    % empty queue 
                FLOW(flow).Queue = pkt_num; 
                FLOW(flow).QSIZE = 1;   % update queue size
                VFT(flow,pkt_num) = round + bits/weight; % update VFT with round
            else
                FLOW(flow).Queue = [FLOW(flow).Queue, pkt_num];
                FLOW(flow).QSIZE = FLOW(flow).QSIZE + 1; % update queue size
                % update VFT with previous packet VFT
                VFT(flow,pkt_num) = VFT(flow,pkt_num - 1) + bits/weight;
            end
            PACKET_ATIMES(flow, pkt_num) = inf;
        end
    end
    % 
    if (TX_busy ==0) % TX buffer is idle
        [TX_flow, TX_pkt_num] = find_smallest_VFT(real_time/1000);
        if (TX_pkt_num > 0) 
            bits = PACKET_BITS(TX_flow, TX_pkt_num); 
            TX_busy    = 1;             
            TX_start   = real_time/1000;    
            TX_end     = TX_start + bits/LINK_RATE; % compute actual finishing time
            plot_transmission_2015(TX_flow, TX_pkt_num, TX_start, bits/LINK_RATE);
            % accumulate the bits
            FLOW(TX_flow).total_bits = FLOW(TX_flow).total_bits + bits;
        end
    elseif (TX_busy ==1)&&(TX_end<=real_time/1000) % TX buffer is busy and transmission is done
        VFT(TX_flow, TX_pkt_num) = inf; % reset VFT
        FLOW(TX_flow).QSIZE = FLOW(TX_flow).QSIZE - 1; % update queue size
        TX_busy = 0;            % reset
        TX_end = 0;             % reset
        TX_flow = 0;            % reset
        TX_pkt_num = 0;         % reset
    end
    
    % increatment the 'round'. check for how long does 1 round will take
    delta_t = 0;
    for flow = 1:NUM_FLOWS
        if(FLOW(flow).QSIZE > 0)
            delta_t = delta_t + FLOW_WEIGHTS(flow)/LINK_RATE;
        end
    end
    round = round + 0.001/delta_t;

end  % for real_time = …. 
title('Weighted Fair Queueing - Non-Equal Weights');
xlabel('Real-time (second)');
ylabel('Packet Size (bits)');
for flow = 1:NUM_FLOWS
    fprintf('Flow %g transmits %g bits.\n', flow, FLOW(flow).total_bits)
end