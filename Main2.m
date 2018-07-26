clear
clc

opengl software

import Environment.Environment
import Agent.createAgents
import Victim.createVictims
import Arena.Arena

% Environment(sizeX,sizeY,windDirection,windSpeed,eSun,reflectionValue)
environment = Environment(100,100,90,10,1,1.7);
% Agent(initialPositionX, initialPositionY, id, color)
agents = createAgents(1,[20 20],'b');
% createVictims(victimNumber,initialPositionX, initialPositionY,color)
victims = createVictims(5,50,50,'r');


% register agents and victims into environment
%  Arena(sizeX,sizeY,environment,agents,victims)
sizeX = 100;
sizeY = 100;

arena = Arena(100,100,environment,agents,victims);

arena.show(3);
