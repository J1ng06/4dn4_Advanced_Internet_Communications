%-------------------------------------------------------------------------
% put the next code into a matlab file called ?find_network_delay.m?
% function  find_network_delay() will return the delay matrix 
% Delay(i,j) = delay on link(i,j) in the network
%-------------------------------------------------------------------------
function [Nq]  = Compute_Nq(Lambda, Mu)

[rows,cols] = size(Lambda);   % find the # rows and # columns in the Lambda matrix
Nq = zeros(rows,cols);       % initialize the Delay matrix to return zeros

for u = 1:rows
	for v = 1:cols
		%---------------------------------------------------------------
		% if this edge (row,col) exists, then it has a non-zero Mu(row,col)		
		% find the Nq; assume that Lambda(row,col) is 0 or positive
		%----------------------------------------------------------------
        if (Lambda(u,v) == 0)
			Nq(u,v)  = 0;
        else
            % Nq = rho /(1-rho)
			Nq(u,v)  = (Lambda(u,v) /  Mu(u,v)) /(1 - Lambda(u,v) /  Mu(u,v));
		end;
	end;
end;
	
