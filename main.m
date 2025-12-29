%% Multi Disciplinary Optimization
% Pipe Flow and Pressure Simulation
% Based on: AE4263 - Module 1 Pipe Example
% Author: Lukas Deuschle
% Date: 2025-11-12

clear; clc; close all;

% Refernce Aircraft
load("A330-300.mat")
Ref=REF;
%define new object to be modified
MOD=REF;
MOD.Name = "A330-300_MOD"; %change the name

%% -------------------- Derived parameters & initialization ----------------

%bounds for optimizer
lb = [ Ref.Wing.c(1)*0.5, 0.01*pi/180 , 0 , 0, ...
    0.9*Ref.Mission.dp.M, ...
    0.9*Ref.Mission.dp.alt, ...
    -5, -5, -5, -5, -5, ...
    -5, -5, -5, -5, -5]; 

ub = [ Ref.Wing.c(1)*1.5 , 70*pi/180 , 1 , 2*(Ref.Wing.y(3)-Ref.Wing.y(2)), ... 
    1.1*Ref.Mission.dp.M, ...
    1.1*Ref.Mission.dp.alt, ...
    5, 5, 5, 5, 5, ...
    5, 5, 5, 5, 5]; 
%normalized bounds for optimizer hypercube
lb_norm = zeros(1, length(lb));
ub_norm = ones(1, length(ub));

%% SIMPLYFY OPTIMIZATION: REDUCE NUMBER OF VARIABLES

fields_active = { ...
    'root_chord', ...
    'leadingEdgeSweep', ...
    'TaperRatio_Tip_To_Kink', ...
    'span_Tip_To_Kink', ...
    %'Mach', ...
    %'altitude' ...
    % 'CST_up' and 'CST_low' are excluded
};

%x0 = [Ref.Wing.c(1) , Ref.Wing.sweepLE , Ref.Wing.c(3)/Ref.Wing.c(2) , Ref.Wing.y(3)-Ref.Wing.y(2), Ref.Mission.dp.M ,Ref.Mission.dp.alt ,Ref.Wing.Airfoil.CST_up , Ref.Wing.Airfoil.CST_low];
x0 = get_Design_Vector(Ref);
x0_normalized = Normalize_Design_Vector(x0,lb,ub); 
x_struct = Design_Vector_To_Struct(x0, fields_active);
lb_struct = Design_Vector_To_Struct(lb,fields_active);
ub_struct = Design_Vector_To_Struct(ub, fields_active);
disp(x_struct);


x0_active = zeros(1,length(fields_active));
lb_active = zeros(1,length(fields_active));
ub_active = zeros(1,length(fields_active));

for i = 1:length(fields_active)
    x0_active(i) = x_struct.(fields_active{i});
    lb_active(i) = lb_struct.(fields_active{i});
    ub_active(i) = ub_struct.(fields_active{i});
end

% Normalize active variables if needed
x0_active_norm = Normalize_Design_Vector(x0_active, lb_active, ub_active);
lb_active_norm = zeros(size(lb_active)); 
ub_active_norm = ones(size(ub_active));


%% Define solver settings 

% Optimization options
options.Display         = 'iter-detailed';
options.Algorithm       = 'sqp';
%options.FunValCheck     = 'off';
options.MaxFunctionEvaluations= 100;
options.TolCon          = 1e-6;         % Maximum difference between two subsequent constraint vectors [c and ceq]
options.TolFun          = 1e-6;         % Maximum difference between two subsequent objective value
options.TolX            = 1e-6;         % Maximum difference between two subsequent design vectors
options.MaxIter         = 5;          % Maximum iterations



%% -------------------- Optimization --------------------------
tic;
%Optimization_Stefan takes as input the non-normalized bounds in order to
%revert the normalization.
[x,R_opt,EXITFLAG,OUTPUT] = fmincon(@(x_active_norm) Optimization_Stefan(MOD, x_active_norm , Ref , lb_active , ub_active , fields_active ) , x0_active_norm , [] , [] , [] , [] , lb_active_norm , ub_active_norm , @(x_normalized) Constraints(x_normalized, MOD, Ref ) , options);
tSolver = toc;
%% Unpack solution
solution = Denormalize_Design_Vector(x,lb_active,ub_active); 
solution_struct = Design_Vector_To_Struct(x,fields_active);

%delete
dummy = solution*1.00001;
dummy_struct = Design_Vector_To_Struct( dummy , fields_active );
DUMMY_DESIGN= REF;
Rnew = Optimization_Stefan(DUMMY_DESIGN, dummy , Ref , lb_active , ub_active , fields_active)
DUMMY_DESIGN= get_Geometry_new(DUMMY_DESIGN, dummy_struct);

MOD = get_Geometry_new(MOD , solution_struct);

%% -------------------- Outputs and Visualization ------------------------------------
print_WingPlanfrom(Ref, DUMMY_DESIGN);

xcompare=[Ref.Performance.R, Denormalize_Design_Vector(x0_active_norm,lb_active,ub_active) ; MOD.Performance.R, Denormalize_Design_Vector(x,lb_active,ub_active)]

%% Save Optimized Aircraft File
save("A330-300_MOD.mat", "MOD");   % saves AC data  into a .mat file


%% -------------------- Nested ODE function -------------------------------
% Empty as located in different files