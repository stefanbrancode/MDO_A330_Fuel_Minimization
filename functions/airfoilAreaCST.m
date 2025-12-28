function A = airfoilAreaCST(Au, Al, N1, N2, c, Nx)
% AIRFOILAREACST
% Computes airfoil area at a given chord using CST

xi = linspace(0, 1, Nx);

zu = CSTsurface(xi, Au, N1, N2);
zl = CSTsurface(xi, Al, N1, N2);

thickness = zu - zl;

% Area scales with c^2
A = trapz(xi, thickness) * c^2;

end
