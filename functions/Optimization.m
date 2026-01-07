function f = Optimization(MOD, REF, x_norm, lb, ub)
% Denormilaize design vector
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
f = -MOD.Performance.R;     % We optimize -R to maximize
if isnan(f) || isinf(f)
    f = 0;             % Penalty for invalid design           
end

fprintf('OPTIMISATION ITERATION FINISHED     R: %.0f m \n', MOD.Performance.R)
end