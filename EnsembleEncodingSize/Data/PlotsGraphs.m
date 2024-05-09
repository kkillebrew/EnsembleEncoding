

load('WeberAndAccuracy')

sprintf('%s_full',datafile);

dataSetName={'Filter Values of 0 .3 .5 .7','Filter Values of 0 .7 .8 .8','Filter Values of 0 .7 .8 1','Filter Values of 0 .8 .9 1','Filter Values of 0 .2 .4 .6 .8 1'};
filterValues=[0 .3 .5 .7; 0 .7 .8 .9; 0 .7 .8 1; 0 .8 .9 1];
meanValues=[2.3 2.4 2.5 2.6 2.7; 2.3 2.4 2.5 2.6 2.7; 2.0 2.3 2.6 2.9 3.2; 2.0 2.3 2.6 2.9 3.2;];

for i=1:4
    nameStr=sprintf('%s','Weber and Accuracy Values for ', dataSetName{i});
    
    figure('name',nameStr,'numbertitle','off')
    
    % Plotting the weber values across filter values
    hold on
    subplot(2,2,1)
    bar(weber_average(i,:));
    % Subplot labels
    xlabel('Filter');
    ylabel('Percent Difference Required to Determine a Change');
    set(gca,'YLim',[0 23]);
    set(gca,'XTickLabel',filterValues(i,:));
    str = {'','Average Weber Values for Each Filter Value',''}; % cell-array method
    title(str,'FontSize',15,'FontWeight','bold');
    nameStr='Weber and Accuracy Values';
    str = {'',nameStr,''}; % cell-array method
    
    % Plotting the accuracy around the PSE across filter values
    subplot(2,2,2)
    bar(right_count_filter_PSE_average(i,:));
    % Subplot labels
    xlabel('Filter');
    ylabel('Accuracy Rate');
    set(gca,'YLim',[0 1]);
    set(gca,'XTickLabel',filterValues(i,:));
    str = {'','Accuracy Rate Around the PSE Across Filter Values',''}; % cell-array method
    title(str,'FontSize',15,'FontWeight','bold');
    nameStr='Weber and Accuracy Values';
    str = {'',nameStr,''}; % cell-array method
    
    % Plotting the accuracy around the actual mean across filter values
    subplot(2,2,3)
    bar(right_count_filter_actual_average(i,:));
    % Subplot labels
    xlabel('Filter');
    ylabel('Accuracy Rate');
    set(gca,'YLim',[0 1]);
    set(gca,'XTickLabel',filterValues(i,:));
    str = {'','Accuracy Rate Around the Actual Mean Across Filter Values',''}; % cell-array method
    title(str,'FontSize',15,'FontWeight','bold');
    nameStr='Weber and Accuracy Values';
    str = {'',nameStr,''}; % cell-array method
    
    % Ploting the accuracy around the actaul mean across mean values
    subplot(2,2,4)
    bar(right_count_means_average(i,:));
    % Subplot labels
    xlabel('Filter');
    ylabel('Accuracy Rate');
    set(gca,'YLim',[0 1]);
    set(gca,'XTickLabel',meanValues(i,:));
    str = {'','Accuracy Rate Around the Actual Mean Across Mean Values',''}; % cell-array method
    title(str,'FontSize',15,'FontWeight','bold');
    nameStr='Weber and Accuracy Values';
    str = {'',nameStr,''}; % cell-array method
    
    hold off
end


