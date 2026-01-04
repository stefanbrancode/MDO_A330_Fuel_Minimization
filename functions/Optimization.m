function R = Optimization(MOD, REF, x_norm, lb, ub)
% xxx
x = Denormalize_Design_Vector(x_norm, lb, ub); 

% Assign Design Vector to Aircracft
MOD = Assign_DesignVector(x, MOD);

% Generate new Wing Geometry
MOD = get_Geometry(MOD);

% Generate new Mission Data
MOD.Mission.dp = get_Mission(MOD.Mission.dp, MOD.Wing.MAC);
MOD.Mission.MO = get_Mission(MOD.Mission.MO, MOD.Wing.MAC);

% Run MDA (convergence loop) 
MOD = MDA(MOD); 

% Run Aerodinamic Analisis
MOD.Res.vis = get_Q3D(MOD, MOD.Mission.dp, MOD.W.des, "viscous"); %viscous analysis to obtain Drag

% Run Performance (Range) 
MOD = get_Performance(MOD, REF); 

% Minimize -Range
R = -MOD.Performance.R

%% Volume calculation
Wing_Volume = get_Wing_Volume(MOD, 150, 300);

MOD.Fuel_Tank.VolumeTank = 0.93 * Wing_Volume;
MOD.Fuel_Tank.FuelDensity = 0.81715*1e3; % kg/m^3  
MOD.Fuel_Tank.Available_fuel_mass = MOD.Fuel_Tank.VolumeTank * MOD.Fuel_Tank.FuelDensity;

disp('ITERATION FINISHED')
end