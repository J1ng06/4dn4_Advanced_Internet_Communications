% new function to check for packet arrivals at a certain real-time
function  pkt_num   = check_for_arrivals(flow, current_time);

    global  PACKET_ATIMES;
    global  NUM_PKTS;

    pkt_num = 0;

    for j = 1:NUM_PKTS;

        if (PACKET_ATIMES(flow, j) <= current_time)
           % we found a packet that has arrived  by the current-time
            pkt_num = j;
            return
        end
    end

    end  % end function

