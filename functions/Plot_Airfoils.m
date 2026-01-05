function Plot_Airfoils(x,x0)

%Reference aircraft
Au_ref = x0.CST_up;         %upper-surface Bernstein coefficients 
Al_ref = x0.CST_low;    %lower surface Bernstein coefficients

%Optimized aircraft
Au_opt = x.CST_up;        
Al_opt = x.CST_low;

X = linspace(0,1,99)';      %points for evaluation along x-axis

[Xtu_ref,Xtl_ref,C_ref] = D_airfoil2(Au_ref,Al_ref,X);
[Xtu_opt,Xtl_opt,C_opt] = D_airfoil2(Au_opt,Al_opt,X);

hold on
%REF airfoil
plot(Xtu_ref(:,1),Xtu_ref(:,2),'b');    %plot upper surface coords
plot(Xtl_ref(:,1),Xtl_ref(:,2),'b');    %plot lower surface coords

%Optimized design

plot(Xtu_opt(:,1),Xtu_opt(:,2),'r');    %plot upper surface coords
plot(Xtl_opt(:,1),Xtl_opt(:,2),'r');    %plot lower surface coords

           
ylim([-0.2,0.2]);
xlim([0,1]);
