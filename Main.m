clear
clc

opengl software

import Environment.Environment
import Agent.createAgents
import Victim.createVictims

% Environment(sizeX,sizeY,windDirection,windSpeed,eSun,reflectionValue)
environment = Environment(100,100,90,10,1,1.7);
% Agent(initialPositionX, initialPositionY, id, color)
agents = createAgents(4,[20 20],'b');
% createVictims(victimNumber,initialPositionX, initialPositionY,color)
victims = createVictims(5,50,50,'r');


% register agents and victims into environment
environment.registerAgents(agents);
environment.registerVictims(victims);

%% Initialise the Arena

fig = figure(1);
clf(fig);
subplot(3,3,[1,2,4,5,7,8]);
environment.initVisualisation();
for i=1:length(agents)
    agents(i).initShow();
end

for i=1:length(victims)
    victims(i).initShow();
end

subplot(3,3,3);
environment.sun.showGraph();
subplot(3,3,6);
environment.wind.showGraph();

%% initialise camera feeds
figure(2)
for i=1:length(agents)
    subplot(length(agents),1,i);
    agents(i).initShowCamera(environment);
end


%% Main simulation
simulationTime = 1000;
fps = 60;
timeSampling = 1/fps;

for i=1: simulationTime * fps
    moveVictims(victims,timeSampling,environment);
    moveAgents(agents,timeSampling);
    pause(timeSampling)
end


%% functions
function moveAgents(agents,timeSampling)
    for i=1:length(agents)
        agents(i).measure();
        agents(i).update(timeSampling);
    end
end

function moveVictims(victims,timeSampling,environment)
    for i=1:length(victims)
        environment.sea.update();
        victims(i).move(timeSampling,environment.sea); %move(self,time,seaObject)
    end
end