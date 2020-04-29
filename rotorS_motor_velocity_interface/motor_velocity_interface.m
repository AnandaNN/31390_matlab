
% This file contains parameters and calculations needed for running
% MatLab with rotorS ROS package for interfacing with a position controlled
% drone

%%
clc;
close all;
clear all;
%%

% Define name for MAV and define topic names
mav_name = 'ardrone';

position_topic = '/ardrone/odometry_sensor1/position'; %['/',mav_name,'/odometry_sensor1/position'];
attitude_topic = ['/' mav_name '/orientation_rpy'];
trajectory_cmd_topic = ['/' mav_name '/command/trajectory'];


%% Connect to Simulation (must start simulation first)
  
rosshutdown
%A new connection is estabilished with the ROS master
IP_ROS_Master = '192.168.2.103';

rosinit(IP_ROS_Master)

d = rosdevice
