function Mission = get_Misssion(Mission, MAC)
% Inputs:
% Mission.alt;   
% Mission.M;  
% MAC
[~, ~, Mission.rho, Mission.a, Mission.mu] = get_ISA(Mission.alt); % Atmosphere 
Mission.V = Mission.M * Mission.a;                              % flight Mach number
Mission.Re = Mission.rho * Mission.V * MAC / Mission.mu;        % reynolds number (bqased on mean aerodynamic chord)
end