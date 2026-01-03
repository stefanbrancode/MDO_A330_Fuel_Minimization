function plot_WingPlanfrom(REF, MOD, Resolution)
set(groot,'defaultTextInterpreter','latex')
set(groot,'defaultAxesTickLabelInterpreter','latex')
set(groot,'defaultLegendInterpreter','latex')

%% --- Settings ---
ACs   = {REF, MOD};
% Colors for plotting (MOD, REF)
names = {'original A330-300'; 'modified A330-300'};
colors = ["#000000"; "#80B3FF"];   % black (REF), blue (MOD)

color_fuse = [0.75 0.75 0.75]; 

%% Paramteters
w_fuselage = 5.64/2; 
x_door1 = -8;
x_door2 = 15;
w_door = 1;
h_door = 1;

x_engine = 2; 
r_engine = REF.Engine.d/2; 
d_engine2 = 1.5/2;
l_eng = REF.Engine.l;
l_eng2 = 2.5;  

x_sparfront = REF.Wing.x + REF.Struct.spar_front.*REF.Wing.c;
x_sparrear = REF.Wing.x + REF.Struct.spar_rear.*REF.Wing.c;

% X_planf=[AC.Wing.Geom(1,4),AC.Wing.Geom(1,1),AC.Wing.Geom(2,1),AC.Wing.Geom(2,1)+AC.Wing.Geom(2,4),AC.Wing.Geom(1,4)];
% Y_planf=[AC.Wing.Geom(1,2),AC.Wing.Geom(1,2),AC.Wing.Geom(2,2),AC.Wing.Geom(2,2),AC.Wing.Geom(1,2)];
% 
% figure 
% plot (Y_planf,X_planf)

%% Printing 
fig = figure; hold on;
% Fuselage
line([-20, max(max(REF.Wing.x , MOD.Wing.x))+10], [0, 0],                       'Color', "black",   LineStyle="-.", LineWidth=2)
line([-20, max(max(REF.Wing.x , MOD.Wing.x))+10], [w_fuselage , w_fuselage],    'Color', color_fuse, LineStyle="-", LineWidth=1.6)
% Door 1
line([x_door1-w_door, x_door1-w_door], [w_fuselage , w_fuselage-h_door],        'Color', color_fuse, LineStyle="-", LineWidth=1)
line([x_door1-w_door, x_door1+w_door], [w_fuselage-h_door, w_fuselage-h_door],  'Color', color_fuse, LineStyle="-", LineWidth=1)
line([x_door1+w_door, x_door1+w_door], [w_fuselage-h_door, w_fuselage],         'Color', color_fuse, LineStyle="-", LineWidth=1)
% Door 2
line([x_door2-w_door, x_door2-w_door], [w_fuselage , w_fuselage-h_door],        'Color', color_fuse, LineStyle="-", LineWidth=1)
line([x_door2-w_door, x_door2+w_door], [w_fuselage-h_door, w_fuselage-h_door],  'Color', color_fuse, LineStyle="-", LineWidth=1)
line([x_door2+w_door, x_door2+w_door], [w_fuselage-h_door, w_fuselage],         'Color', color_fuse, LineStyle="-", LineWidth=1)
% Engine
line([x_engine, x_engine], [REF.Engine.y-r_engine , REF.Engine.y+r_engine],  'Color', color_fuse, LineStyle="-", LineWidth=1)
line([x_engine, x_engine+l_eng2], [REF.Engine.y+r_engine , REF.Engine.y+r_engine],  'Color', color_fuse, LineStyle="-", LineWidth=1)
line([x_engine+l_eng2, x_engine+l_eng], [REF.Engine.y+r_engine , REF.Engine.y+d_engine2],  'Color', color_fuse, LineStyle="-", LineWidth=1)
line([x_engine+l_eng, x_engine+l_eng], [REF.Engine.y+d_engine2 , REF.Engine.y-d_engine2],  'Color', color_fuse, LineStyle="-", LineWidth=1)
line([x_engine+l_eng, x_engine+l_eng2], [REF.Engine.y-d_engine2 , REF.Engine.y-r_engine],  'Color', color_fuse, LineStyle="-", LineWidth=1)
line([x_engine+l_eng2, x_engine], [REF.Engine.y-r_engine , REF.Engine.y-r_engine],  'Color', color_fuse, LineStyle="-", LineWidth=1)

% Initial (REF) and modified (MOD) Aircraft Wing
for i = 1:2
    AC = ACs{i};

    % Leading and Trailing Edges
    h(i) = line([AC.Wing.x(1),        AC.Wing.x(3)              ], [AC.Wing.y(1), AC.Wing.y(3)], 'Color', colors(i), LineStyle="-", LineWidth=1);
    line([AC.Wing.x(3)+AC.Wing.c(3),  AC.Wing.x(2)+AC.Wing.c(2) ], [AC.Wing.y(3), AC.Wing.y(2)], 'Color', colors(i), LineStyle="-", LineWidth=1);
    line([AC.Wing.x(2)+AC.Wing.c(2),  AC.Wing.x(1)+AC.Wing.c(1) ], [AC.Wing.y(2), AC.Wing.y(1)], 'Color', colors(i), LineStyle="-", LineWidth=1);
    % Choords
    line([AC.Wing.x(2),                AC.Wing.x(2)+AC.Wing.c(2) ], [AC.Wing.y(2), AC.Wing.y(2)], 'Color', colors(i), LineStyle="--", LineWidth=1)
    line([AC.Wing.x(3),                AC.Wing.x(3)+AC.Wing.c(3) ], [AC.Wing.y(3), AC.Wing.y(3)], 'Color', colors(i), LineStyle="-", LineWidth=1)
    % Spar
    line(x_sparfront, AC.Wing.y,                                                                  'Color', colors(i), LineStyle="-", LineWidth=3);
    line(x_sparrear, AC.Wing.y,                                                                   'Color', colors(i), LineStyle="-", LineWidth=3);
end

%%  Visulasation Parapeters
grid on; box on;
% title("Wing Planform")
xlabel("x [m]")  % \eta=y*2/b
ylabel("y [m]")  % \eta=y*2/b
axis equal;         % Make data units equal
xlim([-12, max(max(REF.Wing.x(3)+REF.Wing.c(3), MOD.Wing.x(3)+MOD.Wing.c(3)))+3])
ylim([-2, max(REF.Wing.span, MOD.Wing.span)/2+3])

% Lock the physical aspect ratio (this is the key line)
pbaspect([1 1 1])   % Ensures 1 meter in X looks exactly like 1 meter in Y

legend(h, names, 'Location','northwest');

% Save as high-quality PNG
cd 'Figures'
exportgraphics(fig, 'Wing_Planform.png', 'Resolution', Resolution);
% Save as high-quality PNG
cd '..'

end