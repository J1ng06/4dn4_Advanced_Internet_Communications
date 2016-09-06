% new function to plot packet transmissions
function plot_transmission_2015(flow, pkt_num, current_time, tx_time)

global PACKET_ATIMES;
global PACKET_BITS;
global LINK_RATE;

color_vector = ['r', 'b', 'g', 'k', 'm'];

flow_color = color_vector(flow);

% plot a vertical line to show the bits in the Transmit-Q  initially
     
j = pkt_num; 
 
x = current_time;
y = PACKET_BITS(flow,j);

plot([x, x], [0, y], flow_color, 'LineWidth', 2);
hold on;

% plot a diagonal line to show the bits remaining in the Transmit-Q
x2      = x + tx_time;

plot([x, x2], [y, 0], flow_color, 'LineWidth', 2);   
 
%fprintf('Plotted TX: flow %g, pkt %g\n', flow, pkt_num);
%fprintf('Plotted TX: current_time %g, txtime %g\n', x, tx_time);

end % end function
 