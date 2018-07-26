classdef Sea < handle
    %SEA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = 'private')
        reflectionValue;
        seaSurfaceCurrentX;
        seaSurfaceCurrentY;
        
        % has a wind property
        wind
    end
    
    properties (Access='private')
        energyTransferCoefficient = 0.4;
    end
    
    methods
        function self = Sea(reflectionValue, windObject)
            self.reflectionValue = reflectionValue;
            self.wind = windObject;
        end
        
        function update(self)
            self.seaSurfaceCurrentX = (self.energyTransferCoefficient*rand())*self.wind.getSpeedX();
            self.seaSurfaceCurrentY = (self.energyTransferCoefficient*rand())*self.wind.getSpeedY();
        end
        
        function value = getReflectionValue(self)
            value = self.reflectionValue;
        end
        
        function value = getCurrentX(self)
            value = self.seaSurfaceCurrentX;
        end
        
        function value = getCurrentY(self)
            value = self.seaSurfaceCurrentY;
        end
    end
end

