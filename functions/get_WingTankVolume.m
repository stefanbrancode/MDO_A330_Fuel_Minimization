function AC = get_WingTankVolume(AC)
% Computes wing volume from root to 85% of half-span using CST airfoil
y = AC.Wing.y;

y_new(1) = y(1) * AC.Fuel_Tank.eta(1);
y_new(3) = y(2);
y_new(2) = (y_new(1) + y_new(3)) / 2;
y_new(5) = y(3) *AC.Fuel_Tank.eta(2);
y_new(4) = (y_new(3) + y_new(5)) / 2;

h(1) = y_new(3) - y_new(1);
h(2) = y_new(5) - y_new(3);

X = linspace(0, 1, 100)';      % points for evaluation along x-axis

c = zeros(length(y_new), 1);
for i = 1:(length(y_new))
    % chord
    if y_new(i) <= AC.Wing.y(2)
        c(i) = AC.Wing.c(1) + y_new(i) .* (tan(AC.Wing.sweepTE(1))-tan(AC.Wing.sweepLE));
    else
        c(i) = AC.Wing.c(2) + (y_new(i) -AC.Wing.y(2)) .* (tan(AC.Wing.sweepTE(2))-tan(AC.Wing.sweepLE));
    end
    
    [Xtu, Xtl, ~, ~, ~, ~] = D_airfoil2(AC.Wing.Airfoil.CST_up, AC.Wing.Airfoil.CST_low, X);
end

% front Spar positions
xS3 = AC.Wing.x(2) + AC.Struct.spar_front(2) * AC.Wing.c(2);
xS6 = AC.Wing.x(3) + AC.Struct.spar_front(3) * AC.Wing.c(3);
m_spar = (xS6 - xS3) / (y(3) - y(2));
xS1 = xS3 + m_spar * (y_new(1) - y_new(3));
xS2 = xS3 + m_spar * (y_new(2) - y_new(3));

spar_front(1) =  xS1 / c(1);
spar_front(2) =  (xS2 - y_new(2) * tan(AC.Wing.sweepLE)) / c(2);
spar_front(3) =  AC.Struct.spar_front(2);
spar_front(4) =  AC.Struct.spar_front(2);
spar_front(5) =  AC.Struct.spar_front(3);

% rear Spar positions
xS3 = AC.Wing.x(2) + AC.Struct.spar_rear(2) * AC.Wing.c(2);
xS6 = AC.Wing.x(3) + AC.Struct.spar_rear(3) * AC.Wing.c(3);
m_spar = (xS6 - xS3) / (y(3) - y(2));
xS1 = xS3 + m_spar * (y_new(1) - y_new(3));
xS2 = xS3 + m_spar * (y_new(2) - y_new(3));

spar_rear(1) =  xS1 / c(1);
spar_rear(2) =  (xS2 - y_new(2) * tan(AC.Wing.sweepLE)) / c(2);
spar_rear(3) =  AC.Struct.spar_rear(2);
spar_rear(4) =  AC.Struct.spar_rear(2);
spar_rear(5) =  AC.Struct.spar_rear(3);

for i = 1:(length(y_new))
    % Area
    x_common = linspace(spar_front(i), spar_rear(i), 500)';

    yu = interp1(Xtu(:,1), Xtu(:,2), x_common, 'pchip');
    yl = interp1(Xtl(:,1), Xtl(:,2), x_common, 'pchip');
    thickness = yu - yl;
    
    A_norm = trapz(x_common, thickness);
    A(i) = A_norm * c(i)^2;
end

V(1) = h(1) / 6 * (A(1)+ 4 * A(3) + A(3));
V(2) = h(2) / 6 * (A(3)+ 4 * A(4) + A(5));

AC.Fuel_Tank.VolumeTank = 2 * AC.Fuel_Tank.K * sum(V);
end
