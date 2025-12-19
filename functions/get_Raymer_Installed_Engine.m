function [W_ec, W_nacelle_group] = get_Raymer_Installed_Engine( ...
        W_engine, K_tr, K_ng, K_p, ...
        N_lt, N_w, N_z, N_en, S_n)

% -------------------------------------------------------------------------
% nacelle_weight.m
%
% Computes:
%   1) W_ec  – Weight of engine + contents (per nacelle), lb
%   2) W_nacelle_group – Total nacelle group weight, lb
%
% Formulas are from Raymer - Aircraft Design: A Conceptual Approach
%
% INPUTS:
%   W_engine   – Engine weight (each), lb
%   K_tr       – Thrust reverser factor (1.18 for jet w/ reverser, else 1.0)
%   K_ng       – Nacelle installation factor (1.017 pylon-mounted, else 1.0)
%   K_p        – Propeller factor (1.4 with propeller, else 1.0)
%   N_lt       – Nacelle length, ft
%   N_w        – Nacelle width, ft
%   N_z        – Ultimate load factor (= 1.5 × limit load factor)
%   N_en       – Number of engines (total for aircraft)
%   S_n        – Nacelle wetted area, ft² (or appropriate nacelle area term)
%
% OUTPUTS:
%   W_ec             – Engine + contents weight per nacelle (lb)
%   W_nacelle_group  – Total nacelle group weight (lb)
%
% -------------------------------------------------------------------------

%% --- Engine + contents weight (per nacelle) ---
% W_ec ≅ 2.331 * W_engine^0.901 * K_p * K_tr
W_ec = 2.331 * (W_engine^0.901) * K_p * K_tr;


%% --- Nacelle group total weight ---
% W_nacelle_group = 0.6724 * K_ng * N_lt^0.10 * N_w^0.294 * N_z^0.119 ...
%                    * W_ec^0.611 * N_en^0.984 * S_n^0.224

W_nacelle_group = 0.6724 * ...
                  K_ng * ...
                  (N_lt^0.10) * ...
                  (N_w^0.294) * ...
                  (N_z^0.119) * ...
                  (W_ec^0.611) * ...
                  (N_en^0.984) * ...
                  (S_n^0.224);

end
