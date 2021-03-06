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
NUM_FLOWS = 3;
NUM_PKTS     = 100;
LINK_RATE    = 1000;  % 1 kbits per second
TX_busy    = 0;
TX_start   = 0;
TX_end     = 0;
TX_flow    = 0;
TX_pkt_num = 0;
% define some global data-structures, visible in the functions
global NUM_PKTS;
global PACKET_ATIMES;
global PACKET_BITS;
global LINK_RATE;
global VFT;
global FLOW;
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
VFT_buf             = (inf)*ones(3,NUM_PKTS);
FLOW_MEAN_RATES     = [200   100  20 ]; 
FLOW_MEAN_BITS      = [10  20  100]; 
FLOW_WEIGHTS        = [ 1   1   1];

figure(1);

% initialize the  packet arrivals on each flow 
for flow=1:NUM_FLOWS
    
    flow_rate = FLOW_MEAN_RATES(1, flow);
    flow_bits = FLOW_MEAN_BITS(1, flow);
    [atimes, bits] = generate_packets(NUM_PKTS, flow_rate, flow_bits);
    
   PACKET_ATIMES(flow,:) = atimes ;
   PACKET_BITS(flow,:)   = bits  ;
   
   FLOW(flow).Queue = [];
   FLOW(flow).QSIZE = 0;
    FLOW(flow).total_bits = 0;
   plot_arrivals(flow, atimes, bits);
    figure(1);  % bring window to front of screen
end;

figure(2);

real_time = 0;
for round = 1:2000 
    for flow = 1: NUM_FLOWS
        pkt_num = check_for_arrivals(flow,real_time);
        
        if (pkt_num > 0)
            bits = PACKET_BITS(flow, pkt_num);  
            weight = FLOW_WEIGHTS(flow);
            if(FLOW(flow).QSIZE == 0)
                FLOW(flow).Queue = pkt_num;
                FLOW(flow).QSIZE = 1;
                VFT(flow,pkt_num) = round + bits/weight;
                VFT_buf(flow,pkt_num) = round + bits/weight;
            else
                FLOW(flow).Queue = [FLOW(flow).Queue, pkt_num];
                FLOW(flow).QSIZE = FLOW(flow).QSIZE + 1;
                VFT(flow,pkt_num) = VFT_buf(flow,pkt_num - 1) + bits/weight;
                VFT_buf(flow,pkt_num) = VFT_buf(flow,pkt_num - 1) + bits/weight;
            end
            PACKET_ATIMES(flow, pkt_num) = inf;
        end
    end

    if (TX_busy ==0)
        [TX_flow, TX_pkt_num] = find_smallest_VFT(real_time);
        if (TX_pkt_num > 0) 
            bits = PACKET_BITS(TX_flow, TX_pkt_num); 
            TX_busy    = 1;
            TX_start   = real_time;
            TX_end     = TX_start + bits/LINK_RATE;
            plot_transmission_2015(TX_flow, TX_pkt_num, TX_start, bits/LINK_RATE);
            FLOW(TX_flow).total_bits = FLOW(TX_flow).total_bits + bits;
        end
    elseif (TX_busy ==1)&&(TX_end<=real_time)
        VFT(TX_flow, TX_pkt_num) = inf;
        FLOW(flow).QSIZE = FLOW(flow).QSIZE - 1;
        TX_busy = 0; TX_end = 0; TX_flow = 0; TX_pkt_num = 0;
    end

    %increament the 'real_time'
    delta_t = 0;
    for flow = 1:NUM_FLOWS
        if(FLOW(flow).QSIZE > 0)
            delta_t = delta_t + FLOW_WEIGHTS(flow)/LINK_RATE;
        end
    end
    delta_t = max(delta_t,0.001);
    real_time = real_time + delta_t;

end  % for round = �. 
title('Weighted Fair Queue');
xlabel('Real-time (second)');
ylabel('Packet Size (bits)');