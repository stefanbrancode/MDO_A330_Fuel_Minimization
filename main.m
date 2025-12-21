%% Multi Disciplinary Optimization
% Pipe Flow and Pressure Simulation
% Based on: AE4263 - Module 1 Pipe Example
% Author: Lukas Deuschle
% Date: 2025-11-12

clear; clc; close all;

%% -------------------- USER INPUTS (edit these) -------------------------
% Refernce Aircraft

%Initialize the vectors for x and y coordinates 
% for the upper and lower parts of the airfoil

Ref.Airfoil.upper.x = [];
Ref.Airfoil.upper.y = [];
Ref.Airfoil.lower.x = [];
Ref.Airfoil.lower.y = [];

lb = [0.9*Ref.Mission.Ma, ...
    0.9*Ref.Mission.H, ...
    0.5*Ref.Mission.W.Fuel]; 
ub = [1.1*Ref.Mission.Ma, ...
    1.1*Ref.Mission.H, ...
    Ref.Mission.W.Fuel]; 

MOD.Name = "A330-300_MOD";
"MOD_Airfoil_Coords"
% Optimasation options
options.Display         = 'iter-detailed';
options.Algorithm       = 'sqp';
%options.FunValCheck     = 'off';
options.TolCon          = 1e-6;         % Maximum difference between two subsequent constraint vectors [c and ceq]
options.TolFun          = 1e-6;         % Maximum difference between two subsequent objective value
options.TolX            = 1e-6;         % Maximum difference between two subsequent design vectors
options.MaxIter         = 1000;          % Maximum iterations


%% -------------------- Derived parameters & initialization ----------------



x0 = [Ref.Ma, ...
    Ref.H, ...
    Ref.W.Fuel];


%% -------------------- Optimization --------------------------
tic;
[x,R_opt,EXITFLAG,OUTPUT] = fmincon(@(x) Optimization(x),x0,[],[],[],[],lb,ub,@(x) Constraint(x),options);
tSolver = toc;
R_opt



%% -------------------- Outputs and Visualization ------------------------------------
print_WingPlanfrom(Ref, Mod);




%% -------------------- Nested ODE function -------------------------------
% Empty as located in different files