function AC = Performance(AC,REF)
AC.Mission.dp.q = 0.5 * AC.Mission.dp.rho * AC.Mission.dp.V^2;
AC.Mission.CD_woWing = AC.Mission.CD_woWing *(AC.Mission.dp.q / REF.Mission.dp.q); %Scaling body drag with dynamic pressure
AC.Mission.CD = AC.Mission.CD_woWing + AC.Res.vis.CDwing; % Get CD for whole plane. Contribution from wingless part(unchanging) + wing ( result from Q3D viscous)

AC.L_over_D_aircraft= AC.Res.vis.CLwing/AC.Mission.CD; % update L/D

AC.Performance.eta = exp( -((AC.Mission.dp.V - REF.Mission.dp.V).^2 / (2 * 70^2)) - ((AC.Mission.dp.alt - REF.Mission.dp.alt).^2 / (2 * 2500^2)) );
AC.Performance.CT = AC.Performance.CTbar / AC.Performance.eta;
AC.Performance.R = (AC.Mission.dp.V / AC.Performance.CT ) * (AC.L_over_D_aircraft) * log(AC.W.MTOW/AC.W.ZFW);

end