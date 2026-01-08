function plot_OptimizationHistory(filename)
%% Plot objective and constraint history vs iterations

if nargin == 0
    filename = 'Results/iterations_log.mat';
end

S = load(filename);
logData = S.logData;

iter = logData.iteration;

figure('Name','Optimization History','Color','w');

% =====================================================
% Objective function
% =====================================================
subplot(2,1,1)
plot(iter, logData.fval, '-o','LineWidth',1.5)
grid on
xlabel('Iteration')
ylabel('Objective value')
% title('Objective function convergence')

% =====================================================
% Constraint violation
% =====================================================
subplot(2,1,2); hold on;
cMat = cell2mat(logData.c.');
for i = 1:size(cMat,2)
    plot(iter, cMat(:,i),'LineWidth',1.2)
end
yline(0,'k--')
grid on
xlabel('Iteration')
ylabel('Constraint value')
% title('Individual inequality constraints')
legend("c_"+string(1:size(cMat,2)),'Location','best')

end