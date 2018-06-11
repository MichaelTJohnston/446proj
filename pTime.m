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
			if norm(tEcl) > 0
				tEcl = tEcl + T;
			end
			orb = orb + 1;
		end
		if norm(tEcl) == 0 && ismember(orb,orbits) % No eclipse
			power(i,2) = P;
		elseif norm(tEcl) == 0 % No eclipse, no power
			power(i,2) = 0;
		elseif power(i,1) > tEcl(1) && power(i,1) < tEcl(2) && ismember(orb,orbits) && nargin < 6
			power(i,2) = P;
		elseif (power(i,1) < tEcl(1) || power(i,1) > tEcl(2)) && ismember(orb,orbits) && nargin > 5 % Only eclipse
			power(i,2) = P;
		else
			power(i,2) = 0;
		end
	end
end