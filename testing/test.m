clear
clc

global mass
global speed
global acceleration
global time 
global position
global drag

mass = 1;
speed = 0;
acceleration = 0;
time = 1;
position = 0;
drag = 0.5;
speedData = [];

for i=1:100
    dynamics(1)
    speedData = [speedData;speed];
end

for i=1:100
    dynamics(0)
    speedData = [speedData;speed];
end
plot(speedData);

function dynamics(force)
    global mass;
    global speed;
    global acceleration;
    global time ;
    global position;
    global drag;
    
    acceleration = force/mass;
    speed = speed - drag*speed + acceleration*time;
    position = position + speed*time;
end

