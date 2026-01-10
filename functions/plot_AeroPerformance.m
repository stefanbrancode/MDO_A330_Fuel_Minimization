function plot_AeroPerformance(REF, MOD, Resolution)
%% plot_AeroPerformance
% Creates overlapped spanwise aerodynamic performance plots for
% reference (REF) and modified (MOD) aircraft configurations.
%
% Figures generated:
%   1) Spanwise lift distribution (C_l * c)
%   2) Spanwise drag distribution (C_d * c)
%
% Figures are automatically exported to ./Figures with the specified
% resolution.
%
% INPUTS:
%   REF        - Reference aircraft data structure
%   MOD        - Modified aircraft data structure
%   Resolution - Export resolution in DPI (e.g. 300)

%% ------------------------------------------------------------------------
% Global plotting defaults (LaTeX everywhere)
% -------------------------------------------------------------------------
set(groot,'defaultTextInterpreter','latex')
set(groot,'defaultAxesTickLabelInterpreter','latex')
set(groot,'defaultLegendInterpreter','latex')

%% ------------------------------------------------------------------------
% Plot styling
% -------------------------------------------------------------------------
colors.REF = "#64a6ea"; 
colors.MOD = "#e6a26e";   

line.design   = "-";
line.critical = "--";

labels = {"REF","MOD"};

%% ------------------------------------------------------------------------
% Non-dimensional spanwise coordinates
% -------------------------------------------------------------------------
REF.eta_Wing = REF.Res.vis.Wing.Yst    / (REF.Wing.span/2);
REF.eta_Sec  = REF.Res.vis.Section.Y  / (REF.Wing.span/2);

MOD.eta_Wing = MOD.Res.vis.Wing.Yst    / (MOD.Wing.span/2);
MOD.eta_Sec  = MOD.Res.vis.Section.Y  / (MOD.Wing.span/2);

%% ------------------------------------------------------------------------
% Chord distributions
% -------------------------------------------------------------------------
REF.c_Wing    = get_Chord(REF.Res.vis.Wing.Yst,   REF);
REF.c_Section = get_Chord(REF.Res.vis.Section.Y, REF);

MOD.c_Wing    = get_Chord(MOD.Res.vis.Wing.Yst,   MOD);
MOD.c_Section = get_Chord(MOD.Res.vis.Section.Y, MOD);

%% ========================================================================
% 1) Spanwise lift distribution (C_l * c)
% ========================================================================
ACs = {REF, MOD};
fig = figure; hold on; box on;

for i = 1:2
    AC = ACs{i};

    % Design point
    h(i, 1) = plot(AC.eta_Wing, AC.Res.vis.Wing.ccl, ...
        'Color', colors.(labels{i}), ...
        'LineStyle', line.design, ...
        'LineWidth', 1.2);

    % Critical conditions
    h(i, 2) =plot(AC.eta_Wing, AC.Res.invis.Wing.ccl, ...
        'Color', colors.(labels{i}), ...
        'LineStyle', line.critical, ...
        'LineWidth', 1.2);
end

grid on
xlabel("$\eta = \frac{y}{b/2} \; [-]$")
ylabel("$C_l \cdot c \; [m]$")
% Table-style legend
createLegendTable(h, {"Design","Critical"}, ...
    {"Initial","Modified"})

% Save figure
exportFigure(fig, "Spanwise_Lift_distribution.png", Resolution)

%% ========================================================================
% 2) Spanwise drag distribution (C_d * c)
% ========================================================================
fig = figure; hold on; box on;

for i = 1:2
    AC = ACs{i};

    % Induced drag
    h(i, 1) = plot(AC.eta_Wing, AC.Res.vis.Wing.cdi .* AC.c_Wing, ...
        'Color', colors.(labels{i}), ...
        'LineStyle', line.design, ...
        'LineWidth', 1.2);

    % Profile + wave drag
    h(i, 2) = plot(AC.eta_Sec, AC.Res.vis.Section.Cd .* AC.c_Section, ...
        'Color', colors.(labels{i}), ...
        'LineStyle', line.critical, ...
        'LineWidth', 1.2);
end

grid on
xlabel("$\eta = \frac{y}{b/2} \; [-]$")
ylabel("$C_d \cdot c \; [m]$")

% Table-style legend
createLegendTable(h, {"Induced","Profile + Wave"}, ...
    {"Initial","Modified"})

% Save figure
exportFigure(fig, "Spanwise_Drag_distribution.png", Resolution)

end


%% ========================================================================
% Helper functions
% ========================================================================

function c = get_Chord(y, AC)
% Computes local chord distribution for a piecewise trapezoidal wing

c = zeros(size(y));

for i = 1:numel(y)
    if y(i) <= AC.Wing.y(2)
        c(i) = AC.Wing.c(1) + ...
               y(i) * (tan(AC.Wing.sweepTE(1)) - tan(AC.Wing.sweepLE));
    else
        c(i) = AC.Wing.c(2) + ...
               (y(i) - AC.Wing.y(2)) * ...
               (tan(AC.Wing.sweepTE(2)) - tan(AC.Wing.sweepLE));
    end
end

c = c(:); % ensure column vector
end
% -------------------------------------------------------------------------
function createLegendTable(h, colLabels, rowLabels)
% Create a standard 2-column legend with empty labels first (position it roughly)
lgd = legend([h(1, 1), h(2, 1), h(1, 2), h(2, 2)], {'', '', '', ''}, ...
    'NumColumns', 2, 'Location', 'northeast', 'Box', 'off');

% Turn off auto-update
lgd.AutoUpdate = 'off';

% Now overlay a table structure using annotations
ax = gca;
pos = lgd.Position;  % Get legend position

% Adjust position slightly if needed for better alignment
lgd.Position = pos + [-0.035 -0.04 0 0];  % Small shift example
pos = lgd.Position; 

% Add column headers
annotation('textbox', [pos(1)+pos(3)/4 - 0.056, pos(2)+pos(4)-0.013, 0.1, 0.05], ...
    'String', colLabels(1), 'HorizontalAlignment', 'left', ...
    'EdgeColor', 'none');
annotation('textbox', [pos(1)+3*pos(3)/4 - 0.042, pos(2)+pos(4)-0.013, 0.2, 0.05], ...
    'String', colLabels(2), 'HorizontalAlignment', 'left', ...
    'EdgeColor', 'none');

% Add row labels
annotation('textbox', [pos(1)-0.095, pos(2)+pos(4)/2 - 0.012, 0.1, 0.05], ...
    'String', rowLabels(1), 'HorizontalAlignment', 'left', ...
    'EdgeColor', 'none');
annotation('textbox', [pos(1)-0.095, pos(2)+pos(4)/2 - 0.042, 0.1, 0.05], ...
    'String', rowLabels(2), 'HorizontalAlignment', 'left', ...
    'EdgeColor', 'none');
end

% -------------------------------------------------------------------------
function exportFigure(fig, filename, Resolution)
% Exports figure to ./Figures with specified resolution

if ~exist("Figures","dir")
    mkdir("Figures")
end

exportgraphics(fig, fullfile("Figures", filename), ...
    'Resolution', Resolution);
end
