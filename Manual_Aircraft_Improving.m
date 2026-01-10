% maually improve range

% Load Refernce Aircraft
load("A330-300_REF.mat")

% define new object to be modified
MOD_manual = REF;
MOD_manual.Sim.EMWET_show = 1;
MOD_manual.Wing.span = 65; 
MOD_manual.Wing.sweepLE = 35*pi/180; 
MOD_manual.Mission.dp.alt = 12000; 
MOD_manual.Mission.dp.M = 0.77; 

% Generate new Wing Geometry
MOD_manual = get_Geometry(MOD_manual);

% Generate new Mission Data
MOD_manual.Mission.dp = get_Mission(MOD_manual.Mission.dp, MOD_manual.Wing.MAC);
MOD_manual.Mission.MO = get_Mission(MOD_manual.Mission.MO, MOD_manual.Wing.MAC);

% Run MDA (convergence loop) 
MOD_manual = MDA(MOD_manual); 

% Run Aerodinamic Analisis
try
    MOD_manual.Res.vis = get_Q3D(MOD_manual, MOD_manual.Mission.dp, MOD_manual.W.des, "viscous"); %viscous analysis to obtain Drag
    MOD_manual.Res.induced = get_Q3D(MOD_manual, MOD_manual.Mission.dp, MOD_manual.W.des, "inviscid"); %viscous analysis to obtain Drag
catch error
    fprintf('Error occurred: %s\n', error.message);
    MOD_manual.Res.vis.CLwing = NaN;
    MOD_manual.Res.vis.CDwing = NaN;
end

% Run Performance (Range) 
MOD_manual = get_Performance(MOD_manual, REF);

MOD_manual.Fuel_Tank.VolumeFuel = MOD_manual.W.fuel / 9.81 / MOD_manual.Fuel_Tank.FuelDensity;
% normailzed with initial design point
Cineq(1) = (MOD_manual.Fuel_Tank.VolumeFuel - MOD_manual.Fuel_Tank.VolumeTank) / REF.Fuel_Tank.VolumeTank; 

% wing loading must be at most the maximum of the reference aircraft
MOD_manual.Performance.W_S = MOD_manual.W.MTOW/MOD_manual.Wing.Sref;
Cineq(2) = MOD_manual.Performance.W_S / REF.Performance.W_S - 1;


REF.Performance.R
MOD_manual.Performance.R

(MOD_manual.Performance.R - REF.Performance.R) / REF.Performance.R
Cineq(1)
Cineq(2)
