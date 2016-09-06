function [TX_flow, TX_pkt_num] = find_smallest_VFT(real_time)
%FIND_SMALLEST_VFT Summary of this function goes here
%   Detailed explanation goes here
    global NUM_FLOWS;    global VFT;    global FLOW;
    TX_flow = 0;    TX_pkt_num = 0;
    smallest_VFT = inf;
    for flow = 1:NUM_FLOWS
        for pkt_num = FLOW(flow).Queue
            if (VFT(flow, pkt_num) < smallest_VFT) && (VFT(flow, pkt_num) >= real_time)
                smallest_VFT = VFT(flow, pkt_num);
                TX_flow = flow;
                TX_pkt_num = pkt_num;
            end
        end
    end
end

