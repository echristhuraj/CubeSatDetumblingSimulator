function grphcs = spcrft(dimnsns, showBdyFrme)
% SPCRFT Creates a plot with a rectangular prism representing the
%        CubeSat with roll, pitch, and yaw angles equal to zero
%        relative to the inertial frame.
%
% Description: grphcs = spcrft(dimnsns, showBdyFrme) creates a rectangular
% prism that has the dimensions of the spacecraft (provided by dimnsns)
% using MATLAB's patch command to provide a visual representation of the
% CubeSat in orbit. The graphics object (grphcs) is returned.
%
% Author(s): Edwin Christhuraj
% Created: 4-May-2021
%
% Copyright (c) 2021 Edwin Christhuraj.
% See LICENSE for terms.

%% Spacecraft Plot Variables
pstveXFceColr = 'b';
pstveXFceTrnsprncy = 0.75;
ngtveXFceColr = 'b';
ngtveXFceTrnsprncy = 0.75;
pstveYFceColr = 'b';
pstveYFceTrnsprncy = 0.75;
ngtveYFceColr = 'b';
ngtveYFceTrnsprncy = 0.75;
pstveZFceColr = 'g';
pstveZFceTrnsprncy = 0.75;
ngtveZFceColr = 'b';
ngtveZFceTrnsprncy = 0.75;
colr_bodyFrme = ['r','r','g'];
linWdth_bodyFrme = 1;
lablColr_bodyFrme = ['r','r','g'];

%% Spacecraft Plot Setup
vrtcs(1, :) = [dimnsns(1) / 2, dimnsns(2) / 2, -dimnsns(3) / 2];
vrtcs(2, :) = [-dimnsns(1) / 2, dimnsns(2) / 2, -dimnsns(3) / 2];
vrtcs(3, :) = [-dimnsns(1) / 2, -dimnsns(2) / 2, -dimnsns(3) / 2];
vrtcs(4, :) = [dimnsns(1) / 2, -dimnsns(2) / 2, -dimnsns(3) / 2];
vrtcs(5, :) = [dimnsns(1) / 2, dimnsns(2) / 2, dimnsns(3) / 2];
vrtcs(6, :) = [-dimnsns(1) / 2, dimnsns(2) / 2, dimnsns(3) / 2];
vrtcs(7, :) = [-dimnsns(1) / 2, -dimnsns(2) / 2, dimnsns(3) / 2];
vrtcs(8, :) = [dimnsns(1) / 2, -dimnsns(2) / 2, dimnsns(3) / 2];
faces = [1, 5, 8, 4; 3, 7, 6, 2; 2, 6, 5, 1; 4, 8, 7, 3; 5, 6, 7, 8; 4, 3, 2, 1];
grphcs(1) = patch('Vertices', vrtcs, 'Faces', faces(1, :), 'FaceColor', pstveXFceColr, 'EdgeColor', 'w', 'FaceAlpha', pstveXFceTrnsprncy, 'Clipping', 'off');
grphcs(2) = patch('Vertices', vrtcs, 'Faces', faces(2, :), 'FaceColor', ngtveXFceColr, 'EdgeColor', 'w', 'FaceAlpha', ngtveXFceTrnsprncy, 'Clipping', 'off');
grphcs(3) = patch('Vertices', vrtcs, 'Faces', faces(3, :), 'FaceColor', pstveYFceColr, 'EdgeColor', 'w', 'FaceAlpha', pstveYFceTrnsprncy, 'Clipping', 'off');
grphcs(4) = patch('Vertices', vrtcs, 'Faces', faces(4, :), 'FaceColor', ngtveYFceColr, 'EdgeColor', 'w', 'FaceAlpha', ngtveYFceTrnsprncy, 'Clipping', 'off');
grphcs(5) = patch('Vertices', vrtcs, 'Faces', faces(5, :), 'FaceColor', pstveZFceColr, 'EdgeColor', 'w', 'FaceAlpha', pstveZFceTrnsprncy, 'Clipping', 'off');
grphcs(6) = patch('Vertices', vrtcs, 'Faces', faces(6, :), 'FaceColor', ngtveZFceColr, 'EdgeColor', 'w', 'FaceAlpha', ngtveZFceTrnsprncy, 'Clipping', 'off');
if (showBdyFrme)
    size_bodyFrme(1:3) = max(dimnsns / 2) + 0.05;
    lablPostn_bodyFrme(1:3) = max(dimnsns / 2) + 0.1;
    grphcs(7) = plot3([0, size_bodyFrme(1)], [0, 0], [0, 0], 'Color', colr_bodyFrme(1), 'LineWidth', linWdth_bodyFrme, 'Clipping', 'off');
    grphcs(8) = plot3([0, 0], [0, size_bodyFrme(2)], [0, 0], 'Color', colr_bodyFrme(2), 'LineWidth', linWdth_bodyFrme, 'Clipping', 'off');
    grphcs(9) = plot3([0, 0], [0, 0], [0, size_bodyFrme(3)], 'Color', colr_bodyFrme(3), 'LineWidth', linWdth_bodyFrme, 'Clipping', 'off');
    grphcs(10) = text(lablPostn_bodyFrme(1), 0, 0, 'X_B', 'Color', lablColr_bodyFrme(1));
    grphcs(11) = text(0, lablPostn_bodyFrme(2), 0, 'Y_B', 'Color', lablColr_bodyFrme(2));
    grphcs(12) = text(0, 0, lablPostn_bodyFrme(3), 'Z_B', 'Color', lablColr_bodyFrme(3));
end
end
