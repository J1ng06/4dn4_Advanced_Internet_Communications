function plot_arrivals(flow, atimes, bits)

color_vector = ['r', 'b', 'g', 'k', 'm'];

flow_color = color_vector(flow);

[r,c] = size(atimes);

for j = 1:c
    
    x = atimes(1,j);
    y = bits(1,j);
    
    plot([x, x], [0, y], flow_color, 'LineWidth', 2);
    hold on;
    
end;

end

