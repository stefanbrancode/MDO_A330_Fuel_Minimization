function plot_Wing3D(REF, MOD, Resolution)
% plot_Wing3D
% -------------------------------------------------------------------------
% Plots REF and MOD wing geometries in a single 3D isometric view.
% Includes:
%   - Wing planform
%   - CST-based airfoil sections
%   - Dihedral and twist
%
% INPUTS:
%   REF - Reference aircraft struct
%   MOD - Modified aircraft struct
% -------------------------------------------------------------------------

%% --- Global plot settings ---
set(groot,'defaultTextInterpreter','latex');
set(groot,'defaultAxesTickLabelInterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');

fig = figure; hold on; grid on;
view(35,25);
axis equal;

%% --- Settings ---
ACs   = {REF, MOD};
% Colors for plotting (MOD, REF)
names = {'original A330-300'; 'modified A330-300'};
colors = ["#000000"; "#80B3FF"];   % black (REF), blue (MOD)

Nx = 80;                         % chordwise resolution
x_c = linspace(0,1,Nx)';

%% --- Loop over aircraft (REF / MOD) ---
for k = 1:2

    AC = ACs{k};

    %% --- Generate CST airfoil (normalized) ---
    [Xtu, Xtl, ~, ~, ~, ~] = D_airfoil2( ...
        AC.Wing.Airfoil.CST_up, ...
        AC.Wing.Airfoil.CST_low, ...
        x_c);

    airfoil_x = [Xtu(:,1); flipud(Xtl(:,1))];
    airfoil_z = [Xtu(:,2); flipud(Xtl(:,2))];

    Ns = length(AC.Wing.y);

    %% --- Spanwise stations ---
    for i = 1:Ns

        % Local geometry
        y  = AC.Wing.y(i);
        z  = AC.Wing.z(i);
        c  = AC.Wing.c(i);
        x0 = AC.Wing.x(i);
        tw  = conv_unit('degree', 'rad', AC.Wing.twist(i)+AC.Wing.inc);

        % Scale airfoil
        X = c * airfoil_x;
        Z = c * airfoil_z;
        Y = zeros(size(X));

        % Twist (about local y-axis)
        R_tw = [ cos(tw)  0  sin(tw);
                 0        1  0;
                -sin(tw)  0  cos(tw) ];

        coords = R_tw * [X'; Y'; Z'];

        % Global translation
        Xg = coords(1,:) + x0;
        Yg = coords(2,:) + y;
        Zg = coords(3,:) + z;

        % Plot airfoil section
        plot3(Xg, Yg, Zg, ...
            'Color', colors(k), ...
            'LineWidth', 0.8, ...
            'HandleVisibility','off');
    end

    %% --- Planform reference (LE & TE) ---
    h(k) = plot3( ...
        AC.Wing.x, AC.Wing.y, AC.Wing.z, ...
        '-', 'Color', colors(k), 'LineWidth', 1.5);

    plot3( ...
        AC.Wing.x + AC.Wing.c, AC.Wing.y, AC.Wing.z, ...
        '-', 'Color', colors(k), 'LineWidth', 1.5, ...
        'HandleVisibility','off');

end

%% --- Labels & legend ---
xlabel('$x$ [m]');
ylabel('$y$ [m]');
zlabel('$z$ [m]');
% title('3D Wing Geometry (REF vs MOD)');

legend(h, names, 'Location','northeast');

hold off;

% Save as high-quality PNG
cd 'Figures'
exportgraphics(fig, 'Wing_IsentropicView.png', 'Resolution', Resolution);
cd '..'

end
