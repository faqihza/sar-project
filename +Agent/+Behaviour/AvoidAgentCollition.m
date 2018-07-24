classdef AvoidAgentCollition < handle
    %AVOIDCOLLITION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        agent
        allAgents
        proximitySensor
        
        heading
        magnitude
        
        % controller
        speedControl
        headingControl
        
        drawHandler
        drawData
    end
    
    methods
        function self = AvoidAgentCollition(agentObject,proximitySensorObject)
            import Agent.ControlSystem.PIDController
            
            
            self.agent = agentObject;
            self.proximitySensor = proximitySensorObject;
            
            proportional = 1;
            integral = 0;
            derivative = 0.5;
            % PIDController(proportional,integral,derivative);
            self.headingControl = PIDController(proportional,integral,derivative);
            self.speedControl = PIDController(proportional,integral,derivative);
        end
        
        function registerRemainingAgent(self,agentObjectInEnvironment)
            self.allAgents = agentObjectInEnvironment;
            
            for i=1:length(self.allAgents)
                if self.agent.getId() == self.allAgents(i).getId()
                    self.allAgents(i) = [];
                    break;
                end
            end

        end
        
        function [isAvoid,speed,turning] = avoid(self)
            [isAvoid,heading,magnitude] = getAverageHeading(self);
            self.heading = heading;
            self.magnitude = magnitude;
%             fprintf("heading %f, magnitude %f \n",heading, magnitude);
            
            %% turning movement
            headingSV = heading;
            headingPV = self.agent.heading;
            
            turning = calculateTurningValue(self,headingSV,headingPV);
            
            %% speed control
            magnitudeSV = magnitude;
            magnitudePV = 0;
            
            speed = calculateSpeedValue(self,magnitudeSV,magnitudePV);
        end
        
        function draw(self)
            vector = getVector(self,self.heading,self.magnitude);
            x = vector(1);
            y = vector(2);
            self.drawData = [self.agent.positionX self.agent.positionY;(self.agent.positionX + x) (self.agent.positionY + y)];
            self.drawHandler.XData = self.drawData(:,1);
            self.drawHandler.YData = self.drawData(:,2);
        end
        
        function initDraw(self)
            self.drawData = [self.agent.positionX self.agent.positionY;NaN NaN];
            self.drawHandler = patch('XData',self.drawData(:,1),'YData',self.drawData(:,2));
        end
    end
    
    methods (Access = 'private')
        
        function value = calculateTurningValue(self,setPoint,currentValue)
            turnMV = self.headingControl.getManipulatedVariable(setPoint,currentValue);

            if turnMV > 180
                turnMV =turnMV - 360;
            end

            if turnMV > 0
                % turn right
                value = min(self.agent.maxTurn,turnMV);
            else
                % turn left
                value = max(-self.agent.maxTurn,turnMV);
            end
        end
        
        function value = calculateSpeedValue(self,setPoint,currentValue)
            speedMV = self.agent.speed + self.speedControl.getManipulatedVariable(setPoint,currentValue);
            value = max(self.agent.minSpeed,(min(self.agent.maxSpeed,speedMV)));
        end
        
        function [isAvoid,heading,magnitude] = getAverageHeading(self)
            [neighboursNumber,distances,headings] = findNeighbours(self);
            vector = zeros(1,2);
            isAvoid = false;
            for i=1:neighboursNumber
                isAvoid = true;
                vector = vector + getVector(self,headings(i),distances(i));
            end
            
            [heading,magnitude] = vectorToPolar(self,vector);
        end
        
        function [neighboursNumber, distances, headings] = findNeighbours(self)
            headings = [];
            distances = [];
            neighboursNumber = 0;
            for i=1:length(self.allAgents)
                [distance,heading,isNear,~] = self.proximitySensor.check(self.allAgents(i));
                if isNear
                    headings = [headings heading];
                    distances = [distances distance];
                    neighboursNumber = neighboursNumber + 1;
                end
            end
            
        end
        
        function vector = getVector(self, heading, magnitude)
            if (~isempty(heading) && ~isempty(magnitude))
                xValue = (magnitude)*sind(heading);
                yValue = (magnitude)*cosd(heading);
                vector = [xValue yValue];
            else
                vector = [];
            end
        end
       
        function [heading,magnitude] = vectorToPolar(~,vector)
		    real = vector(2);
		    im = vector(1);
		    
            magnitude = sqrt(real^2 + im^2);
		    
            s = complex(real,im);
		    output2 = angle(s)*180/pi;
		    if  output2 < 0
		        heading = 360 + output2;
		    else
		        heading = output2;
		    end
        end
        
    end
end

