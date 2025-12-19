function [W, counter] = MDA(x, error)
% MDA coordinator (convergence loop) 
% once the convergence is within the specified tolerance (optional)

%Convergence loop
if nargin < 2
    error = 1e-6;
end

%for initiation of loop condition:
W.MTO = 0;
W.MTOhat = Ref.W.MTO; 
counter = 0;

while abs( (W.MTO-W.MTOhat)/W.MTO ) > error
    Aero = get_Aero(Geo, W.MTO, n=n_max, Mission, Solver); % Aerodynamic Loads
    W.Wing = ; % Wing struture
    W = get_Weight(x, W);
    counter = counter +1;    
end
end
