classdef ChaseTarget < handle
      
    properties
        % controller
        speedControl
        headingControl
        targetPoint
        
        
        % owned by agent
        agent
    end
    
    methods
        function self = ChaseTarget(agentObject)
            import Agent.ControlSystem.PIDController
            
            self.agent = agentObject;
            proportional = 1;
            integral = 0;
            derivative = 0.5;
            % PIDController(proportional,integral,derivative);
            self.headingControl = PIDController(proportional,integral,derivative);
            self.speedControl = PIDController(proportional,integral,derivative);
        end
        
        function [force, turning] = getForceAndTurning(self, targetObject)
            self.targetPoint = targetObject;
            %% turning movement
            headingSV = self.targetPoint.getHeading();
%             headingSV = heading;
            headingPV = 0;
            
            turning = self.headingControl.getManipulatedVariable(headingSV,headingPV);
            %% speed control
            distanceSV = self.targetPoint.getDistance();
%             distanceSV = distance;
            distancePV = 0;
            
            MV = self.speedControl.getManipulatedVariable(distanceSV,distancePV);
            
            %% body frame
            force = MV;
            
        end
    end
end

