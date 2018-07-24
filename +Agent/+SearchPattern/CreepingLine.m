classdef CreepingLine < handle
    
    properties
        pattern
        currentIndex
    end
    
    properties (Access = 'private')
        distanceTolerance = 0.5;
        initialPosX
        initialPosY
        currentPosX
        currentPosY
        areaSizeX
        areaSizeY
        sweepRadius
    end
    
    methods
        function self = CreepingLine()
            self.currentIndex = 0;
        end
        
        function target = nextPath(self)
            self.currentIndex = self.currentIndex + 1;
            try
                target = self.pattern(self.currentIndex,:);
            catch
                self.currentIndex = 1;
                target = self.pattern(self.currentIndex,:); 
            end
        end
        
        function target = nextTarget(self)
            try
                target = self.pattern(self.currentIndex+1,:);
            catch
                target = self.pattern(2,:); 
            end
        end
        
        
        
        function calculatePath(self,stepSize,initialPositionX,initialPositionY,heading,sizeX,sizeY,sweepRadius)
            self.initialPosX = initialPositionX;
            self.initialPosY = initialPositionY;
            self.areaSizeX = sizeX;
            self.areaSizeY = sizeY;
            self.sweepRadius = sweepRadius;
            startX = self.initialPosX;
            startY = self.initialPosY;
            pattern = [startX startY];
            currentX = startX;
            currentY = startY;
            distanceX = 0;
            distanceY = 0;
            totalY = 0;
            stepX = stepSize*sind(90 - heading);
            stepY = stepSize*cosd(90 - heading);
            while(true)
                if  (distanceX >= 0) && (distanceX < self.areaSizeX) && distanceY < self.sweepRadius*2
                    stepX = stepSize*sind(heading - 90);
                    stepY = stepSize*cosd(heading - 90);
                    distanceX = distanceX + abs(stepSize);
                    distanceY = 0;
                elseif distanceX >= self.areaSizeX && distanceY < self.sweepRadius*2
                    stepX = stepSize*sind(heading);
                    stepY = stepSize*cosd(heading);
                    distanceY = distanceY + abs(stepSize);
                    totalY = totalY + stepSize;
                    if (distanceY >= self.sweepRadius*2)
                        totalY = totalY - stepSize;
                        distanceX = 0;
                        stepX = stepSize*sind(heading + 90);
                        stepY = stepSize*cosd(heading + 90);
                    end
                elseif distanceX >= 0 && distanceX < self.areaSizeX && distanceY >= self.sweepRadius*2
                    stepX = stepSize*sind(heading + 90);
                    stepY = stepSize*cosd(heading + 90);
                    distanceX = distanceX + abs(stepSize);
                elseif distanceX >= self.areaSizeX && distanceY >= self.sweepRadius*2
                    stepX = stepSize*sind(heading);
                    stepY = stepSize*cosd(heading);
                    distanceY = distanceY + abs(stepSize);
                    totalY = totalY + stepSize;
                    if (distanceY >= self.sweepRadius*4)
                        totalY = totalY - stepSize;
                        distanceY = 0;
                        distanceX = 0;
                        stepX = stepSize*sind(heading - 90);
                        stepY = stepSize*cosd(heading - 90);
                    end
                end
                
                
                currentX = currentX + stepX;
                currentY = currentY + stepY;

                pattern = [pattern;currentX currentY];

                if totalY > self.areaSizeY
                    break;
                end
            end
            
            self.pattern = pattern;
        end
    end
end