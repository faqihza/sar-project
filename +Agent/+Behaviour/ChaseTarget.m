classdef ChaseTarget < handle
      
    properties
        % controller
        speedControl
        headingControl
        targetPoint
        
        turning
        
        % owned by agent
        agent
    end
    
    methods
        function self = ChaseTarget(agentObject)
            import Agent.ControlSystem.PIDController
            
            self.agent = agentObject;
            proportional = 1.5;
            integral = 0;
            derivative = 0.5;
            % PIDController(proportional,integral,derivative);
            self.headingControl = PIDController(proportional,integral,derivative);
            self.speedControl = PIDController(proportional,integral,derivative);
        end
        
        function [speed, turning] = getSpeedAndTurning(self, targetObject)
            self.targetPoint = targetObject;
            %% turning movement
            headingSV = self.targetPoint.getHeading();
%             headingSV = heading;
            headingPV = 0;
            
            turning = calculateTurningValue(self,headingSV,headingPV);
            self.turning = turning;
            %% speed control
            distanceSV = self.targetPoint.getDistance();
%             distanceSV = distance;
            distancePV = 0;
            
            speed = calculateSpeedValue(self,distanceSV,distancePV);
            
        end
    end
    
    methods (Access = 'private')
        
        
        %% calculate control output
        
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
            speedMV = cosd(self.turning)*self.speedControl.getManipulatedVariable(setPoint,currentValue);
            value = max(self.agent.minSpeed,(min(self.agent.maxSpeed,speedMV)));
        end
    end
end

