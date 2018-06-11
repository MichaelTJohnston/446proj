% Code by Michael Johnston, June 10, 2018
% AERO 446 Power mode
% Returns power plot
% Inputs: P = Power to plot
%		  T = Period
%		  tEcl = Eclipse time range
%		  time = Time span
%		  orbits = orbit vector you want included
%		  true = only include eclipse

function power = pTime(P,T,tEcl,time, orbits, varargin)
	res = 10000;
	power = [linspace(0,time,res)', zeros(res,1)];
	
	orb = 1;
	for i = 1:res
		if power(i,1) > orb*T
			tEcl = tEcl + T;
			orb = orb + 1;
		end
		if power(i,1) > tEcl(1) && power(i,1) < tEcl(2) && ismember(orb,orbits) && nargin < 6
			power(i,2) = P;
		elseif (power(i,1) < tEcl(1) || power(i,1) > tEcl(2)) && ismember(orb,orbits)
			power(i,2) = P;
		else
			power(i,2) = 0;
		end
	end
end