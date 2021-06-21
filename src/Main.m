% Filename:      Main.m
%
% Description:   Runs a program that simulates the dynamics of a CubeSat
%                in low Earth orbit while detumbling using a 3-axis
%                magnetorquer set, a magnetometer, and a gyroscope. The
%                B-dot control algorithm is used along with some low pass
%                filters to attenuate high frequency sensor noise.
%
% Author(s):     Edwin Christhuraj
% Created:       23-Apr-2021
%
% Copyright (c) 2021 Edwin Christhuraj.
% See LICENSE for terms.

clear;

%% Main Parameters
PhysclCnstnts;

%Magnetorquer Parameters
bDotCntrllrGain_xMgntrqr = 10000; %[unitless] *Range: bDotCntrllrGain_xMgntrqr ≥ 0.0*
bDotCntrllrGain_yMgntrqr = 10000; %[unitless] *Range: bDotCntrllrGain_yMgntrqr ≥ 0.0*
bDotCntrllrGain_zMgntrqr = 10000; %[unitless] *Range: bDotCntrllrGain_zMgntrqr ≥ 0.0*
numCoils_xMgntrqr = 12000; %[unitless] *Range: numCoils_xMgntrqr > 0.0*
numCoils_yMgntrqr = 12000; %[unitless] *Range: numCoils_yMgntrqr > 0.0*
numCoils_zMgntrqr = 320; %[unitless] *Range: numCoils_zMgntrqr > 0.0*
sctnArea_xMgntrqr = 2.2698E-4; %[m^2] *Range: sctnArea_xMgntrqr > 0.0*
sctnArea_yMgntrqr = 2.2698E-4; %[m^2] *Range: sctnArea_yMgntrqr > 0.0*
sctnArea_zMgntrqr = 8.7695E-3; %[m^2] *Range: sctnArea_zMgntrqr > 0.0*
maxCrrnt_xMgntrqr = 0.2143; %[A] *Range: maxCrrnt_xMgntrqr > 0.0*
maxCrrnt_yMgntrqr = 0.2143; %[A] *Range: maxCrrnt_yMgntrqr > 0.0*
maxCrrnt_zMgntrqr = 0.2135; %[A] *Range: maxCrrnt_zMgntrqr > 0.0*

%Magnetometer Parameters
lpFltrGain_mgntmtr = 0.4; %[unitless] *Range: 0.0 ≤ lpFltrGain_mgntmtr ≤ 1.0*
sampRte_mgntmtr = 2; %[Hz] *Range: sampRte_mgntmtr > 0*
cnstntBiasVctr_mgntmtr = [0; 0; 0]; %[T] *Range: cnstntBiasVctr_mgntmtr ≥ [0.0; 0.0; 0.0]*
maxNoiseAmpltde_mgntmtr = 1E-6; %[T] *Range: maxNoiseAmpltde_mgntmtr ≥ 0.0*

%Gyroscope Parameters
lpFltrGain_gyro = 0.45; %[unitless] *Range: 0.0 ≤ lpFltrGain_gyro ≤ 1.0*
sampRte_gyro = 50; %[Hz] *Range: sampRte_gyro > 0*
cnstntBiasVctr_gyro = [0; 0; 0]; %[deg/s] *Range: cnstntBiasVctr_gyro ≥ [0.0; 0.0; 0.0]*
maxNoiseAmpltde_gyro = 0.25; %[deg/s] *Range: maxNoiseAmpltde_gyro ≥ 0.0*

%Spacecraft Parameters
mass_spcrft = 2.6; %[kg] *Range: mass_spcrft > 0.0*
dimnsnsX_spcrft = 0.1; %[m] *Range: dimnsnsX_spcrft > 0.0*
dimnsnsY_spcrft = 0.1; %[m] *Range: dimnsnsY_spcrft > 0.0*
dimnsnsZ_spcrft = 0.2; %[m] *Range: dimnsnsZ_spcrft > 0.0*
inrtaTnsr_spcrft = [0.0108, 0,      0;
                    0,      0.0108, 0;
                    0,      0,      0.0043]; %[kg-m^2] *Range: inrtaTnsr_spcrft > [0.0, 0.0, 0.0;
                                             %                                     0.0, 0.0, 0.0;
                                             %                                     0.0, 0.0, 0.0]*
initYawAngl_spcrft = 0; %[deg] *Range: 0.0 ≤ initYawAngl_spcrft < 360.0*
initPtchAngl_spcrft = 0; %[deg] *Range: 0.0 ≤ initPtchAngl_spcrft < 360.0*
initRollAngl_spcrft = 0; %[deg] *Range: 0.0 ≤ initRollAngl_spcrft < 360.0*
initBdyAnglrRteX_spcrft = 0.5; %[deg/s] *Range: initBdyAnglrRteX_spcrft ≥ 0.0*
initBdyAnglrRteY_spcrft = 1; %[deg/s] *Range: initBdyAnglrRteY_spcrft ≥ 0.0*
initBdyAnglrRteZ_spcrft = 2; %[deg/s] *Range: initBdyAnglrRteZ_spcrft ≥ 0.0*
dsirdBdyAnglrRteX_spcrft = 0; %[deg/s] *Range: dsirdBdyAnglrRteX_spcrft ≥ 0.0*
dsirdBdyAnglrRteY_spcrft = 0; %[deg/s] *Range: dsirdBdyAnglrRteY_spcrft ≥ 0.0*
dsirdBdyAnglrRteZ_spcrft = 0; %[deg/s] *Range: dsirdBdyAnglrRteZ_spcrft ≥ 0.0*

%Orbit Parameters
alt_orbt = 6E5; %[m] *Range: 2.0E6 < alt_orb < 8.5E6*
inc_orbt = 97.787; %[deg] *Range: 0.0 ≤ inc_orb ≤ 180.0*
aop_orbt = 144.8873; %[deg] *Range: 0.0 ≤ aop_orb < 360.0*
raan_orbt = 59.4276; %[deg] *Range: 0.0 ≤ raan_orb < 360.0*
numOrbts = 1; %[unitless] *Range: numOrbs > 0.0*

%Simulator UI Parameters
scrnScleFctr_simUI = 0.75; %[unitless] *Range: 0.0 < scrnScleFctr_simUI ≤ 1.0*
frmeRte_simUI = 10; %[fps] *Range: frmeRte_simUI < 15*
simSpdMltplr = 50; %[unitless] *Range: simSpdMltplr > 0.0*
simCalcltnMdfier = 'Pre-Calculate'; %[unitless] *Range: simCalcltnMdfier = 'Real-Time' or 'Pre-Calculate'*
viewAzmth = 135; %[deg] *Range: 0.0 ≤ viewAzmth < 360.0*
viewElvtn = 22.5; %[deg] *Range: 0.0 ≤ viewElvtn < 360.0*

%% Main Setup
%Simulator UI Setup
simUI = figure('Name', 'CubeSat Detumbling Simulator', 'Position', [(1 - scrnScleFctr_simUI) * COMP_SCRN_SIZE(3) / 2, (1 - scrnScleFctr_simUI) * COMP_SCRN_SIZE(4) / 2, scrnScleFctr_simUI * COMP_SCRN_SIZE(3), scrnScleFctr_simUI * COMP_SCRN_SIZE(4)], 'Color', 'k');
switch simCalcltnMdfier
    case 'Real-Time'
        set(simUI, 'Visible', 'on');
    case 'Pre-Calculate'
        set(simUI, 'Visible', 'off');
    otherwise
        set(simUI, 'Visible', 'off');
        error('The value assigned to simCalcltnMdfier may be spelled incorrectly.');
end
panel_simStatus = uipanel('Parent', simUI);
set(panel_simStatus, 'Position', [0.5, 0.75, 0.5, 0.25], 'BackgroundColor', 'k');
axes_simStatus = axes('Parent', panel_simStatus);
set(axes_simStatus, 'Visible', 'on', 'Color', 'k', 'xcolor', 'k', 'ycolor', 'k');
hold(axes_simStatus, 'on');
axis([0, 1, -5, 5]);
title("Simulation Progress", "Time Remaining: ", 'Color', 'w');
plot([0, 1, 1, 0, 0], [-0.5, -0.5, 0.5, 0.5, -0.5], 'Color', 'r');
statusBar = barh(0, 0, 0.9, 'FaceColor', 'g');
pausePlayBttn_simUI = uicontrol('Parent', panel_simStatus, 'Style', 'togglebutton', 'String', '⏸', 'Position', [(15 / 64) * simUI.Position(3), 0, (1 / 32) * simUI.Position(3), (1 / 32) * simUI.Position(3)], 'ForegroundColor', 'g', 'BackgroundColor', 'b', 'Callback', 'uiresume');
hold(axes_simStatus, 'off');

%Orbit Plot Setup
semiMajr_orbt = R_EQTR_ERTH + alt_orbt;
period_orbt = 2 * pi * sqrt(semiMajr_orbt^3 / MU_ERTH);
draan_dt = rad2deg((-3 / 2) * cosd(inc_orbt) * J2_ERTH * R_EQTR_ERTH^2 * sqrt(MU_ERTH) / semiMajr_orbt^(7 / 2));
daop_dt = rad2deg((-3 / 2) * ((-5 / 2) * sind(inc_orbt)^2 - 2) * J2_ERTH * R_EQTR_ERTH^2 * sqrt(MU_ERTH) / semiMajr_orbt^(7 / 2));
prfclPostn_spcrft = [semiMajr_orbt; 0; 0];
rotMatrx_orbt = rotMatrx313BdyToInrtl(raan_orbt, inc_orbt, aop_orbt);
inrtlPostn_spcrft = rotMatrx_orbt * prfclPostn_spcrft;
ltitde_orbt = geoc2geod(asind(inrtlPostn_spcrft(3, 1) / semiMajr_orbt), semiMajr_orbt);
lngtde_orbt = atan2d(inrtlPostn_spcrft(2, 1), inrtlPostn_spcrft(1, 1));
inrtlMgntcFld = 1E-9 * rotMatrx321BdyToInrtl(lngtde_orbt, 270 - ltitde_orbt, 0) * wrldmagm(alt_orbt, ltitde_orbt, lngtde_orbt, decyear(2020, 1, 1));
panel_erthPlt = uipanel('Parent', simUI);
set(panel_erthPlt, 'Position', [0, 0.67, 0.5, 0.33], 'BackgroundColor', 'k');
axes_erthPlt = axes('Parent', panel_erthPlt);
set(axes_erthPlt, 'Visible', 'off');
view(axes_erthPlt, viewAzmth, viewElvtn);
axis(axes_erthPlt, 'vis3d');
hold(axes_erthPlt, 'on');
plot3([0, R_EQTR_ERTH + 8E5], [0, 0], [0, 0], 'Color', 'w', 'LineWidth', 2, 'Clipping', 'off');
plot3([0, 0], [0, R_EQTR_ERTH + 8E5], [0, 0], 'Color', 'w', 'LineWidth', 2, 'Clipping', 'off');
plot3([0, 0], [0, 0], [0, R_POLR_ERTH + 8E5], 'Color', 'w', 'LineWidth', 2, 'Clipping', 'off');
text(R_EQTR_ERTH + 2E6, 0, 0, 'X_I', 'Color', 'w');
text(0, R_EQTR_ERTH + 2E6, 0, 'Y_I', 'Color', 'w');
text(0, 0, R_POLR_ERTH + 2E6, 'Z_I', 'Color', 'w');
erthTrnsfrm = hgtransform;
set(erth(), 'Parent', erthTrnsfrm);
orbt = animatedline(inrtlPostn_spcrft(1, 1), inrtlPostn_spcrft(2, 1), inrtlPostn_spcrft(3, 1));
set(orbt, 'Color', 'y', 'LineWidth', 1, 'Clipping', 'off');
orbtCrrntPostn = scatter3(inrtlPostn_spcrft(1, 1), inrtlPostn_spcrft(2, 1), inrtlPostn_spcrft(3, 1), 5, 'g', 'filled');
zoom(1);
hold(axes_erthPlt, 'off');

%Spacecraft Plot Setup
dimnsns_spcrft(1) = dimnsnsX_spcrft;
dimnsns_spcrft(2) = dimnsnsY_spcrft;
dimnsns_spcrft(3) = dimnsnsZ_spcrft;
clear dimnsnsX_spcrft;
clear dimnsnsY_spcrft;
clear dimnsnsZ_spcrft;
truAnmly_spcrft = 0;
qtrnion_spcrft(1, 1) = cosd(initRollAngl_spcrft / 2) * cosd(initPtchAngl_spcrft / 2) * cosd(initYawAngl_spcrft / 2) + sind(initRollAngl_spcrft / 2) * sind(initPtchAngl_spcrft / 2) * sind(initYawAngl_spcrft / 2);
qtrnion_spcrft(2, 1) = sind(initRollAngl_spcrft / 2) * cosd(initPtchAngl_spcrft / 2) * cosd(initYawAngl_spcrft / 2) - cosd(initRollAngl_spcrft / 2) * sind(initPtchAngl_spcrft / 2) * sind(initYawAngl_spcrft / 2);
qtrnion_spcrft(3, 1) = cosd(initRollAngl_spcrft / 2) * sind(initPtchAngl_spcrft / 2) * cosd(initYawAngl_spcrft / 2) + sind(initRollAngl_spcrft / 2) * cosd(initPtchAngl_spcrft / 2) * sind(initYawAngl_spcrft / 2);
qtrnion_spcrft(4, 1) = cosd(initRollAngl_spcrft / 2) * cosd(initPtchAngl_spcrft / 2) * sind(initYawAngl_spcrft / 2) - sind(initRollAngl_spcrft / 2) * sind(initPtchAngl_spcrft / 2) * cosd(initYawAngl_spcrft / 2);
bdyAnglrRte_spcrft(1, 1) = deg2rad(initBdyAnglrRteX_spcrft);
bdyAnglrRte_spcrft(2, 1) = deg2rad(initBdyAnglrRteY_spcrft);
bdyAnglrRte_spcrft(3, 1) = deg2rad(initBdyAnglrRteZ_spcrft);
dsirdBdyAnglrRte_spcrft(1, 1) = deg2rad(dsirdBdyAnglrRteX_spcrft);
dsirdBdyAnglrRte_spcrft(2, 1) = deg2rad(dsirdBdyAnglrRteY_spcrft);
dsirdBdyAnglrRte_spcrft(3, 1) = deg2rad(dsirdBdyAnglrRteZ_spcrft);
clear dsirdBdyAnglrRteX_spcrft;
clear dsirdBdyAnglrRteY_spcrft;
clear dsirdBdyAnglrRteZ_spcrft;
dbdyAnglrRte_dt = inrtaTnsr_spcrft \ -cross(bdyAnglrRte_spcrft, inrtaTnsr_spcrft * bdyAnglrRte_spcrft);
dqtrnion_dt = [0, -bdyAnglrRte_spcrft(1), -bdyAnglrRte_spcrft(2), -bdyAnglrRte_spcrft(3); bdyAnglrRte_spcrft(1), 0, bdyAnglrRte_spcrft(3), -bdyAnglrRte_spcrft(2); bdyAnglrRte_spcrft(2), -bdyAnglrRte_spcrft(3), 0, bdyAnglrRte_spcrft(1); bdyAnglrRte_spcrft(3), bdyAnglrRte_spcrft(2), -bdyAnglrRte_spcrft(1), 0] * qtrnion_spcrft * 0.5;
bdyMgntcFld_spcrft = quatrotate(qtrnion_spcrft', inrtlMgntcFld')';
panel_spcrftPlt = uipanel('Parent', simUI);
set(panel_spcrftPlt, 'Position', [0, 0.33, 0.5, 0.34], 'BackgroundColor', 'k');
axes_spcrftPlt = axes('Parent', panel_spcrftPlt);
set(axes_spcrftPlt, 'Visible', 'off');
view(axes_spcrftPlt, viewAzmth, viewElvtn);
axis(axes_spcrftPlt, 'vis3d');
hold(axes_spcrftPlt, 'on');
plot3([0, max(dimnsns_spcrft / 2) + 0.05], [0, 0], [0, 0], 'Color', 'w', 'LineWidth', 2, 'Clipping', 'off');
plot3([0, 0], [0, max(dimnsns_spcrft / 2) + 0.05], [0, 0], 'Color', 'w', 'LineWidth', 2, 'Clipping', 'off');
plot3([0, 0], [0, 0], [0, max(dimnsns_spcrft / 2) + 0.05], 'Color', 'w', 'LineWidth', 2, 'Clipping', 'off');
text(max(dimnsns_spcrft / 2) + 0.1, 0, 0, 'X_I', 'Color', 'w');
text(0, max(dimnsns_spcrft / 2) + 0.1, 0, 'Y_I', 'Color', 'w');
text(0, 0, max(dimnsns_spcrft / 2) + 0.1, 'Z_I', 'Color', 'w');
spcrftTrnsfrm = hgtransform;
set(spcrft(dimnsns_spcrft, true), 'Parent', spcrftTrnsfrm);
if (norm(qtrnion_spcrft(2:4, 1)) ~= 0)
    spcrftTrnsfrm.Matrix = makehgtform('axisrotate', qtrnion_spcrft(2:4, 1), 2 * acos(qtrnion_spcrft(1, 1)));
end
zoom(0.5);
hold(axes_spcrftPlt, 'off');

%Ground Track Plot Setup
panel_grndTrckPlt = uipanel('Parent', simUI);
set(panel_grndTrckPlt, 'Position', [0, 0, 0.5, 0.33], 'BackgroundColor', 'w');
axes_grndTrckPlt = axes('Parent', panel_grndTrckPlt, 'XLim', [-180, 180], 'YLim', [-90, 90], 'XTick', -180:30:180, 'YTick', -90:30:90, 'Layer', 'top', 'GridColor', 'w');
hold(axes_grndTrckPlt, 'on');
image('CData', ERTH_SRFCE, 'XData', [-180, 180], 'YData', [90, -90]);
box(axes_grndTrckPlt, 'on');
grid(axes_grndTrckPlt, 'on');
title('Ground Track', 'Color', 'k');
xlabel('Longitude (deg)', 'Color', 'k');
ylabel('Latitude (deg)', 'Color', 'k');
grndTrckPlt = scatter(lngtde_orbt, ltitde_orbt, 1, 'r', 'filled');
grndTrckCrrntPostn = scatter(lngtde_orbt, ltitde_orbt, 5, 'g', 'filled');
hold(axes_grndTrckPlt, 'off');

%Gyroscope Plot Setup
cnstntBiasVctr_gyro = deg2rad(cnstntBiasVctr_gyro);
noiseVctr_gyro = randn(3, 1);
maxNoiseAmpltde_gyro = deg2rad(maxNoiseAmpltde_gyro);
noiseVctr_gyro = maxNoiseAmpltde_gyro * noiseVctr_gyro / norm(noiseVctr_gyro);
rawBdyAnglrRte_gyro = bdyAnglrRte_spcrft - cnstntBiasVctr_gyro + noiseVctr_gyro;
msurdBdyAnglrRte = rawBdyAnglrRte_gyro;
prevRawBdyAnglrRte_gyro = rawBdyAnglrRte_gyro;
panel_gyroPlt = uipanel('Parent', simUI);
set(panel_gyroPlt, 'Position', [0.5, 0, 0.5, 0.25], 'BackgroundColor', 'w');
axes_gyroPlt = axes('Parent', panel_gyroPlt);
hold(axes_gyroPlt, 'on');
title('Measured Body Frame Angular Rates of Spacecraft');
xlabel('Real Elapsed Time (s)');
ylabel('Angular Rates (deg/s)');
msurdBdyAnglrRte_pltX = animatedline(0, rad2deg(msurdBdyAnglrRte(1)), 'Color', 'r');
msurdBdyAnglrRte_pltY = animatedline(0, rad2deg(msurdBdyAnglrRte(2)), 'Color', 'g');
msurdBdyAnglrRte_pltZ = animatedline(0, rad2deg(msurdBdyAnglrRte(3)), 'Color', 'b');
legend('ω_B_x', 'ω_B_y', 'ω_B_z');
hold(axes_gyroPlt, 'off');

%Magnetometer Plot Setup
noiseVctr_mgntmtr = randn(3, 1);
noiseVctr_mgntmtr = maxNoiseAmpltde_mgntmtr * noiseVctr_mgntmtr / norm(noiseVctr_mgntmtr);
rawBdyMgntcFld_mgntmtr = bdyMgntcFld_spcrft - cnstntBiasVctr_mgntmtr + noiseVctr_mgntmtr;
msurdBdyMgntcFld = rawBdyMgntcFld_mgntmtr;
prevRawBdyMgntcFld_mgntmtr = rawBdyMgntcFld_mgntmtr;
panel_mgntmtrPlt = uipanel('Parent', simUI);
set(panel_mgntmtrPlt, 'Position', [0.5, 0.25, 0.5, 0.25], 'BackgroundColor', 'w');
axes_mgntmtrPlt = axes('Parent', panel_mgntmtrPlt);
hold(axes_mgntmtrPlt, 'on');
title('Measured Body Frame Magnetic Field of Earth');
xlabel('Real Elapsed Time (s)');
ylabel('Magnetic Field (T)');
msurdBdyMgntcFld_pltX = animatedline(0, msurdBdyMgntcFld(1), 'Color', 'r');
msurdBdyMgntcFld_pltY = animatedline(0, msurdBdyMgntcFld(2), 'Color', 'g');
msurdBdyMgntcFld_pltZ = animatedline(0, msurdBdyMgntcFld(3), 'Color', 'b');
legend('β_B_x', 'β_B_y', 'β_B_z');
hold(axes_mgntmtrPlt, 'off');

%Magnetorquer Plot Setup
bDotCntrllrGain_mgntrqrs(1, 1) = bDotCntrllrGain_xMgntrqr;
bDotCntrllrGain_mgntrqrs(2, 1) = bDotCntrllrGain_yMgntrqr;
bDotCntrllrGain_mgntrqrs(3, 1) = bDotCntrllrGain_zMgntrqr;
numCoils_mgntrqrs(1, 1) = numCoils_xMgntrqr;
numCoils_mgntrqrs(2, 1) = numCoils_yMgntrqr;
numCoils_mgntrqrs(3, 1) = numCoils_zMgntrqr;
clear numCoils_xMgntrqr;
clear numCoils_yMgntrqr;
clear numCoils_zMgntrqr;
sctnArea_mgntrqrs(1, 1) = sctnArea_xMgntrqr;
sctnArea_mgntrqrs(2, 1) = sctnArea_yMgntrqr;
sctnArea_mgntrqrs(3, 1) = sctnArea_zMgntrqr;
clear sctnArea_xMgntrqr;
clear sctnArea_yMgntrqr;
clear sctnArea_zMgntrqr;
crrnt_mgntrqrs = (-bDotCntrllrGain_mgntrqrs ./ (numCoils_mgntrqrs .* sctnArea_mgntrqrs)) .* cross(dsirdBdyAnglrRte_spcrft - msurdBdyAnglrRte, bdyMgntcFld_spcrft);
if (abs(crrnt_mgntrqrs(1)) > maxCrrnt_xMgntrqr)
    crrnt_mgntrqrs = crrnt_mgntrqrs * maxCrrnt_xMgntrqr / abs(crrnt_mgntrqrs(1));
end
if (abs(crrnt_mgntrqrs(2)) > maxCrrnt_yMgntrqr)
    crrnt_mgntrqrs = crrnt_mgntrqrs * maxCrrnt_yMgntrqr / abs(crrnt_mgntrqrs(2));
end
if (abs(crrnt_mgntrqrs(3)) > maxCrrnt_zMgntrqr)
    crrnt_mgntrqrs = crrnt_mgntrqrs * maxCrrnt_zMgntrqr / abs(crrnt_mgntrqrs(3));
end
appliedTrqe_mgntrqrs = (numCoils_mgntrqrs .* sctnArea_mgntrqrs) .* cross(crrnt_mgntrqrs, bdyMgntcFld_spcrft);
panel_mgntrqrPlt = uipanel('Parent', simUI);
set(panel_mgntrqrPlt, 'Position', [0.5, 0.5, 0.5, 0.25], 'BackgroundColor', 'w');
axes_mgntrqrPlt = axes('Parent', panel_mgntrqrPlt);
hold(axes_mgntrqrPlt, 'on');
title('Current to Magnetorquers');
xlabel('Real Elapsed Time (s)');
ylabel('Current (A)');
mgntrqrCrrnt_pltX = animatedline(0, crrnt_mgntrqrs(1), 'Color', 'r');
mgntrqrCrrnt_pltY = animatedline(0, crrnt_mgntrqrs(2), 'Color', 'g');
mgntrqrCrrnt_pltZ = animatedline(0, crrnt_mgntrqrs(3), 'Color', 'b');
legend('i_x', 'i_y', 'i_z');
hold(axes_mgntrqrPlt, 'off');

%% Main Simulation
pause(1);
t = 0;
tf = (period_orbt * numOrbts) / simSpdMltplr;
title(axes_simStatus, "Simulation Progress", "Time Remaining: " + round(tf, 0) + " seconds");
tPrev1 = 0;
tPrev2 = 0;
tPrev3 = 0;
tPause = 0;
tPauseTotl = 0;
t0 = clock;

switch simCalcltnMdfier
    case 'Real-Time'
        while (ishghandle(simUI) && t < tf)
            t = etime(clock, t0) - tPauseTotl;
            if (pausePlayBttn_simUI.Value == 1)
                pausePlayBttn_simUI.String = '▶';
                tPause = clock;
                uiwait;
                if (ishghandle(simUI))
                    tPauseTotl = tPauseTotl + etime(clock, tPause);
                    pausePlayBttn_simUI.String = '⏸';
                else
                    break;
                end
            end

            %Orbit, Spacecraft, and Ground Track Plots Update
            if (t - tPrev1 >= 1 / frmeRte_simUI)
                statusBar.YData = t / tf;
                title(axes_simStatus, "Simulation Progress", "Time Remaining: " + round(tf - t, 0) + " seconds");
                hold(axes_erthPlt, 'on');
                erthTrnsfrm.Matrix = makehgtform('axisrotate', [0, 0, 1], wrapTo360(deg2rad(OMEGA_ERTH) * t * simSpdMltplr));
                rotMatrx_orbt = rotMatrx313BdyToInrtl(wrapTo360(raan_orbt + draan_dt * t * simSpdMltplr), inc_orbt, wrapTo360(aop_orbt + daop_dt * t * simSpdMltplr));
                truAnmly_spcrft = wrapTo360((360 / period_orbt) * t * simSpdMltplr);
                prfclPostn_spcrft = [semiMajr_orbt * cosd(truAnmly_spcrft); semiMajr_orbt * sind(truAnmly_spcrft); 0];
                inrtlPostn_spcrft = rotMatrx_orbt * prfclPostn_spcrft;
                ltitde_orbt = geoc2geod(asind(inrtlPostn_spcrft(3, 1) / semiMajr_orbt), semiMajr_orbt);
                lngtde_orbt = wrapTo180(atan2d(inrtlPostn_spcrft(2, 1), inrtlPostn_spcrft(1, 1)) - wrapTo180(OMEGA_ERTH * t * simSpdMltplr));
                inrtlMgntcFld = 1E-9 * rotMatrx321BdyToInrtl(lngtde_orbt, 270 - ltitde_orbt, 0) * wrldmagm(alt_orbt, ltitde_orbt, lngtde_orbt, decyear(2020, 1, 1));
                addpoints(orbt, inrtlPostn_spcrft(1, 1), inrtlPostn_spcrft(2, 1), inrtlPostn_spcrft(3, 1));
                orbtCrrntPostn.XData = inrtlPostn_spcrft(1, 1);
                orbtCrrntPostn.YData = inrtlPostn_spcrft(2, 1);
                orbtCrrntPostn.ZData = inrtlPostn_spcrft(3, 1);
                hold(axes_erthPlt, 'off');
                hold(axes_spcrftPlt, 'on');
                qtrnion_spcrft = qtrnion_spcrft + (dqtrnion_dt / frmeRte_simUI) * simSpdMltplr;
                qtrnion_spcrft = qtrnion_spcrft / norm(qtrnion_spcrft);
                dqtrnion_dt = [0, -bdyAnglrRte_spcrft(1), -bdyAnglrRte_spcrft(2), -bdyAnglrRte_spcrft(3); bdyAnglrRte_spcrft(1), 0, bdyAnglrRte_spcrft(3), -bdyAnglrRte_spcrft(2); bdyAnglrRte_spcrft(2), -bdyAnglrRte_spcrft(3), 0, bdyAnglrRte_spcrft(1); bdyAnglrRte_spcrft(3), bdyAnglrRte_spcrft(2), -bdyAnglrRte_spcrft(1), 0] * qtrnion_spcrft * 0.5;
                bdyAnglrRte_spcrft = bdyAnglrRte_spcrft + (dbdyAnglrRte_dt / frmeRte_simUI) * simSpdMltplr;
                dbdyAnglrRte_dt = inrtaTnsr_spcrft \ (appliedTrqe_mgntrqrs - cross(bdyAnglrRte_spcrft, inrtaTnsr_spcrft * bdyAnglrRte_spcrft));
                bdyMgntcFld_spcrft = quatrotate(qtrnion_spcrft', inrtlMgntcFld')';
                if (norm(qtrnion_spcrft(2:4, 1)) ~= 0)
                    spcrftTrnsfrm.Matrix = makehgtform('axisrotate', qtrnion_spcrft(2:4, 1), 2 * acos(qtrnion_spcrft(1, 1)));
                end
                hold(axes_spcrftPlt, 'off');
                hold(axes_grndTrckPlt, 'on');
                grndTrckPlt.XData = [grndTrckPlt.XData, lngtde_orbt];
                grndTrckPlt.YData = [grndTrckPlt.YData, ltitde_orbt];
                grndTrckCrrntPostn.XData = lngtde_orbt;
                grndTrckCrrntPostn.YData = ltitde_orbt;
                hold(axes_grndTrckPlt, 'off');
                drawnow;
                tPrev1 = t;
            end

            %Magnetorquer and Gyroscope Plot Updates
            if (t - tPrev2 >= 1 / sampRte_gyro)
                hold(axes_gyroPlt, 'on');
                noiseVctr_gyro = randn(3, 1);
                noiseVctr_gyro = maxNoiseAmpltde_gyro * noiseVctr_gyro / norm(noiseVctr_gyro);
                rawBdyAnglrRte_gyro = bdyAnglrRte_spcrft - cnstntBiasVctr_gyro + noiseVctr_gyro;
                msurdBdyAnglrRte = (1 - lpFltrGain_gyro) * rawBdyAnglrRte_gyro + lpFltrGain_gyro * prevRawBdyAnglrRte_gyro;
                prevRawBdyAnglrRte_gyro = rawBdyAnglrRte_gyro;
                addpoints(msurdBdyAnglrRte_pltX, t * simSpdMltplr, rad2deg(msurdBdyAnglrRte(1)));
                addpoints(msurdBdyAnglrRte_pltY, t * simSpdMltplr, rad2deg(msurdBdyAnglrRte(2)));
                addpoints(msurdBdyAnglrRte_pltZ, t * simSpdMltplr, rad2deg(msurdBdyAnglrRte(3)));
                hold(axes_gyroPlt, 'off');
                hold(axes_mgntrqrPlt, 'on');
                crrnt_mgntrqrs = (-bDotCntrllrGain_mgntrqrs ./ (numCoils_mgntrqrs .* sctnArea_mgntrqrs)) .* cross(dsirdBdyAnglrRte_spcrft - msurdBdyAnglrRte, bdyMgntcFld_spcrft);
                if (abs(crrnt_mgntrqrs(1)) > maxCrrnt_xMgntrqr)
                    crrnt_mgntrqrs = crrnt_mgntrqrs * maxCrrnt_xMgntrqr / abs(crrnt_mgntrqrs(1));
                end
                if (abs(crrnt_mgntrqrs(2)) > maxCrrnt_yMgntrqr)
                    crrnt_mgntrqrs = crrnt_mgntrqrs * maxCrrnt_yMgntrqr / abs(crrnt_mgntrqrs(2));
                end
                if (abs(crrnt_mgntrqrs(3)) > maxCrrnt_zMgntrqr)
                    crrnt_mgntrqrs = crrnt_mgntrqrs * maxCrrnt_zMgntrqr / abs(crrnt_mgntrqrs(3));
                end
                appliedTrqe_mgntrqrs = (numCoils_mgntrqrs .* sctnArea_mgntrqrs) .* cross(crrnt_mgntrqrs, bdyMgntcFld_spcrft);
                addpoints(mgntrqrCrrnt_pltX, t * simSpdMltplr, crrnt_mgntrqrs(1));
                addpoints(mgntrqrCrrnt_pltY, t * simSpdMltplr, crrnt_mgntrqrs(2));
                addpoints(mgntrqrCrrnt_pltZ, t * simSpdMltplr, crrnt_mgntrqrs(3));
                hold(axes_mgntrqrPlt, 'off');
                tPrev2 = t;
            end

            %Magnetometer Plot Update
            if (t - tPrev3 >= 1 / sampRte_mgntmtr)
                hold(axes_mgntmtrPlt, 'on');
                noiseVctr_mgntmtr = randn(3, 1);
                noiseVctr_mgntmtr = maxNoiseAmpltde_mgntmtr * noiseVctr_mgntmtr / norm(noiseVctr_mgntmtr);
                rawBdyMgntcFld_mgntmtr = bdyMgntcFld_spcrft - cnstntBiasVctr_mgntmtr + noiseVctr_mgntmtr;
                msurdBdyMgntcFld = (1 - lpFltrGain_mgntmtr) * rawBdyMgntcFld_mgntmtr + lpFltrGain_mgntmtr * prevRawBdyMgntcFld_mgntmtr;
                prevRawBdyMgntcFld_mgntmtr = rawBdyMgntcFld_mgntmtr;
                addpoints(msurdBdyMgntcFld_pltX, t * simSpdMltplr, msurdBdyMgntcFld(1));
                addpoints(msurdBdyMgntcFld_pltY, t * simSpdMltplr, msurdBdyMgntcFld(2));
                addpoints(msurdBdyMgntcFld_pltZ, t * simSpdMltplr, msurdBdyMgntcFld(3));
                hold(axes_mgntmtrPlt, 'off');
                tPrev3 = t;
            end
        end
    case 'Pre-Calculate'
        lcmSampRte = (frmeRte_simUI * sampRte_gyro) / gcd(frmeRte_simUI, sampRte_gyro);
        lcmSampRte = (lcmSampRte * sampRte_mgntmtr) / gcd(lcmSampRte, sampRte_mgntmtr);
        numSimStates = fix(tf * lcmSampRte);
        prcntPrgrss = 0;
        fprintf('Pre-calculating...');
        for simStateIndx = 1:numSimStates
            t = simStateIndx / lcmSampRte;
            prcntPrgrss = round((simStateIndx / numSimStates) * 100, 0);
            fprintf(prcntPrgrss + "%%");

            %Orbit, Spacecraft, and Ground Track Plots Update
            if (mod(lcmSampRte / frmeRte_simUI, simStateIndx) == 0 || mod(simStateIndx, lcmSampRte / frmeRte_simUI) == 0)
                statusBar.YData = t / tf;
                hold(axes_erthPlt, 'on');
                erthTrnsfrm.Matrix = makehgtform('axisrotate', [0, 0, 1], wrapTo360(deg2rad(OMEGA_ERTH) * t * simSpdMltplr));
                rotMatrx_orbt = rotMatrx313BdyToInrtl(wrapTo360(raan_orbt + draan_dt * t * simSpdMltplr), inc_orbt, wrapTo360(aop_orbt + daop_dt * t * simSpdMltplr));
                truAnmly_spcrft = wrapTo360((360 / period_orbt) * t * simSpdMltplr);
                prfclPostn_spcrft = [semiMajr_orbt * cosd(truAnmly_spcrft); semiMajr_orbt * sind(truAnmly_spcrft); 0];
                inrtlPostn_spcrft = rotMatrx_orbt * prfclPostn_spcrft;
                ltitde_orbt = geoc2geod(asind(inrtlPostn_spcrft(3, 1) / semiMajr_orbt), semiMajr_orbt);
                lngtde_orbt = wrapTo180(atan2d(inrtlPostn_spcrft(2, 1), inrtlPostn_spcrft(1, 1)) - wrapTo180(OMEGA_ERTH * t * simSpdMltplr));
                inrtlMgntcFld = 1E-9 * rotMatrx321BdyToInrtl(lngtde_orbt, 270 - ltitde_orbt, 0) * wrldmagm(alt_orbt, ltitde_orbt, lngtde_orbt, decyear(2020, 1, 1));
                addpoints(orbt, inrtlPostn_spcrft(1, 1), inrtlPostn_spcrft(2, 1), inrtlPostn_spcrft(3, 1));
                orbtCrrntPostn.XData = inrtlPostn_spcrft(1, 1);
                orbtCrrntPostn.YData = inrtlPostn_spcrft(2, 1);
                orbtCrrntPostn.ZData = inrtlPostn_spcrft(3, 1);
                hold(axes_erthPlt, 'off');
                hold(axes_spcrftPlt, 'on');
                qtrnion_spcrft = qtrnion_spcrft + (dqtrnion_dt / frmeRte_simUI) * simSpdMltplr;
                qtrnion_spcrft = qtrnion_spcrft / norm(qtrnion_spcrft);
                dqtrnion_dt = [0, -bdyAnglrRte_spcrft(1), -bdyAnglrRte_spcrft(2), -bdyAnglrRte_spcrft(3); bdyAnglrRte_spcrft(1), 0, bdyAnglrRte_spcrft(3), -bdyAnglrRte_spcrft(2); bdyAnglrRte_spcrft(2), -bdyAnglrRte_spcrft(3), 0, bdyAnglrRte_spcrft(1); bdyAnglrRte_spcrft(3), bdyAnglrRte_spcrft(2), -bdyAnglrRte_spcrft(1), 0] * qtrnion_spcrft * 0.5;
                bdyAnglrRte_spcrft = bdyAnglrRte_spcrft + (dbdyAnglrRte_dt / frmeRte_simUI) * simSpdMltplr;
                dbdyAnglrRte_dt = inrtaTnsr_spcrft \ (appliedTrqe_mgntrqrs - cross(bdyAnglrRte_spcrft, inrtaTnsr_spcrft * bdyAnglrRte_spcrft));
                bdyMgntcFld_spcrft = quatrotate(qtrnion_spcrft', inrtlMgntcFld')';
                if (norm(qtrnion_spcrft(2:4, 1)) ~= 0)
                    spcrftTrnsfrm.Matrix = makehgtform('axisrotate', qtrnion_spcrft(2:4, 1), 2 * acos(qtrnion_spcrft(1, 1)));
                end
                hold(axes_spcrftPlt, 'off');
                hold(axes_grndTrckPlt, 'on');
                grndTrckPlt.XData = [grndTrckPlt.XData, lngtde_orbt];
                grndTrckPlt.YData = [grndTrckPlt.YData, ltitde_orbt];
                grndTrckCrrntPostn.XData = lngtde_orbt;
                grndTrckCrrntPostn.YData = ltitde_orbt;
                hold(axes_grndTrckPlt, 'off');
            end

            %Magnetorquer and Gyroscope Plot Updates
            if (mod(lcmSampRte / sampRte_gyro, simStateIndx) == 0 || mod(simStateIndx, lcmSampRte / sampRte_gyro) == 0)
                hold(axes_gyroPlt, 'on');
                noiseVctr_gyro = randn(3, 1);
                noiseVctr_gyro = maxNoiseAmpltde_gyro * noiseVctr_gyro / norm(noiseVctr_gyro);
                rawBdyAnglrRte_gyro = bdyAnglrRte_spcrft - cnstntBiasVctr_gyro + noiseVctr_gyro;
                msurdBdyAnglrRte = (1 - lpFltrGain_gyro) * rawBdyAnglrRte_gyro + lpFltrGain_gyro * prevRawBdyAnglrRte_gyro;
                prevRawBdyAnglrRte_gyro = rawBdyAnglrRte_gyro;
                addpoints(msurdBdyAnglrRte_pltX, t * simSpdMltplr, rad2deg(msurdBdyAnglrRte(1)));
                addpoints(msurdBdyAnglrRte_pltY, t * simSpdMltplr, rad2deg(msurdBdyAnglrRte(2)));
                addpoints(msurdBdyAnglrRte_pltZ, t * simSpdMltplr, rad2deg(msurdBdyAnglrRte(3)));
                hold(axes_gyroPlt, 'off');
                hold(axes_mgntrqrPlt, 'on');
                crrnt_mgntrqrs = (-bDotCntrllrGain_mgntrqrs ./ (numCoils_mgntrqrs .* sctnArea_mgntrqrs)) .* cross(dsirdBdyAnglrRte_spcrft - msurdBdyAnglrRte, bdyMgntcFld_spcrft);
                if (abs(crrnt_mgntrqrs(1)) > maxCrrnt_xMgntrqr)
                    crrnt_mgntrqrs = crrnt_mgntrqrs * maxCrrnt_xMgntrqr / abs(crrnt_mgntrqrs(1));
                end
                if (abs(crrnt_mgntrqrs(2)) > maxCrrnt_yMgntrqr)
                    crrnt_mgntrqrs = crrnt_mgntrqrs * maxCrrnt_yMgntrqr / abs(crrnt_mgntrqrs(2));
                end
                if (abs(crrnt_mgntrqrs(3)) > maxCrrnt_zMgntrqr)
                    crrnt_mgntrqrs = crrnt_mgntrqrs * maxCrrnt_zMgntrqr / abs(crrnt_mgntrqrs(3));
                end
                appliedTrqe_mgntrqrs = (numCoils_mgntrqrs .* sctnArea_mgntrqrs) .* cross(crrnt_mgntrqrs, bdyMgntcFld_spcrft);
                addpoints(mgntrqrCrrnt_pltX, t * simSpdMltplr, crrnt_mgntrqrs(1));
                addpoints(mgntrqrCrrnt_pltY, t * simSpdMltplr, crrnt_mgntrqrs(2));
                addpoints(mgntrqrCrrnt_pltZ, t * simSpdMltplr, crrnt_mgntrqrs(3));
                hold(axes_mgntrqrPlt, 'off');
            end

            %Magnetometer Plot Update
            if (mod(lcmSampRte / sampRte_mgntmtr, simStateIndx) == 0 || mod(simStateIndx, lcmSampRte / sampRte_mgntmtr) == 0)
                hold(axes_mgntmtrPlt, 'on');
                noiseVctr_mgntmtr = randn(3, 1);
                noiseVctr_mgntmtr = maxNoiseAmpltde_mgntmtr * noiseVctr_mgntmtr / norm(noiseVctr_mgntmtr);
                rawBdyMgntcFld_mgntmtr = bdyMgntcFld_spcrft - cnstntBiasVctr_mgntmtr + noiseVctr_mgntmtr;
                msurdBdyMgntcFld = (1 - lpFltrGain_mgntmtr) * rawBdyMgntcFld_mgntmtr + lpFltrGain_mgntmtr * prevRawBdyMgntcFld_mgntmtr;
                prevRawBdyMgntcFld_mgntmtr = rawBdyMgntcFld_mgntmtr;
                addpoints(msurdBdyMgntcFld_pltX, t * simSpdMltplr, msurdBdyMgntcFld(1));
                addpoints(msurdBdyMgntcFld_pltY, t * simSpdMltplr, msurdBdyMgntcFld(2));
                addpoints(msurdBdyMgntcFld_pltZ, t * simSpdMltplr, msurdBdyMgntcFld(3));
                hold(axes_mgntmtrPlt, 'off');
            end
            
            fprintf(repmat('\b', 1, nnz(num2str(prcntPrgrss)) + 1));
        end
        
        fprintf("100%%\n");
        set(simUI, 'Visible', 'on');
        drawnow;
end

if (ishghandle(simUI))
    pausePlayBttn_simUI.String = '✓';
    title(axes_simStatus, "Simulation Progress", "Done.");
    disp(" ");
    
    disp("Run Details ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Completed: " + datestr(datetime('now')));
    disp(" ");
    
    switch simCalcltnMdfier
        case 'Real-Time'
            disp("Estimated Simulation Run Time (s): " + tf);
            disp("Actual Simulation Run Time (Including Pauses) (s): " + (tf + tPauseTotl));
            disp("Simulation UI Frame Rate (fps): " + frmeRte_simUI);
        case 'Pre-Calculate'
    end
    disp("Real Elapsed Time in Orbit (s): " + (numOrbts * period_orbt));
    disp(" ");
    
    disp("Orbit Altitude (m): " + alt_orbt);
    disp("Orbit Inclination (deg): " + inc_orbt);
    disp("Orbit Angle of Periapsis (deg): " + aop_orbt);
    disp("Orbit Right Ascension of the Ascending Node (deg): " + raan_orbt);
    disp("Orbit Period (s): " + period_orbt);
    disp("Number of Orbits: " + numOrbts);
    disp(" ");
    
    disp("Initial Body Angular Rate X (deg/s): " + initBdyAnglrRteX_spcrft);
    disp("Initial Body Angular Rate Y (deg/s): " + initBdyAnglrRteY_spcrft);
    disp("Initial Body Angular Rate Z (deg/s): " + initBdyAnglrRteZ_spcrft);
    disp(" ");
    
    disp("Gyroscope Low Pass Filter Gain: " + lpFltrGain_gyro);
    disp(" ");
    
    disp("Magnetometer Low Pass Filter Gain: " + lpFltrGain_mgntmtr);
    disp(" ");
    
    disp("B-dot Controller Gain X Magnetorquer: " + bDotCntrllrGain_xMgntrqr);
    disp("B-dot Controller Gain Y Magnetorquer: " + bDotCntrllrGain_yMgntrqr);
    disp("B-dot Controller Gain Z Magnetorquer: " + bDotCntrllrGain_zMgntrqr);
    disp(" ");
end
