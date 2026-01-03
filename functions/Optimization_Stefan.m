function R = Optimization(AC, x_normalized, REF,lb,ub,fields_active)
%{ design vector is:
%planform
% x(1) = root chrod
% x(2) = leading edge sweep angle
% x(3) = Taper ratio: tip chord/kink chord
% x(4) = span between tip and kink
%Mission parameters
% x(5) = Mach number
% x(6) = height
% x(7) = fuel volume
%airfoil 
% x(8),x(9),x(10), x(11), x(12) = upper CST parameters
% x(13),x(14),x(15), x(16), x(17) = lower CST parameters

x = Denormalize_Design_Vector(x_normalized,lb,ub); 
x_struct = Design_Vector_To_Struct(x,fields_active);

AC = get_Geometry_new(AC,x_struct); %put design vector variables into the aircraft struct
AC = MDAStefan(AC); %MDA consistency loop
AC.Res.vis = get_Q3D(AC, AC.Mission.dp, AC.W.des, "viscous"); %viscous analysis to obtain Drag
AC = get_Performance(AC, REF); % Breguet eqs 
%Minimize -Range
R = -AC.Performance.R 

%% Volume calculation
Wing_Volume = get_Wing_Volume(AC, 150, 300);

AC.fueltankData.Volume = 0.93 * Wing_Volume;
AC.fueltankData.FuelDensity = 0.81715*1e3; % kg/m^3  
AC.fueltankData.Available_fuel_mass = AC.fueltankData.Volume * AC.fueltankData.FuelDensity;

disp('ITERATION FINISHED')
%print_WingPlanfrom(REF,AC);
end