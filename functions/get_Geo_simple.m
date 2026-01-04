function AC = get_Geo_simple(AC, x_struct)

%% Assign Values
if isfield(x_struct, 'root_chord')
    AC.Wing.c(1) = x_struct.root_chord;

end

if isfield(x_struct, 'leadingEdgeSweep')
    AC.Wing.sweepLE = x_struct.leadingEdgeSweep;
end

if isfield(x_struct, 'TaperRatio_Tip_To_Kink')
    AC.Wing.Taper(2) = x_struct.TaperRatio_Tip_To_Kink;
end

if isfield(x_struct, 'span_Tip_To_Kink')
AC.Wing.y(3) = AC.Wing.y(2) + x_struct.span_Tip_To_Kink; %define the y position of the leading edge wing Tip
end

%assign upper CST coefficients
if isfield(x_struct, 'CST_up')
AC.Wing.Airfoil.CST_up = x_struct.CST_up;
end

%assign lower CST coefficients
if isfield(x_struct, 'CST_low')
AC.Wing.Airfoil.CST_low = x_struct.CST_low;
end

AC.Wing.x(2) = AC.Wing.y(2) * tan(AC.Wing.sweepLE); %define x position Of Leading edge at the kink.

AC.Wing.x(3) = AC.Wing.y(3) * tan(AC.Wing.sweepLE); %define x position of Leading edge of wingtip.

x_TE(1)= AC.Wing.c(1); %define the x position of the trailing edge at the root.

x_TE(2)= x_TE(1) + AC.Wing.y(2) * tan( AC.Wing.sweepTE(1) ); %define the x position at the trailing edge at the kink.

AC.Wing.c(2) = x_TE(2) - AC.Wing.x(2); %define the kink chord

AC.Wing.c(3) = AC.Wing.c(2)*AC.Wing.Taper(2);

%TODO: CHECK AFTER THIS POINT

taper(1) = AC.Wing.c(2)/AC.Wing.c(1); 
AC.Wing.Taper(1)=taper(1);
taper(2) = AC.Wing.Taper(2);

c=AC.Wing.c;
y=AC.Wing.y;
for i = 1:2 % Reference Area using the trapeziod Formula
     S_st(i)   = 1/2 * (c(i) + c(i+1)) * (y(i+1) - y(i));   % reference Surface single taper section
     MAC_st(i) = 2/3 * c(i) * (1 + taper(i) + taper(i)^2) / (1 + taper(i)); % mean aerodynamic chord single taper section
end

AC.Wing.span = 2 * AC.Wing.y(3);
AC.Wing.Sref  = 2*sum(S_st);
AC.Wing.MAC = sum(MAC_st.*S_st) / sum(S_st);
AC.Wing.AR  = AC.Wing.span^2 / AC.Wing.Sref;
%                x                  y                   z                   chord(m)            twist angle (deg) 
AC.Wing.Geom = [AC.Wing.x(1)      AC.Wing.y(1)       AC.Wing.z(1)       AC.Wing.c(1)       AC.Wing.twist(1) ;   
                 AC.Wing.x(2)      AC.Wing.y(2)       AC.Wing.z(2)       AC.Wing.c(2)       AC.Wing.twist(2) ;
                 AC.Wing.x(3)      AC.Wing.y(3)       AC.Wing.z(3)       AC.Wing.c(3)       AC.Wing.twist(3) ];

% Airfoil
%                    |-> upper curve coeff. <-||-> lower curve coeff. <-| 
AC.Wing.Airfoils   = [AC.Wing.Airfoil.CST_up, AC.Wing.Airfoil.CST_low;
                       AC.Wing.Airfoil.CST_up, AC.Wing.Airfoil.CST_low];

% Spar at root position     TODO ------------------
f = AC.Struct.spar_front(3);  % 0.20 = front spar, 0.80 = rear spar
xS2 = AC.Wing.x(2) + f * c(2);
xS3 = AC.Wing.x(3) + f * c(3);
m_spar = (xS3 - xS2) / (y(3) - y(2));
xS1 = xS2 + m_spar * (y(1) - y(2));
AC.Struct.spar_front(1) =  (xS1 - AC.Wing.x(1)) / c(1);

f = AC.Struct.spar_rear(3);  % 0.20 = front spar, 0.80 = rear spar
xS2 = AC.Wing.x(2) + f * c(2);
xS3 = AC.Wing.x(3) + f * c(3);
m_spar = (xS3 - xS2) / (y(3) - y(2));
xS1 = xS2 + m_spar * (y(1) - y(2));
AC.Struct.spar_rear(1) =  (xS1 - AC.Wing.x(1)) / c(1);


% Weights TODO
%AC.W.fuel = x(7)*AC.fueltankData.FuelDensity;        % fuel weight for max range at design payload 

% Update normal Flight Condition
if isfield(x_struct, 'altitude')
AC.Mission.dp.alt   = x_struct.altitude; % flight altitude (m)
end

if isfield(x_struct, 'Mach')
AC.Mission.dp.M     = x_struct.Mach;   % Mach Number (m)
end 

[~, ~, AC.Mission.dp.rho, AC.Mission.dp.a, AC.Mission.dp.mu] = get_ISA(AC.Mission.dp.alt);
AC.Mission.dp.V = AC.Mission.dp.M * AC.Mission.dp.a; % flight Mach number
AC.Mission.dp.Re = AC.Mission.dp.rho * AC.Mission.dp.V * AC.Wing.MAC / AC.Mission.dp.mu; % reynolds number (bqased on mean aerodynamic chord)
AC.Mission.dp.q  = 0.5 * AC.Mission.dp.rho * AC.Mission.dp.V^2;

end