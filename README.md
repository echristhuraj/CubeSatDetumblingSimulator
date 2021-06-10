# CubeSat Detumbling Simulator
[![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/echristhuraj/CubeSatDetumblingSimulator/blob/main/LICENSE.md)

When a satellite such as a CubeSat (a small 10 cm x 10 cm x 10 cm spacecraft) is released from its deployer, it tumbles about all axes and must be detumbled before mission
operations can take place. Detumbling is the process of slowing the body angular rates of a satellite down until its attitude (angular orientation) is stabilized in orbit
After a satellite is detumbled, the on-board attitude determination and control system (ADCS) can use deterministic methods to acquire initial attitude measurements with 
respect to the inertial reference frame (the Earth-centered inertial (ECI) frame), and recursive methods to perform tasks like nadir-pointing and attitude maintenance.
Written in MATLAB, this CubeSat Detumbling Simulator (originally developed for UCI CubeSat) allows the user to simulate the detumbling phase of a LEO CubeSat (with at least a 
3-axis magnetorquer set, a magnetometer, and a gyroscope) using a B-dot controller and low pass filters (for sensor noise attenuation) in a closed-loop feedback process.

## Requirements

**Hardware**

* Minimum RAM: 8 GB
* Recommended: Dedicated Graphics Card

**Software**

* MATLAB (Preferably R2020b or later)
* MATLAB Aerospace Toolbox

## Usage

Download and unzip the files. Open Main.m in MATLAB. In the "Main Parameters" section, initialize the program by assigning values to each of the parameters, making sure to stay
within the allowable range for each parameter. Run Main.m. A GUI window will pop up and will update in real-time as the simulation progresses:

![cubesat_detumbling_simulator_gui](https://user-images.githubusercontent.com/85334364/121489877-5cd38280-c989-11eb-8aa6-63696955615f.gif)

While the simulation is running, calculation can be paused/continued by toggling the pause/play button under the simulation progress bar. Once the simulation finishes, a summary
of run details will be outputted in the MATLAB Command Window. The user is free to edit the code however they would like to customize/personalize their simulation output.

### Tips

1. The default orientation of the CubeSat looks something like the image below. The red/green reference frame is the CubeSat's body frame and the white reference frame is the 
ECI frame. The `initRollAngl_spcrft` (about X), `initPtchAngl_spcrft` (about Y), and `initYawAngl_spcrft` (about Z) parameters represent how the CubeSat will initially be 
oriented relative to the ECI frame when ejected from the deployer; these angles define a body frame rotation sequence relative to the fixed ECI frame (think quaternion pre-
multiplication).

![cubesat_detumbling_simulator_default_orientation](https://user-images.githubusercontent.com/85334364/121497796-a7a4c880-c990-11eb-887e-9441a1702171.png)

2. The `viewAzmth` and `viewElvtn` parameters are passed into MATLAB's [view](https://www.mathworks.com/help/matlab/ref/view.html) command in the code to set the "camera line of 
sight" for the orbit plot and the spacecraft plot. In other words, these parameters change the angle at which the user sees the ECI frame in these two plots.

## Limitations

* The orbit model is simplified to only support circular orbits (eccentricity = 0) between 200 km and 850 km altitude with nonzero time rates of change for argument of periapsis 
(AOP) and right ascension of the ascending node (RAAN) to model the J2 pertubation effect, and zero rates of change for all other Keplerian elements.
* Disturbance forces and torques on the CubeSat were neglected so that the simplified analytical solution to the gravitational 2-body dynamics equations could be used.
* The only actuators used in the detumbling algorithm are the 3 magnetorquers and the only sensors used are the magnetometer and the gyroscope (often packaged together in 
an inertial measurement unit (IMU)).
* The user should adjust the `frmeRte_simUI` and `simSpdMltplr` parameters so that aliasing, graphical errors, or other issues do not occur; these issues can potentially 
cause the simulation results to diverge or the program to crash.

## References

[1] Montalvo, Carlos. "ADCS for LEO Satellites." _YouTube_. https://www.youtube.com/playlist?list=PL_D7_GvGz-v3mDQ9iR-cfjXsQf4DeR1_H. 

[2] Sanderson, Grant [3Blue1Brown] and Ben Eater. "Visualizing Quaternions: An explorable video series." _eater.net_. https://eater.net/quaternions/.

[3] Armesto, Leopoldo. "Quaternions | Robotic Systems." _YouTube_. https://www.youtube.com/watch?v=0FbDyWXemLw&t=309s.
