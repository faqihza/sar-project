classdef PIDController < handle
    %PIDCONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Kp
        Ki
        Kd
        tSampling
        
        error
        sumError
        diffError
    end
    
    methods
        function self = PIDController(proportional,integral,derivative)
            self.error = 0;
            self.sumError = 0;
            self.diffError = 0;
            self.Kp = proportional;
            self.Ki = integral;
            self.Kd = derivative;
        end
        
        function setParameter(self,proportional,integral,derivative)
            self.Kp = proportional;
            self.Ki = integral;
            self.Kd = derivative;
        end
        
        function manipulatedVariable = getManipulatedVariable(self,setPoint,output)
            oldError = self.error;
            self.error = setPoint - output;
            self.sumError = self.sumError + self.error;
            self.diffError = (self.error - oldError);
            manipulatedVariable = self.Kp*self.error + self.Ki*self.sumError + self.diffError*self.Kd;
        end
    end
end

