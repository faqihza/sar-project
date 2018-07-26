classdef Wind < handle
    %WIND Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = 'private')
        direction
        speed
        baseDirection
        baseSpeed
    end
    
    methods
        function self = Wind(direction,speed)
            self.direction = direction;
            self.speed = speed;
            self.baseDirection = direction;
            self.baseSpeed = speed;
        end
        
        function value = getBaseDirection(self)
            value = self.baseDirection;
        end
        
        function value = getBaseSpeed(self)
            value = self.baseSpeed;
        end
        
        function value = getDirection(self)
            randomize(self);
            value = self.direction;
        end        
        
        function value = getSpeed(self)
            randomize(self);
            value = self.speed;
        end
        
        function value = getSpeedX(self)
            randomize(self);
            value = self.speed*sind(self.direction);
        end
        
        function value = getSpeedY(self)
            randomize(self);
            value = self.speed*cosd(self.direction);
        end
        
        function showGraph(self)
            polarplot(deg2rad(self.direction),1,'o');
            str = sprintf('wind direction %.2f',self.direction);
            title(str);
            ax = gca;
            ax.ThetaDir = 'clockwise';
            ax.ThetaZeroLocation = 'top';
            ax.RLim = [0 1];
        end
    end
    
    methods (Access = 'private')
        function randomize(self)
            self.direction = self.baseDirection + 90*randn();
            self.speed = self.baseSpeed + randn();
        end
    end
end

