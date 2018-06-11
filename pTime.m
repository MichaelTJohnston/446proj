% Code by Michael Johnston, June 10, 2018
% AERO 446 Power mode
% Returns power plot
% Inputs: P = Power to plot
%		  T = Period
%		  tEcl = Eclipse time range
%		  time = Time span

function power = pTime(P,T,tEcl,time)
	power = [linspace(0,time)', zeros(100,1)];
	
	orb = 1;
	for i = 1:100
		if power(i,1) > orb*T
			tEcl = tEcl + T;
			orb = orb + 1;
		end
		if power(i,1) > tEcl(1) && power(i,1) < tEcl(2)
			power(i,2) = P;
		else
			power(i,2) = 0;
		end
	end
end