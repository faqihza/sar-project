classdef Environment < handle
    %ENVIRONMENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        sizeX
        sizeY
        agents
        victims
        
        wind
        sun
        sea
        
        arena
        
    end
    
    
    methods
        function self = Environment(sizeX,sizeY,windDirection,windSpeed,eSun,reflectionValue)
            
            % import required packages
            import Environment.Wind.Wind
            import Environment.Sun.Sun
            import Environment.Sea.Sea
            
            self.sizeX = sizeX;
            self.sizeY = sizeY;
            
            % intantiate wind
            self.wind = Wind(windDirection,windSpeed);
            self.sea = Sea(reflectionValue,self.wind);
            self.sun = Sun(eSun,self.wind,self.sea);
            
        end
        
        function registerAgents(self,agentObjects)
            self.agents = agentObjects;
            
            for i=1:length(agentObjects)
                self.agents(i).setEnvironment(self);
            end
        end
        
        function registerVictims(self,victimObjects)
            self.victims = victimObjects;
            
            for i=1:length(victimObjects)
                self.victims(i).setEnvironment(self);
            end
        end
        
        function objects = getAgents(self)
            objects = self.agents;
        end
        
        function objects = getVictims(self)
            objects = self.victims;
        end
        
        function update(self)
            self.sea.update();
        end
        
        function initVisualisation(self)
            self.arena = patch(...
                'XData',[0,self.sizeX,self.sizeX,0],...
                'YData',[0,0,self.sizeY,self.sizeY],...
                'FaceColor', 'none',...
                'LineWidth', 3,...
                'EdgeAlpha', 0.5,...
                'EdgeColor', [0,0,0]);
            
           % setting Axis
            ax = gca;
            axis(ax,[0,self.sizeX,0,self.sizeY]);
            set(ax,'PlotBoxAspectRatio',[1 1 1],'DataAspectRatio',[1 1 1]);
            
            % no axis
            axis(ax,'off');
        end
    end
end

