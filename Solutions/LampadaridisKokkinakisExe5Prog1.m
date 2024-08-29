clear
clc
close all

a=0.05;

data=xlsread("SeoulBike.xlsx");

bikes=data(:,1);          % Bikes
hours=data(:,2);          % Hours
seasons=data(:,11);       % Seasons
temperatures=data(:,3);   % Bikes

% The arrays that will hold the significant and non significant correlation
% coefficients for each seson and each hour. They are normalised as NaN so
% if a certain spot isn't filled it won't show on the plots
significant=NaN(4,24);
non_significant=NaN(4,24);

% For each season
for season=1:4
    for hour=0:23 % For each hour of the day
    
    % The bike count and temperature data for the current hour and season
    % are extracted
    bike_data=bikes(seasons==season & hours==hour);
    temp_data=temperatures(seasons==season & hours==hour);
    
    % The number of bike and temperature data during this seson and hour
    n=length(temp_data);
    
    % The correlation coefficient between the bike and temperature data of
    % this season and hour is calculated
    rho=corr(temp_data,bike_data);

    %t statistical for our data, our hypothesis is that rho=0 
    % (n and rho are used)
    t_stat=rho.*sqrt((n-2)./(1-rho.^2));

    % We take the absolute value since we are performing a one way check and
    % then we multiply by 2. That's why we use the tcdf
    prob_until_second_cross=tcdf(abs(t_stat),n-2);

    
    % The p-value is calculated. The p-value of the parametic check is the
    % probability until a/2 (1-prob_until_second_cross) times two. This
    % p-value is the p-value for the test with the null hypothesis that
    % rho=0!!
    p_value=2*(1-prob_until_second_cross);
    
    % If the p-value is greater than the significance level
    if p_value>a
        % Then the correlation coefficient for this season isn't significant
        % and it's saved in the proper list
        non_significant(season,hour+1)=rho;
    else
        % Then the correlation coefficient for this season is significant
        % and it's saved in the proper list
        significant(season,hour+1)=rho;
    end


    end

end

% A list containing every hour of the day is generated
hour_space=0:23;

% Season 1 plot
figure()
subplot(2,2,1)
scatter(hour_space,significant(1,:))% The plot of the significant rhos for each hour
hold on
grid on
scatter(hour_space,non_significant(1,:))% The plot of the non-significant rhos for each hour
xlabel("Time of day (24h format)")
ylabel("Correlation coefficient \rho")
legend("Significant correlation", ...
    "Non-significan correlation",'Location','best')
title("Season's 1 correlation coefficiant as a function of time.")
hold off

% Season 2 plot
subplot(2,2,2)
scatter(hour_space,significant(2,:))% The plot of the significant rhos for each hour
hold on
grid on
scatter(hour_space,non_significant(2,:))% The plot of the non-significant rhos for each hour
xlabel("Time of day (24h format)")
ylabel("Correlation coefficient \rho")
legend("Significant correlation", ...
    "Non-significan correlation",'Location','best')
title("Season's 2 correlation coefficiant as a function of time.")
hold off

% Season 3 plot
subplot(2,2,3)
scatter(hour_space,significant(3,:))% The plot of the significant rhos for each hour
hold on
grid on
scatter(hour_space,non_significant(3,:))% The plot of the non-significant rhos for each hour
xlabel("Time of day (24h format)")
ylabel("Correlation coefficient \rho")
legend("Significant correlation", ...
    "Non-significan correlation",'Location','best')
title("Season's 3 correlation coefficiant as a function of time.")
hold off

% Season 4 plot
subplot(2,2,4)
scatter(hour_space,significant(4,:))% The plot of the significant rhos for each hour
hold on
grid on
scatter(hour_space,non_significant(4,:))% The plot of the non-significant rhos for each hour
xlabel("Time of day (24h format)")
ylabel("Correlation coefficient \rho")
legend("Significant correlation", ...
    "Non-significan correlation",'Location','best')
title("Season's 4 correlation coefficiant as a function of time.")
hold off

% In general season 3 (summer) seems to be the odd one out since it's the
% only one with a negative significant correlation coefficiant between hours
% 10 to 16, meaning that as the temperature increases people tend to rent
% less bikes. The other hours during the summer seam to have an
% insignificant correlation betwewen temperature and the number of bikes
% rented

% During all the other seasons we see that the corralation coefficiant is
% always positive. We see the highest peacks in season 1 from 12 to hour 17
% then there's a dropoff at 18 followed by a slow increse untill hour 23. In
% seasons 2 and 4 we see the largest correlation coefficiants between hours
% 10 to 23 with both peacks being at hour 17. We  conclude that there is 
% some overlap in these three seasons (1,2 and 4) with season 2 and season
% 4 being the more similar.
