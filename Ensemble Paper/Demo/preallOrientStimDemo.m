
clear all;
close all;

datafile='PreallocateOrientationStim';
datafile_full=sprintf('%s_full',datafile);

load('PreallocateOrientation');

mon_width_cm = 40;
mon_dist_cm = 73;
mon_width_deg = 2 * (180/pi) * atan((mon_width_cm/2)/mon_dist_cm);
PPD = (1024/mon_width_deg);

nCircles = 3;   % Number of circles of stimuli

for i=1:nCircles
    % Eccentricity of the circles is a scale of the height of the
    % screen
    wedgeSize(i) = 360/(dotAmount(i)*2);
    radiusAnnulusBig(i)=22.9823*PPD;
    % radiusAnnulusSmall=5.985*PPD;
    radiusMax(i)=(tand(wedgeSize(i))*radiusAnnulusBig(i))/(1+tand(wedgeSize(i)));
end
xJitter = 0;
yJitter = 0;
distanceScale = [.2 .35 .55];    % Scaling distnace inner ring starts from the center

% Determines the scaling factor based on eccentricity
for i=1:nCircles
    xCenter(i) = (radiusAnnulusBig(i)-radiusMax(i)+xJitter)*distanceScale(i);
    yCenter(i) = xCenter(i);
    eScale(i) = 1 + (xCenter(i)/PPD)/3.6;
end

scaledtexture = cell(1);

for i=1:nCircles
    imSize(i) = (PPD*eScale(i));                           % image size: n X n
    lamda = imSize(i)/2;                             % wavelength (number of pixels per cycle)
    sigma = imSize(i)*.1122;                             % gaussian standard deviation in pixels
    phase = .5;                            % phase (0 -> 1)
    trim = .005;                            % trim off gaussian values smaller than this
    
    phaseRad = (phase * 2* pi);             % convert to radians: 0 -> 2*pi
    
    X = 1:imSize(i);                           % X is a vector from 1 to imageSize
    X0 = (X / imSize(i)) - .5;                 % rescale X -> -.5 to .5
    
    [Xm, Ym] = meshgrid(X0, X0);             % 2D matrices
    
    newtexture = [];
    
    % for i=1:trialsDotAmount(1)
    theta = 0;
    freq = imSize(i)/lamda;                    % compute frequency from wavelength
    Xf = Xm * freq * 2*pi;
    thetaRad = (theta / 360) * 2*pi;        % convert theta (orientation) to radians
    Xt = Xm * cos(thetaRad);                % compute proportion of Xm for given orientation
    Yt = Ym * sin(thetaRad);                % compute proportion of Ym for given orientation
    XYt = [ Xt + Yt ];                      % sum X and Y components
    XYf = XYt * freq * 2*pi;                % convert to radians and scale by frequency
    grating = sin( XYf + phaseRad);         % make 2D sinewave
    grating=abs(grating)*256;               % convert to rgb
    
    s = sigma / imSize(i);                     % gaussian width as fraction of imageSize
    gauss = exp( -(((Xm.^2)+(Ym.^2)) ./ (2* s^2)) ); % formula for 2D gaussian
    gauss(gauss < trim) = 0;                 % trim around edges (for 8-bit colour displays)
    
    % Scaling the texture to fade to gray
    for k=1:imSize(i)
        for j=1:imSize(i)
            if grating(k,j)>128
                newtexture(k,j)=128+((grating(k,j)-128)*gauss(k,j));
            elseif grating(k,j)<128
                newtexture(k,j)=128-((128-grating(k,j))*gauss(k,j));
            end
        end
    end
    scaledtexture{i} = newtexture;
end

save(datafile,'scaledtexture','xCenter','yCenter','eScale','imSize','wedgeSize','radiusAnnulusBig','radiusMax','nCircles');
save(datafile_full);