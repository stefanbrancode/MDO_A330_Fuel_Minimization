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

lb = [ -Inf, -Inf , 0.01*pi/180 , 0, ...
    0.9*Ref.Mission.Ma, ...
    0.9*Ref.Mission.H, ...
    0.5*Ref.Mission.W.Fuel, ...
    0, -0.3, -0.3, -0.3, -0.05, ...
    -0.2, -0.5, -0.5, -0.5, -0.05]; 
ub = [ Inf, Inf, 70*pi/180 , 1, ... 
    1.1*Ref.Mission.Ma, ...
    1.1*Ref.Mission.H, ...
    Ref.Mission.W.Fuel, ...
    0.2, 0.5, 0.5, 0.5, 0.05, ...
    0,    0.3,  0.3,  0.3,  0.05]; 

MOD.Name = "A330-300_MOD";
"MOD_Airfoil_Coords"
% Optimasation options
options.Display         = 'iter-detailed';
options.Algorithm       = 'sqp';
%options.FunValCheck     = 'off';
options.TolCon          = 1e-6;         % Maximum difference between two subsequent constraint vectors [c and ceq]
options.TolFun          = 1e-6;         % Maximum difference between two subsequent objective value
options.TolX            = 1e-6;         % Maximum difference between two subsequent design vectors
options.MaxIter         = 10;          % Maximum iterations


%% -------------------- Derived parameters & initialization ----------------


%x=[root chord, LE sweep angle, Taper ratio, span kink to tip]
%x0 = [Ref.Wing.c(1) , Ref.Wing.sweepLE , Ref.Wing.c(3)/Ref.Wing.c(2) , Ref.Wing.y(3)-Ref.Wing.y(2), Ref.Mission.dp.M ,Ref.Mission.dp.alt ,Ref.Wing.Airfoil.CST_up , Ref.Wing.Airfoil.CST_low];
x0= get_Design_Vector(Ref)

%% -------------------- Optimization --------------------------
tic;
[x,R_opt,EXITFLAG,OUTPUT] = fmincon(@(x) Optimization(x),x0,[],[],[],[],lb,ub,@(x) Constraint(x),options);
tSolver = toc;
R_opt



%% -------------------- Outputs and Visualization ------------------------------------
print_WingPlanfrom(Ref, Mod);




%% -------------------- Nested ODE function -------------------------------
% Empty as located in different files