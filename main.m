%% Multi Disciplinary Optimization
% Optimazation of A330-300 Wing for extending the Range
% Based on: MDO AE4
% Author: Lukas Deuschle
% Date: 2025-11-12

% Clear everything
clear; clc; close all;

% Start logging the Command Window
diary optimization_log.txt
diary on

% dbstop if warning
dbclear if warning

%% -------------------- Load Refrence Model ----------------
% Initialize Folders 
folders = ["functions", "Q3d", "EMWET 1.5"];
for i = 1:length(folders)
    addpath(genpath(folders{i}));
    disp(['Folder added: ', folders{i}]);
end

% Load Refernce Aircraft
load("A330-300.mat")

% define new object to be modified
MOD = REF;
MOD.Name = "A330-300_MOD"; %change the name
MOD.Wing.Airfoil_Name = "A330_Airfoil_MOD"; %change the name
MOD.Sim.EMWET_show = 0;

% Resolution of the graphics
MOD.Sim.Graphics.Resolution = 300;  

% 
MOD.Sim.MDA_TOL = 1e-4;
MOD.Sim.MDA_MAXIter = 50;

MOD.Sim.Q3D_MAXIter = 150;

%% ========================================================================
% Initial design vector (x0) and bounds based on REF aircraft
% ========================================================================
x0 = [
    % Mission design point
    REF.Mission.dp.M              % [-] Cruise Mach number
    REF.Mission.dp.alt            % [m] Cruise altitude

    % Weights
    REF.W.fuel                    % [kg] Fuel weight 

    % Wing planform geometry
    REF.Wing.span                 % [m] Wing span
    REF.Wing.c(2)                 % [m] Kink chord
    REF.Wing.sweepLE              % [rad] Leading edge sweep
    REF.Wing.Taper(2)             % [-] Outer panel taper ratio

    % Fuel tank
    REF.Fuel_Tank.eta(2)          % [-] Spanwise fuel tank extent

    % Wing structure
    REF.Struct.spar_front(3)      % [-] Front spar position (outer wing)
    REF.Struct.spar_rear(3)       % [-] Rear spar position (outer wing)

    % Airfoil CST coefficients
    REF.Wing.Airfoil.CST_up(:)    % Upper surface CST coefficients
    REF.Wing.Airfoil.CST_low(:)   % Lower surface CST coefficients
];

% lower bound for optimizer
lb = [
    % Mission design point
    0.9 * REF.Mission.dp.M        % [-] Cruise Mach number
    0.9 * REF.Mission.dp.alt      % [m] Cruise altitude

    % Weights
    0.8 * REF.W.fuel            % [kg] Fuel weight 

    % Wing planform geometry
    0.5 * REF.Wing.span         % [m] Wing span
    0.5 * REF.Wing.c(2)         % [m] Kink chord
    10 * pi/180                 % [rad] Leading edge sweep
    0.1                         % [-] Outer panel taper ratio

    % Fuel tank
    0.5                         % [-] Spanwise fuel tank extent

    % Wing structure
    0.15                        % [-] Front spar position (outer wing)
    0.55                        % [-] Rear spar position (outer wing)

    % Airfoil CST coefficients
    -1 * ones(numel(REF.Wing.Airfoil.CST_up),1)  % Upper surface CST coefficients
    -1 * ones(numel(REF.Wing.Airfoil.CST_low),1) % Lower surface CST coefficients
];

% Upper bounds for optimizer
ub = [
    % Mission design point
    REF.Mission.MO.M                 % [-] Cruise Mach number
    1.1 * REF.Mission.dp.alt         % [m] Cruise altitude

    % Weights
    1 * REF.W.fuel            % [kg] Fuel weight

    % Wing planform geometry
    65                      % [m] Wing span
    1.5 * REF.Wing.c(2)    % [m] Kink chord
    70 * pi/180             % [rad] Leading edge sweep
    1                     % [-] Outer panel taper ratio

    % Fuel tank
    0.85                        % [-] Spanwise fuel tank extent

    % Wing structure
    0.20                        % [-] Front spar position (outer wing)
    0.75                        % [-] Rear spar position (outer wing)

    % Airfoil CST coefficients
    1 * ones(numel(REF.Wing.Airfoil.CST_up),1) % Upper surface CST coefficients
    1 * ones(numel(REF.Wing.Airfoil.CST_low),1) % Lower surface CST coefficients
];

%normalized vektor and bounds for optimizer hypercube
lb_norm = zeros(1, length(lb));
ub_norm = ones(1, length(ub));
x0_norm = Normalize_Design_Vector(x0,lb,ub); 

%% Test and Check Section
check_DesignVectorBounds(x0, lb, ub)

% MOD.Sim.EMWET_show = 1;
% get_EMWET(MOD)
% MOD = MDA(MOD);
% R = Optimization(MOD, REF, x0_norm, lb, ub)

%% Define solver settings 
% Optimization options
options.Display         = 'iter-detailed';
options.OutputFcn       = @(x,optimValues,state) save_Iterations(x, lb, ub, optimValues, state);
options.Algorithm       = 'sqp';
% options.UseParallel     = true;
options.FunValCheck     = 'off';
options.MaxFunctionEvaluations = 100;
options.DiffMinChange   = 1e-2;
options.DiffMaxChange   = 0.05;
options.TolCon          = 1e-6;         % Maximum difference between two subsequent constraint vectors [c and ceq]
options.TolFun          = 1e-6;         % Maximum difference between two subsequent objective value
options.TolX            = 1e-6;         % Maximum difference between two subsequent design vectors
% options.MaxIter         = 100;          % Maximum iterations

%% -------------------- Optimization --------------------------
tic;
% Optimization_Stefan takes as input the non-normalized bounds in order to
% revert the normalization.
[x_opt_norm, R_opt, EXITFLAG, OUTPUT] = fmincon(@(x_norm) Optimization(MOD, REF, x_norm, lb, ub), x0_norm, [], [] , [] , [] , lb_norm, ub_norm, @(x_norm) Constraints(MOD, REF), options);
tSolver = toc;

%% Unpack solution
x_opt = Denormalize_Design_Vector(x_opt_norm, lb_active,ub_active); 

%% -------------------- Outputs and Visualization ------------------------------------
% plot_AeroPerformance(REF, DUMMY_DESIGN, Resolution);
% plot_Airfoil(REF, DUMMY_DESIGN, Resolution);
% plot_WingPlanfrom(REF, DUMMY_DESIGN, Resolution);
% plot_Wing3D(REF, DUMMY_DESIGN, Resolution);

% xcompare = [REF.Performance.R, Denormalize_Design_Vector(x0_active_norm,lb_active,ub_active) ; MOD.Performance.R, Denormalize_Design_Vector(x_opt_norm,lb_active,ub_active)]

%% Save Optimized Aircraft File
save("A330-300_MOD.mat", "MOD");   % saves AC data  into a .mat file

% End the logging of the Command Window
diary off
