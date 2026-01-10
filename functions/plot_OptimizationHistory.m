function plot_OptimizationHistory(filename, Resolution)
%% Plot objective and constraint history vs iterations

if nargin == 0
    filename = 'Results/iterations_log.mat';
end

S = load(filename);
logData = S.logData;

iter = logData.iteration;



% =====================================================
% Objective function
% =====================================================
fig = figure('Name','Objective History','Color','w'); hold on;
plot(iter, logData.fval, '-o','LineWidth',1.5)
yline(-1,'k--')
grid on
xlabel('Iteration')
ylabel('normalized Objective value')
% title('Objective function convergence')
ylim([min(logData.fval)*1.01, -0.99])

cd 'Figures'
exportgraphics(fig, 'History_objective.png', 'Resolution', Resolution);
cd '..'

% =====================================================
% Constraint violation
% =====================================================
fig = figure('Name','Constraint History','Color','w'); hold on;
cMat = cell2mat(logData.c.');
for i = 1:size(cMat,2)
    plot(iter, cMat(:,i),'-o', 'LineWidth', 1.5)
end
yline(0,'k--')
grid on
xlabel('Iteration')
ylabel('normalized Constraint value')
% title('Individual inequality constraints')
legend("c_1: Fuel Volume","c_2: Wing Loading", "Constraint violation",'Location','best')

ylim([min(min(cMat))*1.1, 0.10])

cd 'Figures'
exportgraphics(fig, 'History_constraints.png', 'Resolution', Resolution);
cd '..'

end