function rotMatrx = rotMatrx321BdyToInrtl(yaw, pitch, roll)
    % ROTMATRX321BDYTOINRTL Creates the 3-2-1 sequence Euler rotation
    %                       matrix that can be used to express a
    %                       position vector expressed in body frame
    %                       coordinates to the position vector
    %                       expressed in inertial frame coordinates.
    %
    % Description: rotMatrx = rotMatrx321BdyToInrtl(yaw1, roll, yaw2)
    % uses the angles (3)yaw, (2)pitch, and (1)roll (used to transform the
    % inertial frame to the body frame) to construct the 3-2-1 sequence Euler
    % rotation matrix that is used to convert body frame coordinates to
    % inertial frame coordinates. The 3 x 3 rotation matrix (rotMatrx) is
    % returned.
    % 
    % Inputs: yaw [deg] *Type: integer* *Range: 0 ≤ yaw < 360*
    %         pitch [deg] *Type: integer* *Range: 0 ≤ pitch < 360*
    %         roll [deg] *Type: integer* *Range: 0 ≤ roll < 360*
    %
    % Author(s): Edwin Christhuraj
    % Created: 4-May-2021
    %
    % Copyright (c) 2021 Edwin Christhuraj.
    % See LICENSE for terms.

    rotMatrx(1, 1) = cosd(yaw) * cosd(pitch);
    rotMatrx(1, 2) = cosd(yaw) * sind(pitch) * sind(roll) - sind(yaw) * cosd(roll);
    rotMatrx(1, 3) = cosd(yaw) * sind(pitch) * cosd(roll) + sind(yaw) * sind(roll);
    rotMatrx(2, 1) = sind(yaw) * cosd(pitch);
    rotMatrx(2, 2) = sind(yaw) * sind(pitch) * sind(roll) + cosd(yaw) * cosd(roll);
    rotMatrx(2, 3) = sind(yaw) * sind(pitch) * cosd(roll) - cosd(yaw) * sind(roll);
    rotMatrx(3, 1) = -sind(pitch);
    rotMatrx(3, 2) = cosd(pitch) * sind(roll);
    rotMatrx(3, 3) = cosd(pitch) * cosd(roll);
end
