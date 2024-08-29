
clear
clc
close all

data = xlsread("SeoulBike.xlsx");

% Setting significance level and number of data our bootsrap sample will have
a = 0.05;
M = 1000;


bikes=data(:,1);          % Bikes
holiday=data(:,12);       % Holiday

% The bike data is saparated based on holiday status
bikes_no_holiday=bikes(holiday==0);
bikes_holiday=bikes(holiday==1);

% The medians for holiday and non-holiday data are computed
m1=median(bikes_holiday);
m0=median(bikes_no_holiday);

% Hours and seasons are extracted
hours=data(:,2);
seasons=data(:,11);

% Separating hours and seasons based on holiday status
hours_no_holiday=hours(holiday==0);
hours_holiday=hours(holiday==1);
seasons_no_holiday=seasons(holiday==0);
seasons_holiday=seasons(holiday==1);

% A random season is selected CHANGE THIS IF YOU WANT TO VIEW A SPECIFIC
% SEASON
season=randi(4);

% The arrays for holiday season's upper and lower of confidence area limits
% of the median for each hour of the day are normalised
median_holiday_upper=zeros(24,1);
median_holiday_lower=zeros(24,1);

% The indices for confidence areas of the bootsrap method are calculated
low_index=round(M*a/2);
high_index=round(M*(1-a/2));

% For each hour of the day (holiday season)
for hour=0:23
    % The data for the current hour and season when we are in a
    % holiday period are extracted
    bikes_holiday_hour_data=bikes_holiday(hour==hours_holiday & season==seasons_holiday);
    n=length(bikes_holiday_hour_data);
    
    % The array that will hold the median for each bootsrap
    % sample is normalised
    median_holiday=zeros(M,1);
    
    % For each bootsrap sample
    for i=1:M
        % An array of n random values from 1 to n. It holds the indeces for
        % the data needed to berform the bootsrap method
        rand_index=unidrnd(n,n,1);
        % The bootsrap sample is generated
        bikes_holiday_hour_data_rand=bikes_holiday_hour_data(rand_index);
        % The median of this sample is calculated and saved in the right
        % array
        median_holiday(i)=median(bikes_holiday_hour_data_rand);
    end
    
    % Medians are sorted and the upper and lower confidence limits are saved
    median_holiday_sorted=sort(median_holiday);
    median_holiday_upper(hour+1)=median_holiday_sorted(high_index);
    median_holiday_lower(hour+1)=median_holiday_sorted(low_index);
end

% The arrays for non-holiday upper and lower of confidence area limits of
% the median for each hour of the day are normalised
median_no_holiday_upper=zeros(24,1);
median_no_holiday_lower=zeros(24,1);

% For each hour of the day (no holiday seson)
for hour=0:23
    % The data for the current hour and season is extracted when we are not
    % in a holiday period
    bikes_no_holiday_hour_data = bikes_no_holiday(hour==hours_no_holiday & season==seasons_no_holiday);
    n = length(bikes_no_holiday_hour_data);

    % The array that will hold the median for each bootsrap
    % sample is normalised
    median_no_holiday=zeros(M,1);
    
    % For each bootsrap sample
    for i=1:M
        % An array of n random values from 1 to n. It holds the indeces for
        % the data needed to perform the bootsrap method
        rand_index=unidrnd(n,n,1);

        % The bootsrap sample is generated
        bikes_no_holiday_hour_data_rand=bikes_no_holiday_hour_data(rand_index);
        % The median of this sample is calculated and saved in the right
        % array
        median_no_holiday(i)=median(bikes_no_holiday_hour_data_rand);
    end
    
    % Medians are sorted and the upper and lower confidence limits are saved
    % for each hour of the day
    median_no_holiday_sorted=sort(median_no_holiday);
    median_no_holiday_upper(hour+1)=median_no_holiday_sorted(high_index);
    median_no_holiday_lower(hour+1)=median_no_holiday_sorted(low_index);
end

% An array for every hour of the day is generated
hours_space=linspace(0,23,24);

% Plotting holiday data
subplot(2,1,1)
scatter(hours_space,median_holiday_lower) % The lower limit of the confidence area
hold on
scatter(hours_space,median_holiday_upper) % The upper limit of the confidence area
grid on
yline(m1,'--r','LineWidth',2) % The median of all the holiday data
title(sprintf("The %.2f area of confidence for the median of the bikes as a function of the time in season %d in the holiday season",(1-a)*100,season))
xlabel("Time of day (24 hour format)")
ylabel(sprintf("Bikes rented in season %d",season))
legend(sprintf("The lower limit of the %.2f%% median's confidence area",(1-a)*100),...
    sprintf("The upper limit of the %.2f%% median's confidence area",(1-a)*100),...
    sprintf("The median of bikes rented when we are in a holiday season m_1=%.2f",m1),'Location','best')
hold off

% Plotting non-holiday data
subplot(2,1,2)
scatter(hours_space, median_no_holiday_lower) % The lower limit of the confidence area
hold on
scatter(hours_space, median_no_holiday_upper) % The upper limit of the confidence area
grid on
yline(m0,'--r','LineWidth',2)
title(sprintf("The %.2f area of confidence for the median of the bikes as a function of the time in season %d outside of the holiday season",(1-a)*100,season))
xlabel("Time of day (24  hour format)")
ylabel(sprintf("Bikes rented in season %d",season))
legend(sprintf("The lower limit of the %.2f%% median's confidence area",(1-a)*100),...
    sprintf("The upper limit of the %.2f%% median's confidence area",(1-a)*100),...
    sprintf("The median of bikes rented when we are not in a holiday season m_0=%.2f",m0),"Location","best")
hold off

% Comments regarding observed patterns in the data
% In season 1, the 95% confidence area is below the mean of
% all the data in both cases, excluding hours 13 to 17 of the holiday case.
% There's a small increase in median values from 8 to 15 in the holiday season,
% followed by a slow decrease until hour 19.

% Season 2 follows a similar pattern as Season 1. However, in the holiday season,
% the 95% confidence area mostly includes the median (m1), indicating less
% variability compared to the non-holiday season.

% Season 3 shows that in the holiday season, most hours' confidence levels are above
% the median (m1), except for hour 5. In the non-holiday season, the confidence levels
% are mostly above the median (m0), except for hours 2 to 5 and hour 6.

% Season 4 exhibits similar behavior to Season 3, with most hours' confidence levels
% in the holiday season above the median (m1), except for hours 3, 4, 6, and 7. In
% the non-holiday season, most confidence levels are above the median (m0), except
% for hours 2 to 6 and hour 1.

% Overall, it's observed that the confidence levels during holidays are wider
% due to smaller sample sizes compared to non-holiday seasons. This leads to
% increased uncertainty and wider confidence intervals.
