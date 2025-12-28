function AC = get_Geometry_new(AC,x)
%% Assaign Values DELETE
y = AC.Wing.y; 
c = AC.Wing.c;
taper = AC.Wing.Taper;  
LE = AC.Wing.sweepLE;
TE = AC.Wing.sweepTE;

%% Assign Values
AC.Wing.c(1) = x(1);
AC.Wing.sweepLE = x(2);
AC.Wing.Taper(2) = x(3);
AC.Wing.y(3) = AC.Wing.y(2) + x(4);

AC.Wing.Airfoil.CST_up = [x(8) , x(9), x(10) , x(11) , x(12)];
AC.Wing.Airfoil.CST_low = [x(13) , x(14), x(15) , x(16) , x(17)];


%% Calulate Values
AC.Wing.y(1) = 0; % origin definition
% AC.Wing.y(2) stays constant throughout the optimization.
AC.Wing.y(3) = AC.Wing.y(2) + x(4); 

AC.Wing.x(1) = 0;
AC.Wing.x(2) = y(2) * tan( x(2) );
AC.Wing.x(3) = y(3) * tan( x(2) );

c_k = AC.Wing.c(1) + (AC.Wing.x(1) - AC.Wing.x(2)) + (AC.Wing.y(2) - AC.Wing.y(1))* tan(AC.Wing.sweepTE(1));
c_t = AC.Wing.Taper(2) * c_k;
AC.Wing.c =[x(1) , c_k , c_t ];

taper(1) = c(2)/c(1); 
AC.Wing.Taper(1)=taper(1);
taper(2) = AC.Wing.Taper(2);

for i = 1:2 % Reference Area using the trapeziod Formula
     S_st(i)   = 1/2 * (c(i) + c(i+1)) * (y(i+1) - y(i));   % reference Surface single taper section
     MAC_st(i) = 2/3 * c(i) * (1 + taper(i) + taper(i)^2) / (1 + taper(i)); % mean aerodynamic chord single taper section
end

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

end


