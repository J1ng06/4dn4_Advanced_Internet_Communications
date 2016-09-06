%---------------------SAMPLE CODE TO GET STARTED -------------------------------------------- 
%----------------------------------------------------------------  
% MAIN_WRR_2015.m
% 4DN4 class demo, Wed,Thurs. March 4,5, 2015
% this programs implements a basic Weighted Round Robin scheduler
%----------------------------------------------------------------

clear all;      % clear all variables
close all;      % close all figures
clc;            % clear command window

NUM_FLOWS  = 3;
NUM_PKTS     = 100;
LINK_RATE    = 1000;  % 1 kbits per second

% define some global data-structures, visible in the functions
global NUM_PKTS;
global PACKET_ATIMES;
global PACKET_BITS;
global LINK_RATE;

%-------------------------------------------------------------------------------
% define several matrices, to store data on packets and flows 
% store packet arrival times, bits per packet,
%---------------------------------------------------------
PACKET_ATIMES   = zeros(NUM_FLOWS, NUM_PKTS); 
PACKET_BITS      = zeros(NUM_FLOWS, NUM_PKTS);
 
FLOW_MEAN_RATES     = zeros(1, NUM_FLOWS);
FLOW_MEAN_BITS      = zeros(1, NUM_FLOWS); 
FLOW_WEIGHTS   = zeros(1, NUM_FLOWS); 

FLOW_MEAN_RATES     = [20   20    5]; 
FLOW_MEAN_BITS      = [20  15    40]; 
FLOW_WEIGHTS        = [ 1   1     1];

%figure(1);

% initialize the  packet arrivals on each flow 
for flow=1:3
    
    flow_rate = FLOW_MEAN_RATES(1, flow)
    flow_bits = FLOW_MEAN_BITS(1, flow) 
    [atimes, bits] = generate_packets(NUM_PKTS, flow_rate, flow_bits);
    
   PACKET_ATIMES(flow,:) = atimes ;
   PACKET_BITS(flow,:)   = bits  ;
    
    %plot_arrivals(flow, atimes, bits);
    %figure(1);  % bring window to front of screen
end;

%----------------------------------------------------
% Weighted Round Robin (WRR) server
% plot packet transmissions in figure 2
%----------------------------------------------------
figure(2);

current_time = 0;
for round = 1 : 10
    
    for flow = 1:NUM_FLOWS 
         
        flow_weight = FLOW_WEIGHTS(1,flow);
        
        %-----------------------------------------------------------------
        % for each round and for each flow, service a 
        % number of packets equal to the flow's weight
        %-----------------------------------------------------------------
        for pass = 1:flow_weight
            
            pkt_num   = check_for_arrivals(flow, current_time);

            if (pkt_num > 0)
                
                % we have a packet arrival to transmit
                bits      =  PACKET_BITS(flow, pkt_num);
                tx_time = bits/LINK_RATE;
                             
                plot_transmission_2015(flow, pkt_num, current_time, tx_time);
                figure(2);
                
                PACKET_ATIMES(flow, pkt_num) = inf;  % remove this packet from consideration
   
                current_time = current_time + tx_time;    

                fprintf('TXed pkt: flow %g, pkt %g\n', flow, pkt_num); 
            end
         
        end  % for pass ..
         
    end  % for flow = … 
    
end  % fior round = …. 