function MOD = get_newAC(x_norm, x0, REF)

MOD = REF;

% Denormilaize design vector
x = x_norm .* abs(x0); 

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
try
    MOD.Res.vis = get_Q3D(MOD, MOD.Mission.dp, MOD.W.des, "viscous"); %viscous analysis to obtain Drag
    MOD.Res.induced = get_Q3D(MOD, MOD.Mission.dp, MOD.W.des, "inviscid"); %viscous analysis to obtain Drag
catch error
    fprintf('Error occurred: %s\n', error.message);
    MOD.Res.vis.CLwing = NaN;
    MOD.Res.vis.CDwing = NaN;
end

% Run Performance (Range) 
MOD = get_Performance(MOD, REF);
end