classdef Victim < handle
    %VICTIM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = 'private')
        displayShape = [0.5 0.5 1;-0.5 0.5 1; -0.5 -0.5 1;0.5 -0.5 1];
        dragCoefficient = 0.5;
        environment;
        
        % attribute
        id
        color
        
        % dynamic parameter
        positionX
        positionY
        speedX
        speedY
        
        % display handler
        displayHandler
    end
    
    methods
        function self = Victim(positionX,positionY,id,color)
            self.id = id;
            self.positionX = positionX;
            self.positionY = positionY;
            self.color = color;
        end
        
        %% getter and Setter
        function setEnvironment(self,environmentObject)
            self.environment = environmentObject;
        end
        
        
        function initShow(self)
            victimBody = self.displayShape + [self.positionX self.positionY 0;
                                              self.positionX self.positionY 0;
                                              self.positionX self.positionY 0;
                                              self.positionX self.positionY 0];
            self.displayHandler = patch(...
                'Vertices',victimBody,...
                'Faces',[1 2 3 4 1],...
                'FaceColor',self.color,...
                'FaceVertexCData',[0.5 0.5 0.5]);
        end
        
        function move(self,time,seaObject)
            self.speedX = seaObject.getCurrentX();
            self.speedY = seaObject.getCurrentY();
            
            self.positionX = self.positionX + time*self.speedX;
            self.positionY = self.positionY + time*self.speedY;
            updateShow(self);
        end
    end
    
    methods (Access = 'private')
        function updateShow(self)
            victimBody = self.displayShape + [self.positionX self.positionY 0;
                                              self.positionX self.positionY 0;
                                              self.positionX self.positionY 0;
                                              self.positionX self.positionY 0];
            set(self.displayHandler,'Vertices',victimBody);
        end
    end
end

