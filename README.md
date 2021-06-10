# CubeSat Detumbling Simulator

When a satellite such as a CubeSat (a small 10 cm x 10 cm x 10 cm spacecraft) is released from its launch vehicle container, it tumbles about all axes and must be detumbled
before mission operations can take place. Detumbling is the process of slowing the body angular rates of a satellite down until its attitude (angular orientation) is stabilized in 
orbit. After a satellite is detumbled, the on-board attitude determination and control system (ADCS) can use deterministic methods to acquire initial attitude measurements with 
respect to the inertial reference frame (the Earth-centered inertial (ECI) frame), and recursive methods to perform tasks like nadir-pointing and attitude maintenance.
Written in MATLAB, this CubeSat Detumbling Simulator (originally developed for UCI CubeSat) allows the user to simulate the detumbling phase of a LEO CubeSat (with at least a 3-
axis magnetorquer set, a magnetometer, and a gyroscope) using a B-dot controller and low pass filters (for sensor noise attenuation) in a closed-loop feedback process.

## Requirements

### Hardware

* Minimum RAM: 8 GB
* Recommended: Dedicated Graphics Card

### Software

* MATLAB (Preferably R2020b or later)
* MATLAB Aerospace Toolbox

## Usage

Download and unzip the files. Open Main.m in MATLAB. In the "Main Parameters" section, initialize the program by assigning values to each of the parameters, making sure to stay
within the allowable range for each parameter. Run Main.m. A GUI window will pop up and will update in real-time as the simulation progresses:

![cubesat_detumbling_simulator_gui](https://user-images.githubusercontent.com/85334364/121482268-d49daf00-c981-11eb-8bc3-a523955ac50d.gif)

While the simulation is running, calculation can be paused/continued by toggling the pause/play button 

## Limitations
