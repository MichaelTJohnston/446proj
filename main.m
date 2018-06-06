% Code by Michael Johnston, June 4, 2018
% AERO 446 Project

% housekeeping
clear; % Clears workspace
clc; %clears command window
close all;

c = 299.8E6; % Speed of light [m/s]
hOrbit = 200; % Height of orbit [km]
muMoon = 4904.8695; % Gravitational constant of Moon [km^3/s^2]
rMoon = 1737.1; % Radius of Moon [km]
EMdist = 406700E3; % Max distance from Earth to Moon [m]

pSens = 40; % Power consumed by sensor during science gathering [w]
pSens_sby = 2; % Power consumed by sensor in stand-by [w]
rSens = 100E3; % Data rate of sensor during operations [bps]
commTime = 2*3600; % Total required comm time per day [s]
diaG = 20; % Diameter of ground antenna [m]
diaScFixed = 20E-2; % Diameter of FIXED spacecraft antenna (low-cost) [m]
diaScDep = 50E-2; % Diameter of DEPLOYABLE spacecraft antenna (high-cost) [m]

% -- dB Equations
G = @(D,f) 20*log10(f*1E-9) + 20*log10(D) + 17.8; % Parabolic antenna gain [dB]
Ls = @(dist,f) 20*log10(dist) + 20*log10(f) - 147.55; % Path loss [dB]
beamWid = @(D,f) 65.3*c/f/D; % Parabolic antenna beam width equation [degrees]
Lpoint = @(err,beamWid) 12*(err/beamWid)^2; % Pointing error equation [dB]

