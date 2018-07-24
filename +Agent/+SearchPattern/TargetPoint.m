classdef TargetPoint < handle
    properties
        positionX
        positionY
        relativePositionX
        relativePositionY
        distance
        relativeHeading
        
        % owned by agent
        agent
    end
    
    methods
        function self = TargetPoint(position,agentObject)
            self.positionX = position(1);
            self.positionY = position(2);
            self.agent = agentObject;
            self.distance = calculateDistance(self);
            self.relativeHeading = getHeading(self);
        end
        
        function setTarget(self,position)
            self.positionX = position(1);
            self.positionY = position(2);
        end
        
        function position = getPosition(self)
            position = [self.positionX self.positionY];
        end
        function value = getDistance(self)
            value = calculateDistance(self);
        end
        
        function output = isArrived(self)
            if calculateDistance(self) < 1
                output = true;
            else 
                output = false;
            end 
        end
        
        function value = getHeading(self)
            absoluteHeading = vectorToAngle(self,[getRelativePositionX(self) getRelativePositionY(self)]);
            relativeHeading = absoluteHeading - self.agent.heading;
            
            if relativeHeading > 180
                relativeHeading = relativeHeading - 360;
            elseif relativeHeading < -180
                relativeHeading = 360 + relativeHeading;
            end
            self.relativeHeading = relativeHeading;
            value = self.relativeHeading;
        end
    end
    
    methods (Access = 'private')
        function value = calculateDistance(self)
            value = sqrt(getRelativePositionX(self)^2 + getRelativePositionY(self)^2);
            self.distance = value;
        end
        
        function value = getRelativePositionX(self)
            value = self.positionX - self.agent.positionX;
            self.relativePositionX = value;
        end
        
        function value = getRelativePositionY(self)
            value = self.positionY - self.agent.positionY;
            self.relativePositionY = value;
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