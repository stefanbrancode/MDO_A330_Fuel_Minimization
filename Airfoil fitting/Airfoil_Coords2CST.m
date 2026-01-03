%% Generate Airfoil CST from Coordinates
% This script:
%   1) Reads raw airfoil coordinates
%   2) Normalizes them to unit chord
%   3) Fits a CST representation via constrained optimization
%   4) Compares CST reconstruction with original airfoil geometry

clc
clear

%% ------------------------------------------------------------------------
% Initialize folders
% -------------------------------------------------------------------------
folders = "Airfoil fitting";

for i = 1:numel(folders)
    addpath(genpath(folders{i}));
    fprintf("Folder added to path: %s\n", folders{i});
end

%% ------------------------------------------------------------------------
% Read airfoil coordinate file
% -------------------------------------------------------------------------
inputFile = 'A330Airfoil.dat';

fid = fopen(inputFile, 'r');
assert(fid ~= -1, "Could not open file: %s", inputFile);

% Read coordinates: [x y]
Coor = fscanf(fid, '%g %g', [2 Inf])';
fclose(fid);

% Transpose for convenience (2 x N)
Coor = Coor';

%% ------------------------------------------------------------------------
% Normalize airfoil coordinates to unit chord
% -------------------------------------------------------------------------
% Shift x so leading edge is at x = 0
xMin = min(Coor(1,:));
Coor(1,:) = Coor(1,:) - xMin;

% Normalize chord length to 1
xMax = max(Coor(1,:));
Coor = Coor ./ xMax;

fprintf("Airfoil normalized: x in [%.2f, %.2f]\n", ...
        min(Coor(1,:)), max(Coor(1,:)));

%% ------------------------------------------------------------------------
% Save normalized airfoil coordinates
% -------------------------------------------------------------------------
outputFile = 'A330Airfoil_normalized.dat';

fid_out = fopen(outputFile, 'w');
assert(fid_out ~= -1, "Could not write file: %s", outputFile);

fprintf(fid_out, '%g %g\n', Coor);
fclose(fid_out);

fprintf("Normalized airfoil saved as: %s\n", outputFile);

%% ------------------------------------------------------------------------
% CST airfoil fitting setup
% -------------------------------------------------------------------------
% Number of CST coefficients (upper + lower surface)
M = 10;                     % must be even

% Initial guess
x0 = ones(M,1);

% Bounds on CST coefficients
lb = -1 * ones(M,1);
ub =  1 * ones(M,1);

% Optimization options
options = optimset('Display','iter');

%% ------------------------------------------------------------------------
% Run CST optimization
% -------------------------------------------------------------------------
% Evaluate initial error
initialError = CST_objective(x0);

fprintf("Initial CST error: %.4e\n", initialError);

% Run constrained optimization
tic
[xOpt, fval, exitflag] = fmincon( ...
    @CST_objective, x0, ...
    [], [], [], [], ...
    lb, ub, [], options);
optTime = toc;

fprintf("Optimization completed in %.2f s\n", optTime);

%% ------------------------------------------------------------------------
% Reconstruct airfoil from optimized CST coefficients
% -------------------------------------------------------------------------
M_half = M / 2;

% Chordwise evaluation points
X_vect = linspace(0, 1, 99)';

% Split upper and lower CST coefficients
Aupp_vect = xOpt(1:M_half);
Alow_vect = xOpt(M_half+1:end);

% Generate CST airfoil
[Xtu, Xtl, C, Thu, Thl, Cm] = ...
    D_airfoil2(Aupp_vect, Alow_vect, X_vect);

%% ------------------------------------------------------------------------
% Visualization
% -------------------------------------------------------------------------
figure; hold on; box on

% CST airfoil
plot(Xtu(:,1), Xtu(:,2), 'b', 'LineWidth', 1.2)
plot(Xtl(:,1), Xtl(:,2), 'b', 'LineWidth', 1.2)

% Original airfoil coordinates
plot(Coor(1,:), Coor(2,:), 'rx')

axis equal
axis([0 1 -0.5 0.5])
pbaspect([1 1 1])
grid on

xlabel('$x/c$', 'Interpreter','latex')
ylabel('$y/c$', 'Interpreter','latex')
legend({'CST upper','CST lower','Original airfoil'}, ...
       'Location','best')

hold off
