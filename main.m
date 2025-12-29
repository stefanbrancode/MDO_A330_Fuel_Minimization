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
load("A330-300.mat")
Ref=REF;
%
%Ref.Airfoil.upper.x = [];
%Ref.Airfoil.upper.y = [];
%Ref.Airfoil.lower.x = [];
%Ref.Airfoil.lower.y = [];

lb = [ Ref.Wing.c(1)*0.5, 0.01*pi/180 , 0 , 0, ...
    0.9*Ref.Mission.dp.M, ...
    0.9*Ref.Mission.dp.alt, ...
    0.5*Ref.fueltankData.Volume, ...
    -5, -5, -5, -5, -5, ...
    -5, -5, -5, -5, -5]; 

ub = [ Ref.Wing.c(1)*1.5 , 70*pi/180 , 1 , 2*(Ref.Wing.y(3)-Ref.Wing.y(2)), ... 
    1.1*Ref.Mission.dp.M, ...
    1.1*Ref.Mission.dp.alt, ...
    1.5*Ref.fueltankData.Volume, ...
    5, 5, 5, 5, 5, ...
    5, 5, 5, 5, 5]; 

lb_norm = zeros(1, length(lb));
ub_norm = ones(1, length(ub));
MOD=REF;
MOD.Name = "A330-300_MOD";
"MOD_Airfoil_Coords"
% Optimasation options
options.Display         = 'iter-detailed';
options.Algorithm       = 'sqp';
%options.FunValCheck     = 'off';
options.MaxFunctionEvaluations= 30;
options.TolCon          = 1e-6;         % Maximum difference between two subsequent constraint vectors [c and ceq]
options.TolFun          = 1e-6;         % Maximum difference between two subsequent objective value
options.TolX            = 1e-6;         % Maximum difference between two subsequent design vectors
options.MaxIter         = 1;          % Maximum iterations


%% -------------------- Derived parameters & initialization ----------------


%x=[root chord, LE sweep angle, Taper ratio, span kink to tip]
%x0 = [Ref.Wing.c(1) , Ref.Wing.sweepLE , Ref.Wing.c(3)/Ref.Wing.c(2) , Ref.Wing.y(3)-Ref.Wing.y(2), Ref.Mission.dp.M ,Ref.Mission.dp.alt ,Ref.Wing.Airfoil.CST_up , Ref.Wing.Airfoil.CST_low];
x0 = get_Design_Vector(Ref);
x0_normalized = Normalize_Design_Vector(x0,lb,ub); 
%% -------------------- Optimization --------------------------
tic;
[x,R_opt,EXITFLAG,OUTPUT] = fmincon(@(x_normalized) Optimization_Stefan(MOD, x_normalized,Ref,lb,ub),x0_normalized,[],[],[],[],lb_norm,ub_norm,@(x_normalized) Constraints(x_normalized, MOD, Ref ),options);
tSolver = toc;
R_opt



%% -------------------- Outputs and Visualization ------------------------------------
print_WingPlanfrom(Ref, MOD);
disp(x)
disp(x0)
xcompare=[Ref.Performance.R, x0 ; MOD.Performance.R, Denormalize_Design_Vector(x)]

%% Save Optimized Aircraft File
save("A330-300_MOD.mat", "MOD");   % saves AC data  into a .mat file


%% -------------------- Nested ODE function -------------------------------
% Empty as located in different files