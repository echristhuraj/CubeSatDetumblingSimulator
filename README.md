# CubeSat Detumbling Simulator

When a satellite such as a CubeSat (a small 10 cm x 10 cm x 10 cm spacecraft) is released from its launch vehicle container, it tumbles about all axes and must be detumbled
before mission operations can take place. Detumbling is the process of slowing the body angular rates of a satellite down until its attitude (angular orientation) is stabilized in 
orbit. After a satellite is detumbled, the on-board attitude determination and control system (ADCS) can use deterministic methods to acquire initial attitude measurements with 
respect to the inertial reference frame (the Earth-centered inertial (ECI) frame), and recursive methods to perform tasks like nadir-pointing and attitude maintenance.
Written in MATLAB, this CubeSat Detumbling Simulator (originally developed for UCI CubeSat) allows the user to simulate the detumbling phase of a LEO CubeSat (with at least a 3-
axis magnetorquer set, a magnetometer, and a gyroscope) using a B-dot controller and low pass filters (for sensor noise attenuation) in a closed-loop feedback process.

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

While the simulation is running, calculation can be paused/continued by toggling the pause/play button under the simulation progress bar.

## Limitations

* The orbit model is simplified to only circular orbits (eccentricity = 0) between 200 km and 850 km altitude with nonzero rates of change for argument of periapsis (AOP) and
right ascension of the ascending node (RAAN) to model the J2 pertubation effect, and zero rates of change for all other Keplerian elements.
* Disturbance forces and torques on the CubeSat were neglected so that the simplified analytical solution to the gravitational 2-body dynamics equations could be used.
* The user should adjust the `frmeRte_simUI` and `simSpdMltplr` parameters such that aliasing, graphical errors, or other issues do not occur as to make the simulation results 
diverge or the program to crash.
