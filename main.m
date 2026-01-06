%% Multi Disciplinary Optimization
% Pipe Flow and Pressure Simulation
% Based on: AE4263 - Module 1 Pipe Example
% Author: Lukas Deuschle
% Date: 2025-11-12

clear; clc; close all;

folders = ["functions", "Q3D", "EMWET 1.5"];
for i = 1:length(folders)
    addpath(genpath(folders{i}));
    disp(['Folder added: ', folders{i}]);
end
% Refernce Aircraft
load("A330-300.mat")
Ref=REF;
%define new object to be modified
MOD=REF;
MOD.Name = "A330-300_MOD"; %change the name
%% -------------------- Derived parameters & initialization ----------------

%bound on LE sweep: LE sweep> TE sweep => wing becomes thinner
%bound on taper 0.2 => Tip too pointy => decrease in local Reynolds =>Tip stall
%bounds for optimizer
lb = [ Ref.Wing.c(1)*0.8, 0.8*REF.Wing.sweepLE , 0.8 * (Ref.Wing.c(3)/Ref.Wing.c(2))  , 0.8*(Ref.Wing.y(3)-Ref.Wing.y(2)), ...
    0.9*Ref.Mission.dp.M, ...
    0.9*Ref.Mission.dp.alt, ...
    0.8*Ref.Wing.Airfoil.CST_up, ...
    0.8* Ref.Wing.Airfoil.CST_low]; 

%upper bound on spanwise distance between kink and tip such that the span
%is smaller that 65 m % 65/2 - Ref.Wing.y(2)
%bound on LE sweep <35-40 deg: penalty due to torsion outweighs the sweep buff
%bound on taper 0.5 => Tip wide=> large bending moment
ub = [ Ref.Wing.c(1)*1.2 , 1.1*REF.Wing.sweepLE , 1.2 * (Ref.Wing.c(3)/Ref.Wing.c(2)) , 1.2*(Ref.Wing.y(3)-Ref.Wing.y(2)), ... 
    1.1*Ref.Mission.dp.M, ...
    1.1*Ref.Mission.dp.alt, ...
    1.2*Ref.Wing.Airfoil.CST_up, ...
    1.2*Ref.Wing.Airfoil.CST_low]; 
%normalized bounds for optimizer hypercube
lb_norm = zeros(1, length(lb));
ub_norm = ones(1, length(ub));

%% SIMPLYFY OPTIMIZATION: REDUCE NUMBER OF VARIABLES

fields_active = { ...
    'root_chord', ...
    'leadingEdgeSweep', ...
    'TaperRatio_Tip_To_Kink', ...
    'span_Tip_To_Kink', ...
    'Mach', ...
    'altitude', ...
    'CST_up', ...
    'CST_low' ...
    
    % 'CST_up' and 'CST_low' are excluded
};

%x0 = [Ref.Wing.c(1) , Ref.Wing.sweepLE , Ref.Wing.c(3)/Ref.Wing.c(2) , Ref.Wing.y(3)-Ref.Wing.y(2), Ref.Mission.dp.M ,Ref.Mission.dp.alt ,Ref.Wing.Airfoil.CST_up , Ref.Wing.Airfoil.CST_low];
x0 = get_Design_Vector(Ref);
x0_normalized = Normalize_Design_Vector(x0,lb,ub); 
x_struct = Design_Vector_To_Struct(x0, fields_active);
lb_struct = Design_Vector_To_Struct(lb,fields_active);
ub_struct = Design_Vector_To_Struct(ub, fields_active);
disp(x_struct);

% Initialize empty arrays
x0_active = [];
lb_active = [];
ub_active = [];

% Loop through fields and concatenate (append) values
for i = 1:length(fields_active)
    fieldName = fields_active{i};
    
    % Extract the value (which might be a scalar OR a vector like CST)
    val_current = x_struct.(fieldName);
    val_lb      = lb_struct.(fieldName);
    val_ub      = ub_struct.(fieldName);
    
    % Append to the main vectors
    % This handles both scalars and vectors (like CST) automatically
    x0_active = [x0_active, val_current];
    lb_active = [lb_active, val_lb];
    ub_active = [ub_active, val_ub];
    
    % Optional: Debug print to see what is being added
    fprintf('Added %s: size %d\n', fieldName, length(val_current));
end


% Normalize active variables if needed
x0_active_norm = Normalize_Design_Vector(x0_active, lb_active, ub_active);
lb_active_norm = zeros(size(lb_active)); 
ub_active_norm = ones(size(ub_active));


%% Define solver settings 

% Optimization options
options.Display         = 'iter-detailed';
options.Algorithm       = 'sqp';
options.FunValCheck     = 'off';
options.DiffMinChange   = 1e-2;
options.DiffMaxChange   = 0.1;
options.MaxFunctionEvaluations= 10000;
options.TolCon          = 1e-6;         % Maximum difference between two subsequent constraint vectors [c and ceq]
options.TolFun          = 1e-6;         % Maximum difference between two subsequent objective value
options.TolX            = 1e-6;         % Maximum difference between two subsequent design vectors
options.MaxIter         = 20;          % Maximum iterations
    
%% -------------------- Optimization --------------------------
tic;
%Optimization_Stefan takes as input the non-normalized bounds in order to
%revert the normalization.
[x,R_opt,EXITFLAG,OUTPUT] = fmincon(@(x_active_norm) Optimization_Stefan(MOD, x_active_norm , Ref , lb_active , ub_active , fields_active ) , x0_active_norm , [] , [] , [] , [] , lb_active_norm , ub_active_norm , @(x_normalized) Constraints(x_normalized, MOD, Ref ) , options);
tSolver = toc;
%% Unpack solution
solution = Denormalize_Design_Vector(x,lb_active,ub_active); 
solution_struct = Design_Vector_To_Struct(x,fields_active);

%% -------------------- Outputs and Visualization ------------------------------------
x0 = Design_Vector_To_Struct( Denormalize_Design_Vector(x0_active_norm,lb_active,ub_active) , fields_active );
x_opt = Design_Vector_To_Struct( Denormalize_Design_Vector(x,lb_active,ub_active) , fields_active );

xcompare=[Ref.Performance.R, Denormalize_Design_Vector(x0_active_norm,lb_active,ub_active) ; MOD.Performance.R, Denormalize_Design_Vector(x,lb_active,ub_active)];
load("A330-300_MOD.mat")
print_WingPlanfrom(REF,MOD)

Plot_Airfoils(x_opt,x0);


%% -------------------- Nested ODE function -------------------------------
% Empty as located in different files