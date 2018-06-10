% Code by Michael Johnston, Valeria Salazar, Bryan Num, Chris Barta
% AERO 446 Project

%% housekeeping
clear; % Clears workspace
clc; %clears command window
close all;

%% -- Constants --
c = 299.8E6; % Speed of light [m/s]
hOrbit = 200; % Height of orbit [km]
muMoon = 4904.8695; % Gravitational constant of Moon [km^3/s^2]
rMoon = 1737.1; % Radius of Moon [km]
EMdist = 406700E3; % Max distance from Earth to Moon [m]

%% -- Orbit parameters --
T = 2*pi*sqrt((hOrbit+rMoon)^3/muMoon); % Period of orbit [s]
w = 2*pi/T; % Angular velocity [rad/s]
thetaEclipse = acos(rMoon/(hOrbit+rMoon));
tEclipse = [thetaEclipse wrapTo2Pi(-thetaEclipse)]/w; % Time range in eclipse [s]
tSun = (tEclipse(2) - tEclipse(1)); % Time in sun [s]
orbits = 24*3600/T; % Orbits per day
tSun_day = tSun*orbits; % time in sun per day [s]

%% -- Solar panels --
U = 0.10; % Cube sat "Unit" [m]
APanel = 3*U*2*U; % Area of solar panels [m^2]
Fsun = 1366; % Solar flux [W/m^2]
effPanel = 0.3; % Efficiency of panel
pDens = 0.8; % Panel density
effTemp = 0.5/100; % Degredation of panel efficiency due to temp
effTime = 2.5/100; % Degredation of panel efficiency due to time [%/yr]
opTime = 3; % Operational time [yrs]
Tsol = 40; % Temperature of panels [?C]
panelDens = 80/100; % Density of solar panels

%% --Body Mounted Solar Panels

effEoL = pDens*effPanel*(1 - effTemp*(Tsol - 28))*(1 - effTime)^opTime;  %end of life efficiency

%case where sensor points and s/c rotates 
syms t
PgenFixed = Fsun*APanel*effEoL; % Power generated by fixed panels (oriented normal) [W]
eGenFixed = (double(PgenFixed*( 2*int(sin(w*t),t, thetaEclipse/w, pi/w))))*orbits/3600; %[W.hr/day]

%case where s/c is oriented at 45 degrees and doesn't rotate
PgenFixed45 = 2*cosd(45)*PgenFixed; % Power generated by fixe panels (oriented 45deg) [W]
eGenFixed45 = PgenFixed45*tSun/3600*orbits; % [W.hr/day]


%% Power generated by tracking panels [W]
pGen = Fsun*effEoL*APanel;
EgenTracking = (pGen*tSun*orbits)/3600 % Energy generated by tracking panels per day [W.hr]

% -- Power consumed by... --
% -Radio
rxPower = 12.5; % Power CONSUMED by radio during receive only [W]
rxTxPower = 35; % Power CONSUMED by radio during transmit/recieve [W]
maxTxPowerIn = 30.8; % Power CONSUMED by radio during transmit only [W]
rxPlusPower = rxTxPower - maxTxPowerIn; % Power CONSUMED for rx during tx/rx [W]
maxTxPowerOut = 3.8; % Max power output by transmitter [W]
txEff = 3.8/maxTxPowerIn; % Transmitter power efficiency

% -ACS (varies?)
pACS = [2 3]; % Power consumed by ACS (average) [w]

% -Computer
pCPU = [1.6 2.85]; % Power consumed by computer

% -Sensor
pSens = 40; % Power consumed by sensor during science gathering [w]
pSens_sby = 2; % Power consumed by sensor in stand-by [w]
rSens = 100E3; % Data rate of sensor during operations [bps]

%% -- 

% -- Modes
% Idle power consumed [W]
pModeIdle = pCPU(1) + rxPower + pSens_sby + pACS(1);
% Comms only power consumed [W]
pModeComms = pACS(2) + pCPU(1) + rxPower + pSens_sby + rxTxPower;
% Power generation
pModeGen = pModeIdle; % Power consumed during power generation
% Science gathering (always gather in eclipse?)
pModeSci = pSens + pCPU(2) + pACS(2) + rxPower;

% --

fRange = linspace(8.400, 8.450)'*1E9; % X-Band frequency range [Hz]
commTime = 2*3600; % Total required comm time per day [s]

diaG = 20; % Diameter of ground antenna [m]
diaScFixed = 20E-2; % Diameter of FIXED spacecraft antenna (low-cost) [m]
diaScDep = 50E-2; % Diameter of DEPLOYABLE spacecraft antenna (high-cost) [m]

Ts = 10*log10(150); % System temperature noise [dB]
Ll = 5; % Line losses [dB]
EbNoMin = 3 + 5; % Link budget plus margin for Reed-Solomon encoding[dB]
Latm = 0; % Atmospheric losses ASSUMING ZERO [dB]
Lpt = 0; % Pointing losses [dB]

%% -- dB Equations --
G = @(D,f) 20*log10(f*1E-9) + 20*log10(D) + 17.8; % Parabolic antenna gain [dB]
Ls = @(dist,f) 20*log10(dist) + 20*log10(f) - 147.55; % Path loss [dB]
beamWid = @(D,f) 65.3*c./f/D; % Parabolic antenna beam width equation [degrees]
Lpoint = @(err,beamWid) 12*(err./beamWid).^2; % Pointing error equation [dB]

%% -- Signal loss vs Frequency (tl;dr, frequency doesn't matter)
% figure
% plot(fRange*1E-9, G(diaG,fRange) + G(diaScDep,fRange) - Ls(EMdist,fRange),...
% 	fRange*1E-9, G(diaG,fRange) + G(diaScFixed,fRange) - Ls(EMdist,fRange), 'lineWidth', 2)
% grid on
% title('Signal Loss vs Frequency (Antenna Gain - Path Loss)')
% xlabel('Frequency [GHz]'), ylabel('Signal Loss [dB]')
% legend('Deployable Antenna', 'Fixed Antenna')

%% Solving for max data rate that meets link budget
fTx = fRange(1); % Transmit frequency
syms dRate
linkEq = EbNoMin == maxTxPowerOut - Ls(EMdist,fTx) + G(diaG,fTx)...
	+ G(diaScFixed,fTx) + 228.6 - Ts - 10*log10(dRate) - Ll;

dRateMax = double(solve(linkEq,dRate))  % Max data rate that meets link budget [bps]

%% finding the energy for different modes

%max data sent
dStored = dRateMax*(2*3600); %[bits] data sent to earth for two hours

%max data stored
tSci = (dRateMax*2*3600)/rSens;

%energy consumed gathering data
ESci = (pModeSci)*tSci;

%energy consumed during downlink
EDown = (pACS(2) + maxTxPowerIn + pCPU(1) + pACS(2) + pSens_sby)*tSci; %[Whr] energy consumed during uplink