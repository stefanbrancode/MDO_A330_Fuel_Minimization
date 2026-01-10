function plot_Airfoil(REF, MOD, Resolution)
% plot_Airfoil
% -------------------------------------------------------------------------
% Plots the reference and modified airfoil shapes using CST coefficients.
%
% INPUTS:
%   REF - Reference aircraft structure containing:
%         REF.Wing.Airfoil.CST_up   (upper CST coefficients)
%         REF.Wing.Airfoil.CST_low  (lower CST coefficients)
%
%   MOD - Modified aircraft structure containing:
%         MOD.Wing.Airfoil.CST_up
%         MOD.Wing.Airfoil.CST_low
%
% The airfoils are evaluated along the chord from x = 0 to x = 1 using the
% function D_airfoil2.
% -------------------------------------------------------------------------

%% --- Plot formatting (LaTeX enabled) ---
set(groot,'defaultTextInterpreter','latex');
set(groot,'defaultAxesTickLabelInterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');

%% --- Chordwise evaluation points ---
X_vect = linspace(0, 1, 500)';   % Normalized chord positions

%% --- Collect CST coefficients ---
% Row 1: Modified airfoil
% Row 2: Reference airfoil
CST_up  = [REF.Wing.Airfoil.CST_up;
           MOD.Wing.Airfoil.CST_up];

CST_low = [REF.Wing.Airfoil.CST_low;
           MOD.Wing.Airfoil.CST_low];

%% --- Plot setup ---
fig = figure;
hold on;
grid on;

% Colors for plotting (REF, MOD)
colors = ["#64a6ea"; "#e6a26e"];
names  = ['original A330-300'; 'modified A330-300'];

%% --- Loop over airfoils ---
for i = 1:2

    % Generate airfoil coordinates from CST coefficients
    [Xtu, Xtl, ~, ~, ~, ~] = D_airfoil2( ...
        CST_up(i,:), CST_low(i,:), X_vect);

    % Plot upper and lower surfaces
    h(i) = plot(Xtu(:,1), Xtu(:,2), 'Color', colors(i), 'LineWidth', 1.5);
    plot(Xtl(:,1), Xtl(:,2), 'Color', colors(i), 'LineWidth', 1.5);

end

%% --- Axis formatting ---
axis([-0.1, 1.1, -0.1, 0.1]);

ylabel('$y/c$');
xlabel('$x/c$');

legend(h, names, 'Location','northeast');

hold off;

% Save as high-quality PNG
cd 'Figures'
exportgraphics(fig, 'Airfoil.png', 'Resolution', Resolution);
cd '..'
end


