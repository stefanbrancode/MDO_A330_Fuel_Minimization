function [Cie, Ceq] = Constraints(x)
V_fuel = W.fuel / rho_fuel; 
Cie(1) = V_fuel - (V_tank*0.93); 
Cie(2) = W.MTO/S_ref - Ref.W.MTO/Ref.S_ref;
Ceq = [];
end