function grphcs = erth()
    % ERTH Creates a plot with an Earth-textured ellipsoid which is to be
    %      centered at an Earth Centered Inertial (ECI) frame.
    %
    % Description: grphcs = erth() uses the Earth's equatorial radius
    % and the Earth's polar radius to create a wireframe model of an ellipsoid
    % representing the Earth. Then it applies the image file of the Earth's
    % surface as a texture to the ellipsoid. The graphics object (grphcs) is
    % returned. 
    %
    % Credits: This code is based heavily on Ryan Gray's "3D Earth Example" on
    % the MATLAB Central File Exchange. See NOTICES for licensing attribution.
    %
    % Author(s): Edwin Christhuraj
    % Created: 23-Apr-2021
    %
    % Copyright (c) 2021 Edwin Christhuraj.
    % See LICENSE for terms.

    %% Earth Plot Variables
    PhysclCnstnts;
    numSurfPanels = 180;
    trnsprncy_erth = 0.75;

    %% Earth Plot Setup
    [x, y, z] = ellipsoid(0, 0, 0, R_EQTR_ERTH, R_EQTR_ERTH, R_POLR_ERTH, numSurfPanels);
    grphcs = surf(x, y, -z, 'FaceColor', 'texture', 'CData', ERTH_SRFCE);
    set(grphcs, 'EdgeColor', 'none', 'FaceAlpha', trnsprncy_erth, 'Clipping', 'off');
end
