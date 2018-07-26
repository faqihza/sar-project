classdef Arena < handle
    %ARENA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = 'private')
        sizeX
        sizeY
        
        environment
        agents
        victims
        
        % plot handler
        display
    end
    
    methods
        function self = Arena(sizeX,sizeY,environment,agents,victims)
            self.sizeX = sizeX;
            self.sizeY = sizeY;
            self.environment = environment;
            self.agents = agents; 
            self.victims = victims;
        end
        
        function build(self)
          
            disp("All Components are built");
            
        end
        
        function show(self,numberFigure)
            figure(numberFigure);
            clf;
            subplot(3,3,[1,2,4,5,7,8]);
            initVisualisation(self);
            initAgentsAndVictims(self);
        end
        
    end
    
    methods (Access = 'private')
        
        function initVisualisation(self)
            self.display = patch(...
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
        
        function initAgentsAndVictims(self)
            for i=1:length(self.agents)
                self.agents(i).initShow();
            end

            for i=1:length(self.victims)
                self.victims(i).initShow();
            end
        end
    end
    
end

