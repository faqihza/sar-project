classdef Sun < handle
    
    properties
        % sun properties
        azimuth
        zenith
        time
        state
        stateIndex
        
        eSun
        
        % know the wind from the environment
        wind
        sea
    end
    
    properties (Access = private)
        sunData
    end
    
    methods
        function self = Sun(eSun,windObject,seaObject)
            self.eSun = eSun;
            self.wind = windObject;
            self.sea = seaObject;
            self.sunData = dataLoader(self,"sunData.txt"); 
            
            selectedData = self.sunData(randi([1 length(self.sunData)]));
			
			self.azimuth = selectedData.azimuth;
			self.zenith = selectedData.zenith;
			self.time = selectedData.time;
			self.state = selectedData.state;
			self.stateIndex = selectedData.stateIndex;
        end
        
        
        
        function radiance = getRadiance(self,cameraObject)
            radiance = calcRadianceValues(self,...
                self.azimuth,... 
                self.zenith,...
                self.eSun,...
                self.sea.getReflectionValue(),...
                self.wind.getSpeed(),...
                cameraObject.host.heading,...
                cameraObject.host.altitude,...
                cameraObject.size,...
                cameraObject.coverageAngle,...
                cameraObject.tiltAngle);
        end
        
        function showGraph(self)
			x1 = zeros(1,length(self.sunData));
			y1 = x1;
			z1 = x1;

			for i=1:length(self.sunData)
				y1(i) = cosd(self.sunData(i).azimuth);
				x1(i) = sind(self.sunData(i).azimuth);
				z1(i) = cosd(self.sunData(i).zenith);
			end
			
			y2 = cosd(self.azimuth);
			x2 = sind(self.azimuth);
			z2 = cosd(self.zenith);

			str = sprintf("Sun Position\nAzimuth = %.2f, Zenith = %.2f, Time=%s \nsun state = %s",self.azimuth,self.zenith,self.time,self.state);
			hold on
			plot3(x1,y1,z1)
			scatter3(x2,y2,z2)
			title(str);
			hold off
		end
    end
    
    methods (Access = 'private')
		function sunPosition = dataLoader(self,filename)
			M = fopen("+Environment/+Sun/" + filename);

			formatSpec = '%s';
			N = 3;
			Header = textscan(M, formatSpec,N,'Delimiter',' ');

			Data = textscan(M, '%{HH:mm}D %f %f');
			fclose(M);

			sunPosition = struct('time',[],'azimuth',[],'zenith',[], 'state',[], 'stateIndex',[]);

			length = size(Data{1,1},1);

			for i = 1:length
			    state = ' ';
			    stateIndex = [];
			    sunPosition(i).time = Data{1,1}(i);
			    sunPosition(i).azimuth = Data{1,2}(i);
			    sunPosition(i).zenith = 90 - Data{1,3}(i);
			    if ( 180 > sunPosition(i).azimuth > 0) && (90 > sunPosition(i).zenith > 0)
			        state = 'Upsun';
			        stateIndex = 2;
			    elseif (sunPosition(i).azimuth > 180) && (90 > sunPosition(i).zenith > 0)
			        state = 'Downsun';
			        stateIndex = 3;
			    elseif (sunPosition(i).azimuth > 180) && (sunPosition(i).zenith > 90)
			        state = 'Sunset';
			        stateIndex = 4;
			    elseif (sunPosition(i).azimuth > 0) && (sunPosition(i).zenith > 90)
			        state = 'Sunrise';
			        stateIndex = 1;
			    end
			    sunPosition(i).stateIndex = stateIndex;
			    sunPosition(i).state = state;
			end
        end
        
        function radianceValue = calcRadianceValues(self,sun_azimut, sun_zenith, Esun, n, wind, uav_heading, uav_altitude, sensor_size, sensor_coverage, camera_tilt_angle) 
        %[x,y,radianceValue] = calcRadianceValues(sun_azimut, sun_zenith, Esun, n, wind, 
        %               uav_heading, altitude, 
        %               sensor_size, sensor_coverage)
        %*environment's properties
        %   sun_azimut = angle of sun's position from north (clockwise)
        %   sun_zenith = angle of sun's posistion from earth's normal
        %   Esun = Sun irRadiance
        %   n = sea surface reflection rate (depends on wavelength)
        %   wind = average wind speed
        %*uav's direction
        %   uav_heading = angle of heading to the north
        %   altitude = altitude of uav from sea surface
        %*sensor property
        %   sensor_size = sensor size in pixel
        %   sensor_coverage = angle of sensor coverage
        %   camera_tilt_angle = angle from uav's -z direction

        coverage = tan(deg2rad(sensor_coverage))*uav_altitude;
        areaPerPixel = coverage/sensor_size;

        imageData = cell(sensor_size,sensor_size);
        distanceMatrix = zeros(sensor_size);
        pixelAzimut = zeros(sensor_size);
        y_coor_translation = tand(camera_tilt_angle)*uav_altitude;


        if mod(sensor_size,2)
           boundaryIndex = floor(sensor_size/2);
        else
           boundaryIndex = (sensor_size-1)/2;
        end

        x_coor = -boundaryIndex: 1 : boundaryIndex;
        y_coor = boundaryIndex: -1 : -boundaryIndex;


        y_coor = y_coor - y_coor_translation;

        for i=1:length(y_coor)
            for j = 1: length(x_coor)
                imageData{i,j} = sprintf('(%.2f,%.2f)',x_coor(j),y_coor(i));
                distanceMatrix(i,j) = areaPerPixel*hypot(x_coor(j),y_coor(i));
                if ( x_coor(j) > 0) && (y_coor(i) >= 0)
                    pixelAzimut(i,j) = atand(x_coor(j)/y_coor(i));
                elseif (y_coor(i) < 0)
                    pixelAzimut(i,j) = atand(x_coor(j)/y_coor(i)) + 180;
                elseif ( x_coor(j) < 0) && (y_coor(i) >= 0)
                    pixelAzimut(i,j) = atand(x_coor(j)/y_coor(i)) + 360;
                end
            end
        end

        pixelZenith = atand(distanceMatrix/uav_altitude);

        incidentAlpha = 180 + sun_azimut - uav_heading;
        incidentTheta = sun_zenith;

        radianceValue = zeros(sensor_size);
        for i = 1: sensor_size
            for j = 1:sensor_size
                reflectTheta = pixelZenith(i,j);
                reflectAlpha = pixelAzimut(i,j);
                radianceValue(i,j) = Lradiance(self,reflectTheta, reflectAlpha, incidentTheta, incidentAlpha, wind, Esun, n);
            end
        end

        x = (1:sensor_size)';
        y = (sensor_size:-1:1)';
        end

        function radiance = Lradiance(self,reflectTheta, reflectAlpha, incidentTheta, incidentAlpha, wind, Esun, n)
            x = acosd(sqrt((1 + (sind(incidentTheta)*sind(reflectTheta)*cosd(incidentAlpha-reflectAlpha)) + (cosd(incidentTheta)*cosd(reflectTheta)))/2));

            zx = - (sind(incidentTheta)*cosd(incidentAlpha) + sind(reflectTheta)*cosd(reflectAlpha))/(cosd(incidentTheta) + cosd(reflectTheta));
            zy = - (sind(incidentTheta)*sind(incidentAlpha) + sind(reflectTheta)*sind(reflectAlpha))/(cosd(incidentTheta) + cosd(reflectTheta));
            fr = (rho(self,n,x)*(cosd(x)^2) / (pi*(sigma(self,wind)^2)*(cosd(incidentTheta) + cosd(reflectTheta))^3)) * exp(- (zx^2 + zy^2)/sigma(self,wind));

            radiance = fr*Esun;
        end

        function rhoValue = rho(self,n,x)
            Rp = (n*cosd(x) - sqrt(((1 - sind(x)^2)/(n^2))))/(n*cosd(x) + sqrt(((1 - sind(x)^2)/(n^2))));
            Rs = (cosd(x) - n*sqrt(((1 - sind(x)^2)/(n^2))))/(cosd(x) + n*sqrt(((1 - sind(x)^2)/(n^2))));

            rhoValue = (abs(Rp)^2 + abs(Rs)^2)/2;
        end

        function sigmaValue = sigma(self,wind)
            sigmaValue = (0.003 + 0.00512*wind)/2;
        end
	end
end

