function [MOD, eta] = get_Performance(MOD, REF)
eta = exp( - (MOD.V-REF.V)^2/(2*70^2) - (MOD.alt-REF.alt)^2/(2*2500^2)); 
MOD.Mission.C_T = REF.C_T / eta; 
MOD.Mission.R = MOD.Mission.v_dp/MOD.C_T* MOD.Aero.L_D*log(MOD.W.cruisefrac); 
end