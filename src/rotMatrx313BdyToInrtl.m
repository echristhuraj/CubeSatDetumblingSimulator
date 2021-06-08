function rotMatrx = rotMatrx313BdyToInrtl(yaw1, roll, yaw2)
% ROTMATRX313BDYTOINRTL Creates the 3-1-3 sequence Euler rotation
%                       matrix that can be used to express a
%                       position vector expressed in body frame
%                       coordinates to the position vector
%                       expressed in inertial frame coordinates.
%
% Description: rotMatrx = rotMatrx313BdyToInrtl(yaw1, roll, yaw2)
% uses the angles (3)yaw1, (1)roll, and (3)yaw2 (used to transform the
% inertial frame to the body frame) to construct the 3-1-3 sequence Euler
% rotation matrix that is used to convert body frame coordinates to
% inertial frame coordinates. The 3 x 3 rotation matrix (rotMatrx) is
% returned.
%
% Author(s): Edwin Christhuraj
% Created: 23-Apr-2021
%
% Copyright (c) 2021 Edwin Christhuraj.
% See LICENSE for terms.

rotMatrx(1, 1) = cosd(yaw1) * cosd(yaw2) - sind(yaw1) * cosd(roll) * sind(yaw2);
rotMatrx(1, 2) = -cosd(yaw1) * sind(yaw2) - sind(yaw1) * cosd(roll) * cosd(yaw2);
rotMatrx(1, 3) = sind(yaw1) * sind(roll);
rotMatrx(2, 1) = sind(yaw1) * cosd(yaw2) + cosd(yaw1) * cosd(roll) * sind(yaw2);
rotMatrx(2, 2) = -sind(yaw1) * sind(yaw2) + cosd(yaw1) * cosd(roll) * cosd(yaw2);
rotMatrx(2, 3) = -cosd(yaw1) * sind(roll);
rotMatrx(3, 1) = sind(roll) * sind(yaw2);
rotMatrx(3, 2) = sind(roll) * cosd(yaw2);
rotMatrx(3, 3) = cosd(roll);
end

