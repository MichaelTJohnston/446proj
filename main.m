% Code by Michael Johnston, Valeria Salazar, Bryan Num, Chris Barta, June 4, 2018
% AERO 446 Project

% -- Assumptions --
% Pointing errors are negligible (XACT-50 has ?0.003 deg accuracy)

% -- Variables --
% Data rate
% Transmit power

% -- To do --
% Find power produced by panels in 1 day (fn of data rate)

% housekeeping
clear; % Clears workspace
clc; %clears command window
close all;

% -- Constants & givens for equipment --
c = 299.8E6; % Speed of light [m/s]
hOrbit = 200; % Height of orbit [km]
muMoon = 4904.8695; % Gravitational constant of Moon [km^3/s^2]
rMoon = 1737.1; % Radius of Moon [km]
EMdist = 406700E3; % Max distance from Earth to Moon [m]

% -- Orbit parameters --
T = 2*pi*sqrt((hOrbit+rMoon)^3/muMoon); % Period of orbit [s]
w = 2*pi/T; % Angular velocity [rad/s]
thetaEclipse = pi/2 + acos(rMoon/(hOrbit+rMoon));
tEclipse = [thetaEclipse wrapTo2Pi(-thetaEclipse)]/w; % Time range in eclipse [s]
tSun = T - (tEclipse(2) - tEclipse(1)); % Time in sun [s]
orbits = 24*3600/T; % Orbits per day

% -- Tracking panel
% Power out in an orbit?
% Fn of size of panels, density, efficiency
U = 0.10; % Cube sat "Unit" [m]
APanel = 3*U*2*U; % Area of solar panels [m^2]
Fsun = 1366; % Solar flux [W/m^2]
effPanel = 0.3; % Efficiency of panel
effTemp = 0.5/100; % Degredation of panel efficiency due to temp
effTime = 0.25/100; % Degredation of panel efficiency due to time [%/yr]
opTime = 3; % Operational time [yrs]
T = 40; % Temperature of panels [?C]
Ppanel = Fsun*effPanel*(1 - effTemp*(T - 25))*(1 - effTime)^opTime*APanel

pSens = 40; % Power consumed by sensor during science gathering [w]
pSens_sby = 2; % Power consumed by sensor in stand-by [w]
rSens = 100E3; % Data rate of sensor during operations [bps]

fRange = linspace(8.400, 8.450)'*1E9; % X-Band frequency range [Hz]
commTime = 2*3600; % Total required comm time per day [s]
rxPower = 12.5; % Power consumed by radio during receive only [W]
maxTxPowerIn = 30.8; % Power consumed by radio during transmit only [W]
rxPlusPower = 35-maxTxPowerIn; % Power consumed for rx during tx/rx [W]
txEff = 3.8/maxTxPowerIn; % Transmitter power efficiency

diaG = 20; % Diameter of ground antenna [m]
diaScFixed = 20E-2; % Diameter of FIXED spacecraft antenna (low-cost) [m]
diaScDep = 50E-2; % Diameter of DEPLOYABLE spacecraft antenna (high-cost) [m]

Ts = 10*log10(150); % System temperature noise [dB]
Ll = 5; % Line losses [dB]
EbNoMin = 3 + 5; % Link budget plus margin for Reed-Solomon encoding[dB]
Latm = 0; % Atmospheric losses ASSUMING ZERO [dB]
Lpt = 0; % Pointing losses [dB]

% -- dB Equations --
G = @(D,f) 20*log10(f*1E-9) + 20*log10(D) + 17.8; % Parabolic antenna gain [dB]
Ls = @(dist,f) 20*log10(dist) + 20*log10(f) - 147.55; % Path loss [dB]
beamWid = @(D,f) 65.3*c./f/D; % Parabolic antenna beam width equation [degrees]
Lpoint = @(err,beamWid) 12*(err./beamWid).^2; % Pointing error equation [dB]

% -- Signal loss vs Frequency (tl;dr, frequency doesn't matter)
figure
plot(fRange*1E-9, G(diaG,fRange) + G(diaScDep,fRange) - Ls(EMdist,fRange),...
	fRange*1E-9, G(diaG,fRange) + G(diaScFixed,fRange) - Ls(EMdist,fRange), 'lineWidth', 2)
grid on
title('Signal Loss vs Frequency (Antenna Gain - Path Loss)')
xlabel('Frequency [GHz]'), ylabel('Signal Loss [dB]')
legend('Deployable Antenna', 'Fixed Antenna')

% Solving for max data rate that meets link budget
fTx = fRange(1); % Transmit frequency
syms dRate
linkEq = EbNoMin == 10*log10(txEff*maxTxPowerIn) - Ls(EMdist,fTx) + G(diaG,fTx)...
	+ G(diaScFixed,fTx) + 228.6 - Ts - 10*log(dRate) - Ll;

dRateMax = double(solve(linkEq,dRate)); % Max data rate that meets link budget [bps]

