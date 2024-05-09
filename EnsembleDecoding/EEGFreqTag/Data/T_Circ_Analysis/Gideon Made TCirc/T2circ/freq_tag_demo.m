%Demo script for using t2circ_1tag
% Embed a sinewave in some noise
% clear;
signal_freq = 5; % This will be the frequency of the signal
target_tag = 5; % This will be the frequency that will be assessed and plotted
noise_level = 225; % This is how noisy the raw data will be
signal_level =1;
data_length = 1000; % Number of time_domain samples
num_sweeps = 200; % number of sweeps
alpha = 0.05; % Alpha level for significance
fft_data =  zeros(num_sweeps,data_length);
data =      zeros(num_sweeps,data_length);
critical_range_zero_center=zeros(data_length,360);

% Define the target signal and its fft
target = signal_level*sin(2*pi*signal_freq*(0:data_length-1)/data_length);
fft_target = fft(target);
% For each trial make a signal and add_noise to it and compute the fourier
% transform
for i =1:num_sweeps
    data(i,:) = target + noise_level*rand(1,data_length)-.5*noise_level;
    fft_data(i,:) = fft(data(i,:));
end
%Plot mean time_domain waveform
figure(1)
subplot(3,1,1)
plot(mean(data),'r','LineWidth',2);
hold on
plot(target,'b','LineWidth',2);
legend('mean signal','target')

%Call the T-circ program
[Z_est confidence_radii p t2circ] = t2circ_1tag(fft_data,alpha);

%Make confidence circle
ang = 1:360;
for i = 1:data_length
    critical_range_zero_center(i,:) = confidence_radii(i)*(cos(2*pi*ang/360)+sqrt(-1)*sin(2*pi*ang/360));
end

%Plot Magnitude Specturm and turn red a significan target_tag
figure(1)
subplot(3,1,2)
stem(0:60,abs(Z_est(1:61)),'b.','LineWidth',2)
if p(target_tag+1)< alpha
    hold on
    stem(target_tag,abs(Z_est(target_tag+1)),'r.','LineWidth',2);
    hold off
end
     xlabel('Hz','FontSize',16,'FontWeight','bold')
     ylabel('Fourier Magnitude','FontSize',14,'FontWeight','bold')
     set(gca,'FontSize',16,'FontWeight','bold')
title('Average Magnitude Spectrum');

%SETUP POLOR PLOT for frequency of interest: note the +1 is used to account
%for DC
subplot(3,1,3)
polar(0,abs(Z_est(target_tag+1))+.5*abs(Z_est(target_tag+1))');
hold on
polar([0,angle(Z_est(target_tag+1))],[0,abs(Z_est(target_tag+1))],'r-');
polar(angle(Z_est(target_tag+1)+critical_range_zero_center(target_tag+1,:))',abs(Z_est(target_tag+1)+critical_range_zero_center(target_tag+1,:))','b');
polar(angle(fft_target(target_tag+1))',abs(fft_target(target_tag+1))','k+');
 th = findall(gca,'Type','text');
    for ii = 1:length(th),
        set(th(ii),'FontSize',16,'FontWeight','bold')
    end
    hlines = findall(gca,'Type','line');
    title_text= sprintf('Frequency: %d, p-value: %.8f, Sweeps: %d',target_tag,p(target_tag+1),num_sweeps);
    title(title_text,'FontSize',16,'FontWeight','bold');
    for ii = 1:length(hlines)
        set(hlines(ii),'LineWidth',2);
    end
    hold off
  legend('','target coef', 'confidence interval', 'signal coef','Location','NorthEastOutside')