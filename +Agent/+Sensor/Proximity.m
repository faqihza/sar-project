classdef Proximity < handle
    %PROXIMITY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % parameters
        innerRadius
        outerRadius
        
        % position
        positionX
        positionY
        
        % displayH handler
        innerHandler
        outerHandler
        
        % owned by agent to get agent's Data in real time
        agent
    end
    
    methods
        
        function self = Proximity(agent,innerRadius,outerRadius)
            self.innerRadius = innerRadius;
            self.outerRadius = outerRadius;
            self.agent = agent;
        end
        
        function [distance, heading, isNear, isCollide] = check(self,otherAgent)
            self.positionX = self.agent.positionX;
            self.positionY = self.agent.positionY;
            
            distance = calculateDistance(self,otherAgent);
            heading = calculateHeading(self,otherAgent);
            [isNear, isCollide] = checkPerimeter(self,distance);
        end
        
        function show(self)
            posX = self.agent.positionX;
			posY = self.agent.positionY;
			theta = linspace(0,2*pi,20);
			x1 = self.outerRadius*cos(theta) + posX;
			y1 = self.outerRadius*sin(theta) + posY;
            x2 = self.innerRadius*cos(theta) + posX;
			y2 = self.innerRadius*sin(theta) + posY;
			z = ones(1,length(theta));

			perimeter1 = [x1' y1' z'];
            perimeter2 = [x2' y2' z'];
            
            set(self.outerHandler,'Vertices',perimeter1);
            set(self.innerHandler,'Vertices',perimeter2);
        end
        
        function initShow(self)
            posX = self.agent.positionX;
			posY = self.agent.positionY;
			theta = linspace(0,2*pi,20);
			x1 = self.outerRadius*cos(theta) + posX;
			y1 = self.outerRadius*sin(theta) + posY;
            x2 = self.innerRadius*cos(theta) + posX;
			y2 = self.innerRadius*sin(theta) + posY;
			z = ones(1,length(theta));

			perimeter1 = [x1' y1' z'];
            perimeter2 = [x2' y2' z'];
            faces = 1:1:length(theta);
            faces = [faces 1];
			self.outerHandler = patch (...
				'Vertices', perimeter1,...
                'Faces',faces,...
                'FaceColor','blue',...
                'FaceAlpha',.1,...
                'LineStyle','-');
            self.innerHandler = patch (...
				'Vertices', perimeter2,...
                'Faces',faces,...
                'FaceColor','red',...
                'FaceAlpha',.1,...
                'LineStyle','-');
        end
        
    end
    
    methods (Access = 'private')
        function [isNear, isCollide] = checkPerimeter(self,distance)
            if (distance < self.innerRadius)
                isNear = true;
            else
                isNear = false;
            end
            
            if (distance == 0)
                isCollide = true;
            else
                isCollide = false;
            end
        end
        
        function distance = calculateDistance(self,otherAgent)
            distance = sqrt((self.positionX - otherAgent.positionX)^2 + (self.positionY - otherAgent.positionY)^2);
        end
        
        function heading = calculateHeading(self,otherAgent)
            absoluteHeading = vectorToAngle(self,[getRelativePositionX(self,otherAgent) getRelativePositionY(self,otherAgent)]);
          
            heading = absoluteHeading;
        end
        
        function value = getRelativePositionX(self,otherAgent)
            value = self.agent.positionX - otherAgent.positionX;
        end
        
        function value = getRelativePositionY(self,otherAgent)
            value = self.agent.positionY - otherAgent.positionY;
        end
        
        function output = vectorToAngle(~,vector)
		    real = vector(2);
		    im = vector(1);
		    
		    s = complex(real,im);
		    output2 = angle(s)*180/pi;
		    if  output2 < 0
		        output = 360 + output2;
		    else
		        output = output2;
		    end
        end
        
    end
    
end

