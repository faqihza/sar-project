classdef Camera < handle
    %CAMERA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
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

