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
		t = power(i,1);
		if isa(P, 'function_handle') % Check if P varies with time
			p = max(P(t),0);
		else
			p = P;
		end
		if t > orb*T
			if norm(tEcl) > 0
				tEcl = tEcl + T;
			end
			orb = orb + 1;
		end
		if norm(tEcl) == 0 && ismember(orb,orbits) % No eclipse
			power(i,2) = p;
		elseif norm(tEcl) == 0 % No eclipse, no power
			power(i,2) = 0;
		elseif t > tEcl(1) && t < tEcl(2) && ismember(orb,orbits) && nargin < 6
			power(i,2) = p;
		elseif (t < tEcl(1) || t > tEcl(2)) && ismember(orb,orbits) && nargin > 5 % Only eclipse
			power(i,2) = p;
		else
			power(i,2) = 0;
		end
	end
end