classdef Agent < handle
    
    properties
        % Attributes
        id
        displayColor
        
        % Dynamics parameter
        % first order
        positionX
        positionY
        heading
        altitude
        
        % second order
        speedX
        speedY
        speed
        turningAngle
        
        % Sensor
        proximitySensor
        camera
        
        % Search Pattern
        searchPattern
        targetPoint
        
        % Movement Behaviour
        chasingTarget
        avoidAgentCollition
        
        % Control System
        speedControl
        headingControl
        positionControl
        altitudeControl
        
        % System Constraints
        maxTurn = 180;
        maxSpeed = 10;
        minSpeed = 2;
        mass = 1;
        
        % Display Parameter
        displayHandler
        idDisplayHandler
        displayShape = [0  2 1;
                        1 -1 1;
                       -1 -1 1];
        penHandler
        penData
    end
    
    properties (Access = 'private')
        environment
    end
    
    methods
        function self = Agent(initialPosition, id, color)
            import Agent.Sensor.Camera
            import Agent.Sensor.Proximity
            import Agent.ControlSystem.PIDController
            import Agent.SearchPattern.CreepingLine
            import Agent.SearchPattern.TargetPoint
            import Agent.Behaviour.ChaseTarget
            import Agent.Behaviour.AvoidAgentCollition
            
            self.id = id;
            self.positionX = initialPosition(1) + 5*randn();
            self.positionY = initialPosition(2) + 5*randn();
            self.heading = randi([0 360],1);
            self.altitude = 10;
            self.speed = 0;
            self.speedX = 0;
            self.speedY = 0;
            self.displayColor = color;
            
            %% sensor Creation
            % Camera(size,coverageAngle,tiltAngle)
            self.camera = Camera(self, 10, 60, 0);
            % Proximity(agent,innerRadius,outerRadius)
            self.proximitySensor = Proximity(self,5,10);
            
            
            %% Search Pattern Creation
            self.searchPattern = CreepingLine();
            % calculatePath(self,stepSize,initialPositionX,initialPositionY,heading,sizeX,sizeY,sweepRadius)
            self.searchPattern.calculatePath(1,50,50,45,30,30,2);
            self.targetPoint = TargetPoint(self.searchPattern.nextPath(),self);
            
            %% behaviour assignment
            self.chasingTarget = ChaseTarget(self);
            self.avoidAgentCollition = AvoidAgentCollition(self,self.proximitySensor);
            
            %% Controller Creation
            proportional = 1;
            integral = 0;
            derivative = 0.5;
            % PIDController(proportional,integral,derivative);
            self.headingControl = PIDController(proportional,integral,derivative);
            self.speedControl = PIDController(proportional,integral,derivative);
        end
        
        function update(self,timeSampling)
            % chasing target
            if self.targetPoint.isArrived()
                self.targetPoint.setTarget(self.searchPattern.nextPath());
            end
            [chaseSpeed, chaseTurning] = self.chasingTarget.getSpeedAndTurning(self.targetPoint);
            
            [isAvoid, avoidSpeed, avoidTurning] = self.avoidAgentCollition.avoid();
            
            if isAvoid
                move(self,avoidSpeed,avoidTurning,timeSampling);
                fprintf("id = %d, %f, %f \n", self.id, avoidSpeed, avoidTurning);
            else
                move(self,chaseSpeed,chaseTurning,timeSampling);
            end
            
            updateDraw(self);
        end
        
        function measure(self)
            self.camera.measure(self.environment);
            self.camera.show();
        end
        
        %% getter and setter
        function value = getId(self)
            value = self.id;
        end
        
        function setEnvironment(self,environmentObject)
            self.environment = environmentObject;
        end
        
        function initNeighbours(self)
            self.avoidAgentCollition.registerRemainingAgent(self.environment.getAgents());
        end
        function initShow(self)
            initNeighbours(self)
            initDraw(self);
            initPen(self);
        end
        
        function initShowCamera(self,environmentObject)
            title(sprintf("image feed for agent %d",self.id));
            self.camera.measure(environmentObject);
            self.camera.initShow();
        end
        
    end
    
    methods (Access = 'private')
        
        %% createPattern
        
        
        %% move
        
        function move(self,speed,turning,timeSampling)
            self.speed = speed;
            
            
            self.heading = self.heading + turning*timeSampling;
            self.positionX = self.positionX + speed*sind(self.heading)*timeSampling;
            self.positionY = self.positionY + speed*cosd(self.heading)*timeSampling;
        
        end
        
        
        
        %% movement control
        
        function heading = turningDynamics(self,turning)
            if turning > 180
                turning = turning - 360;
            end

            if turning > 0
                % turn right
                value = min(self.maxTurn,turning);
            else
                % turn left
                value = max(-self.maxTurn,turning);
            end
            
            turning = value;
        end
        
        function value = calculateSpeedValue(self,setPoint,currentValue)
            speedMV = self.speedControl.getManipulatedVariable(setPoint,currentValue);
            value = max(self.minSpeed,(min(self.maxSpeed,speedMV)));
        end
        
        
        %% draw
        function initDraw(self)
			x = self.positionX;
			y = self.positionY;
			h = -self.heading;

			rotationMatrix = [cosd(h) -sind(h) x;
							  sind(h)  cosd(h) y;
							  0			0	   1];
			agentBody = self.displayShape*rotationMatrix';
            self.idDisplayHandler = text(x,y,num2str(self.id),'color','red');
			self.displayHandler = patch(...
                    'Vertices',agentBody,...
                    'Faces',[1 2 3 1],...
                    'FaceColor',self.displayColor,...
                    'FaceVertexCData',[0.5 0.5 0.5]);
			set(self.displayHandler,'Vertices',agentBody);
			self.proximitySensor.initShow();
            self.avoidAgentCollition.initDraw();
        end
        
		function initPen(self)
			self.penData = [self.positionX self.positionY;NaN NaN];
			self.penHandler = patch('XData',self.penData(:,1),'YData',self.penData(:,2));
        end
        
        function drawPen(self)
			addPen(self);
			set(self.penHandler,'XData',self.penData(:,1),'YData',self.penData(:,2));
		end

		function addPen(self)
			self.penData(end,:) = [self.positionX self.positionY];
			self.penData = [self.penData;NaN NaN];
        end
        
        function updateDraw(self)
            x = self.positionX;
			y = self.positionY;
			h = -self.heading;

			rotationMatrix = [cosd(h) -sind(h) x;
							  sind(h)  cosd(h) y;
							  0			0	   1];
			agentBody = self.displayShape*rotationMatrix';
			set(self.displayHandler,'Vertices',agentBody);
            set(self.idDisplayHandler,'Position',[x y 0]);
            drawPen(self);
			self.proximitySensor.show();
            self.avoidAgentCollition.draw();
        end
    end
end

