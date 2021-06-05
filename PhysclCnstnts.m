% Filename:      PhysclCnstnts.m
%
% Description:   Creates and assigns values to static variables
%                representing non-changing physical constants including
%                Earth's geometry and physical characteristics of your
%                computer.
%
% Author(s):     Edwin Christhuraj
% Created:       23-Apr-2021
%
% Copyright (c) 2021 Edwin Christhuraj.
% See LICENSE for terms.

COMP_SCRN_SIZE = get(0, 'ScreenSize');
ERTH_SRFCE = imread('erth_srfce.jpg');
R_EQTR_ERTH = 6.378E6; %[m]
R_POLR_ERTH = 6.356E6; %[m]
OMEGA_ERTH = 4.178E-3; %[deg/s]
MU_ERTH = 3.986E14; %[m^3/s^2]
J2_ERTH = 1.08263E-3; %[unitless]