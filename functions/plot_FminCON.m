function plot_FminCON()

load iterations_log.mat

plot(logData.iteration, logData.fval)
xlabel('Iteration'), ylabel('Objective')
grid on

end