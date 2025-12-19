function print_WingPlanfrom(REF, MOD)


% Replace Ref, Mod
% Ref.Wing.span = 60.3;
% Ref.y = [0 18.74/2 Ref.b/2]; 
% Ref.x = sin(30*pi/180) * Ref.y;
% Ref.c = [8 5 2]; 
% 
% Mod.b = 65;
% Mod.y = [0 18.74/2 Mod.b/2]; 
% Mod.x = sin(35*pi/180) * Mod.y;
% Mod.c = [9 4 1];  

w_fuselage = 5.64/2; 
x_door1 = -8;
x_door2 = 15;
w_door = 1;
h_door = 1;

% REF.Engine.y = 18.74/2; % Source Airbus
x_engine = 2; 
d_engine = 2.47/2; % Source Wiki
d_engine2 = 1.5/2;
l_engine = 5.639; % Source Wiki
l_engine2 = 2.5; 

x_sparfront = REF.Wing.x + REF.Struct.spar_front.*REF.Wing.c;
x_sparrear = REF.Wing.x + REF.Struct.spar_rear.*REF.Wing.c;

% X_planf=[AC.Wing.Geom(1,4),AC.Wing.Geom(1,1),AC.Wing.Geom(2,1),AC.Wing.Geom(2,1)+AC.Wing.Geom(2,4),AC.Wing.Geom(1,4)];
% Y_planf=[AC.Wing.Geom(1,2),AC.Wing.Geom(1,2),AC.Wing.Geom(2,2),AC.Wing.Geom(2,2),AC.Wing.Geom(1,2)];
% 
% figure 
% plot (Y_planf,X_planf)

%% Printing 
figure; hold on;
% Fuselage
line([-20, max(max(REF.Wing.x , MOD.Wing.x))+10], [0, 0], Color="black", LineStyle="-.")
line([-20, max(max(REF.Wing.x , MOD.Wing.x))+10], [w_fuselage , w_fuselage], 'Color', [0.75 0.75 0.75], LineStyle="-", LineWidth=1.6)
% Door 1
line([x_door1-w_door, x_door1-w_door], [w_fuselage , w_fuselage-h_door],        'Color', [0.75 0.75 0.75], LineStyle="-", LineWidth=1)
line([x_door1-w_door, x_door1+w_door], [w_fuselage-h_door, w_fuselage-h_door],  'Color', [0.75 0.75 0.75], LineStyle="-", LineWidth=1)
line([x_door1+w_door, x_door1+w_door], [w_fuselage-h_door, w_fuselage],         'Color', [0.75 0.75 0.75], LineStyle="-", LineWidth=1)
% Door 2
line([x_door2-w_door, x_door2-w_door], [w_fuselage , w_fuselage-h_door],        'Color', [0.75 0.75 0.75], LineStyle="-", LineWidth=1)
line([x_door2-w_door, x_door2+w_door], [w_fuselage-h_door, w_fuselage-h_door],  'Color', [0.75 0.75 0.75], LineStyle="-", LineWidth=1)
line([x_door2+w_door, x_door2+w_door], [w_fuselage-h_door, w_fuselage],         'Color', [0.75 0.75 0.75], LineStyle="-", LineWidth=1)
% Engine
line([x_engine, x_engine], [REF.Engine.y-d_engine , REF.Engine.y+d_engine],  'Color', [0.75 0.75 0.75], LineStyle="-", LineWidth=1)
line([x_engine, x_engine+l_engine2], [REF.Engine.y+d_engine , REF.Engine.y+d_engine],  'Color', [0.75 0.75 0.75], LineStyle="-", LineWidth=1)
line([x_engine+l_engine2, x_engine+l_engine], [REF.Engine.y+d_engine , REF.Engine.y+d_engine2],  'Color', [0.75 0.75 0.75], LineStyle="-", LineWidth=1)
line([x_engine+l_engine, x_engine+l_engine], [REF.Engine.y+d_engine2 , REF.Engine.y-d_engine2],  'Color', [0.75 0.75 0.75], LineStyle="-", LineWidth=1)
line([x_engine+l_engine, x_engine+l_engine2], [REF.Engine.y-d_engine2 , REF.Engine.y-d_engine],  'Color', [0.75 0.75 0.75], LineStyle="-", LineWidth=1)
line([x_engine+l_engine2, x_engine], [REF.Engine.y-d_engine , REF.Engine.y-d_engine],  'Color', [0.75 0.75 0.75], LineStyle="-", LineWidth=1)

% Reference Aircraft
% Leading and Trailing Edges
line([REF.Wing.x(1),                REF.Wing.x(3)               ], [REF.Wing.y(1), REF.Wing.y(3)], Color="black", LineStyle="--", LineWidth=1)
line([REF.Wing.x(3)+REF.Wing.c(3),  REF.Wing.x(2)+REF.Wing.c(2) ], [REF.Wing.y(3), REF.Wing.y(2)], Color="black", LineStyle="--", LineWidth=1)
line([REF.Wing.x(2)+REF.Wing.c(2),  REF.Wing.x(1)+REF.Wing.c(1) ], [REF.Wing.y(2), REF.Wing.y(1)], Color="black", LineStyle="--", LineWidth=1)
% Choords
% line([Ref.x(1), Ref.x(1)+Ref.c(1)], [Ref.y(1), Ref.y(1)], Color="black", LineStyle="--", LineWidth=1)
line([REF.Wing.x(2),                REF.Wing.x(2)+REF.Wing.c(2) ], [REF.Wing.y(2), REF.Wing.y(2)], Color="black", LineStyle="--", LineWidth=1)
line([REF.Wing.x(3),                REF.Wing.x(3)+REF.Wing.c(3) ], [REF.Wing.y(3), REF.Wing.y(3)], Color="black", LineStyle="--", LineWidth=1)
% Spar
line(x_sparfront, REF.Wing.y, Color="black", LineStyle="--", LineWidth=3);
line(x_sparrear, REF.Wing.y, Color="black", LineStyle="--", LineWidth=3);

% Modified Wing Geometry
% Leading and Trailing Edges
line([MOD.Wing.x(1), MOD.Wing.x(3)], [MOD.Wing.y(1), MOD.Wing.y(3)], Color="black", LineStyle="-", LineWidth=1)
line([MOD.Wing.x(3)+MOD.Wing.c(3), MOD.Wing.x(2)+MOD.Wing.c(2)], [MOD.Wing.y(3), MOD.Wing.y(2)], Color="black", LineStyle="-", LineWidth=1)
line([MOD.Wing.x(2)+MOD.Wing.c(2), MOD.Wing.x(1)+MOD.Wing.c(1)], [MOD.Wing.y(2), MOD.Wing.y(1)], Color="black", LineStyle="-", LineWidth=1)
% Choords
% line([Ref.x(1), Ref.x(1)+Ref.c(1)], [Ref.y(1), Ref.y(1)], Color="black", LineStyle="--", LineWidth=1)
line([MOD.Wing.x(2), MOD.Wing.x(2)+MOD.Wing.c(2)], [MOD.Wing.y(2), MOD.Wing.y(2)], Color="black", LineStyle="-", LineWidth=1)
line([MOD.Wing.x(3), MOD.Wing.x(3)+MOD.Wing.c(3)], [MOD.Wing.y(3), MOD.Wing.y(3)], Color="black", LineStyle="-", LineWidth=1)
% Spar
line(x_sparfront, REF.Wing.y, Color="black", LineStyle="-", LineWidth=3);
line(x_sparrear, REF.Wing.y, Color="black", LineStyle="-", LineWidth=3);

%%  Visulasation Parapeters
grid on
title("Wing Planform")
xlabel("x [m]")  % \eta=y*2/b
ylabel("y [m]")  % \eta=y*2/b
xlim([-6, max(max(REF.Wing.x(3)+REF.Wing.c(3), MOD.Wing.x(3)+MOD.Wing.c(3)))+2])
ylim([-1, max(REF.Wing.span, MOD.Wing.span)/2+2])
axis equal          % Make data units equal
box on

% Lock the physical aspect ratio (this is the key line)
pbaspect([1 1 1])   % Ensures 1 meter in X looks exactly like 1 meter in Y
end