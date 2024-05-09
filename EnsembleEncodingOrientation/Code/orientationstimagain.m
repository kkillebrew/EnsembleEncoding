clear
close all;

ListenChar(2);

backColor = 128;
dotColor = 128;
textColor = [256, 256, 256];

dotSize = 100;
freq = 2;

rect=[0 0 1024 768];     % test comps
[w,rect]=Screen('OpenWindow', 0,[backColor backColor backColor],rect);
x0 = rect(3)/2;% screen center
y0 = rect(4)/2;

imSize = 100;                           % image size: n X n
lamda = 10;                             % wavelength (number of pixels per cycle)
theta = 15;                              % grating orientation
sigma = 20;                             % gaussian standard deviation in pixels
phase = .5;                            % phase (0 -> 1)
trim = .005;                            % trim off gaussian values smaller than this

phaseRad = (phase * 2* pi);             % convert to radians: 0 -> 2*pi

X = 1:imSize;                           % X is a vector from 1 to imageSize
X0 = (X / imSize) - .5;                 % rescale X -> -.5 to .5

[Xm, Ym] = meshgrid(X0, X0);             % 2D matrices

freq = imSize/lamda;                    % compute frequency from wavelength
Xf = Xm * freq * 2*pi;
thetaRad = (theta / 360) * 2*pi;        % convert theta (orientation) to radians
Xt = Xm * cos(thetaRad);                % compute proportion of Xm for given orientation
Yt = Ym * sin(thetaRad);                % compute proportion of Ym for given orientation
XYt = [ Xt + Yt ];                      % sum X and Y components
XYf = XYt * freq * 2*pi;                % convert to radians and scale by frequency
grating = sin( XYf + phaseRad);         % make 2D sinewave
grating=abs(grating)*256;               % convert to rgb

s = sigma / imSize;                     % gaussian width as fraction of imageSize
gauss = exp( -(((Xm.^2)+(Ym.^2)) ./ (2* s^2)) ); % formula for 2D gaussian

gauss(gauss < trim) = 0;                 % trim around edges (for 8-bit colour displays)

% Scaling the texture to fade to gray
for i=1:imSize
    for j=1:imSize
        if grating(i,j)>128
            newtexture(i,j)=128+((grating(i,j)-128)*gauss(i,j));
        elseif grating(i,j)<128
            newtexture(i,j)=128-((128-grating(i,j))*gauss(i,j));
        end
    end
end

gabor = Screen('MakeTexture',w,newtexture);


[keyIsDown, secs, keycode] = KbCheck;
while ~keyIsDown
    [keyIsDown, secs, keycode] = KbCheck;
    destRect = [(x0-imSize/2) (y0-imSize/2) (x0+imSize/2) (y0+imSize/2)];
    Screen('DrawTexture',w, gabor,[],destRect);
    Screen('Flip',w);
end

ListenChar(0);
Screen('CloseAll');






