classdef Camera < handle
    %CAMERA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = 'private')
        data
        size
        coverageAngle
        tiltAngle
        
        imageHandler
        displayHandler
        
        %owned by agent
        host
        
    end
    
    methods
        function self = Camera(agent,size,coverageAngle,tiltAngle)
            self.size = size;
            self.coverageAngle = coverageAngle;
            self.tiltAngle = tiltAngle;
            self.host = agent;
        end
        
        function output = getHeading(self)
            output = self.host.getHeading();
        end
        
        function output = getAltitude(self)
            output = self.host.getAltitude();
        end
        
        function output = getResolution(self)
            output = self.size;
        end
        
        function output = getCoverage(self)
            output = self.coverageAngle;
        end
        
        function output = getTilt(self)
            output = self.tiltAngle;
        end
        
        function measure(self, environmentObject)
            self.data = environmentObject.sun.getRadiance(self);
        end
        
        function initShow(self)
            self.imageHandler = image(self.data);
            ax = gca;
            set(ax,'PlotBoxAspectRatio',[1 1 1], 'DataAspectRatio',[1 1 1]);
            axis(ax,'off');
        end
        
        function show(self)
            set(self.imageHandler,'CData', self.data);
        end
        
    end
end

