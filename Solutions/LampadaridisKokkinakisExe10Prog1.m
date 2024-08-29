clc
clear
close all

data=xlsread("SeoulBike.xlsx");

bikes=data(:,1);          % Bike counts

seasons=data(:,11);       % Seasons
holidays=data(:,12);      % Holidays


holiday=0;                % holiday=0 (no holiday)

window_length=960;        % The length of the window we will study

% Define noise confidence intervals for autocorrelation analysis
noise_lower=-2/sqrt(window_length);
noise_higher=2/sqrt(window_length);

% Iterate over the four seasons
for season=1:4

    bike_data=bikes(seasons==season);  % bike data for the current season
    holiday_data=holidays(seasons==season); % holiday data for the current season

    % Find the indices where holidays occur
    holiday_indices=find(holiday_data~=holiday);

    % Calculate the differences between consecutive holiday indices
    holiday_indices_difference=zeros(length(holiday_indices)-1,1);
    for i=1:length(holiday_indices)-1
        holiday_indices_difference(i)=holiday_indices(i+1)-holiday_indices(i);
    end

    % Find the maximum difference between consecutive holiday indices
    max_holiday_difference=max(holiday_indices_difference);

    % Determine the analysis window based on holiday indices and window length
    % If the first window of the bike data is long enough then we use that
    % by using the first 960 values of the season
    if holiday_indices_difference(1)>window_length %If the first window of
        window_start=1;
        window_end=holiday_indices(1)-1;

    % If not then we see if the longest window in our data is long enough 
    % and if it is we take the first 960 
    elseif max_holiday_difference>window_length
        %The place where the max difference happens
        max_difference_index=find(holiday_indices_difference==max_holiday_difference);
        % The window starts from the 1st element and it ends at the 960th 
        % elementof the largest non holiday window
        window_start=holiday_indices(max_difference_index)+1;
        window_end=window_start+window_length-1;
    end

    % Select data within the determined analysis window
    bikes_window=bike_data(window_start:window_end);

    figure()
    % Plot the initial bike renting history diagram
    subplot(2,2,1)
    plot(bikes_window,'.-')
    hold on
    xlabel("Hours")
    ylabel("Number of bikes rented")
    grid on
    title(sprintf("Initial bike renting timeseries (elements from %d to %d) for Season %d", window_start, window_end, season))
    legend("Initial bike renting timeseries", "Location", "best")
    hold off

    % Calculate and plot autocorrelation function of the bike renting 
    % timeseries before removing the circular aspect so we can get an idea
    % of the periodicity of our data
    [acf, lags]=autocorr(bikes_window, NumLags=100);
    subplot(2,2,2)
    stem(lags,acf,"LineWidth", 2)
    hold on
    grid("on")
    xlabel("Lag n")
    ylabel("Autocorrelation r_n before the circular aspect is removed")
    yline(noise_higher,"r--","LineWidth",2) % Plot upper noise confidence
    % limit

    yline(noise_lower,"r--","LineWidth", 2) % Plot lower noise confidence
    % limit

    legend("Autocorrelation function r_n", "95% noise confidence area limits")
    title(sprintf("Autocorrelation function r_n before removing the circular aspect for Season %d", season))
    hold off
    % Calculate and remove the periodic component from the bike renting
    % timeseries
    season_period=24;
    bikes_circle=zeros(window_length, 1);
    for i=1:season_period
        bikes_circle(i:season_period:end)=mean(bikes_window(i:season_period:end));
    end
    bikes_window_no_period=bikes_window-bikes_circle;

    % Plot the bike renting timeseries after removing the periodic aspect
    subplot(2,2,3)
    plot(bikes_window_no_period,'.-')
    hold on
    xlabel("Hours")
    ylabel("Number of bikes rented")
    grid on
    title(sprintf("Bike renting timeseries after removing the periodic aspect (elements from %d to %d) for Season %d", window_start, window_end, season))
    legend("Bike renting timeseries after removing the periodic aspect", "Location", "best")
    hold off


    % Calculate and plot autocorrelation function of the bike renting 
    % timeseries after removing the circular aspect
    [acf_no_period, lags_no_period]=autocorr(bikes_window_no_period, NumLags = 60);
    subplot(2,2,4)
    stem(lags_no_period,acf_no_period,"LineWidth", 2)
    hold on
    grid("on")
    xlabel("Lag n")
    ylabel("Autocorrelation r_n when the circular aspect is removed")
    yline(noise_higher, "r--","LineWidth",2) % Plot upper noise confidence limit
    yline(noise_lower,"r--","LineWidth",2) % Plot lower noise confidence limit
    legend("Autocorrelation function r_n", "95% noise confidence area limits")
    title(sprintf("Autocorrelation function r_n after removing the circular aspect for Season %d", season))
    hold off

end

% Firstly, to identify the period of the data of each season, we create
% the autocorrelation plot of the original history diagram. What we found
% is that the data of all 4 sesons seem to be subject to a periodocity of
% period 24 hours (1 day), which is to be expected. Thus the period we
% choose is 24 for the circular phenomenon is 24 hours.

% By the plot of the autocorrection aster the removal we see that for 
% seasons 1 2 and 3 the seasonality of our data seems to be removed since
% the autocorrection is always positive (we still see some oscilation, 
% showing us that there could be some more periodic phenomenons). We also 
% see that as the lag increases so does the autocorrection's amplitude, a 
% telltale sign of a tendancy excisting in our data. 
% This means that for season 1 2 and 3 the autocorrection seems to be 
% significant.

% Season 4 is intresting because we see that despite us trying to eliminate
% the 24 hour period it persists, since the plot of the autocorrection is
% stil periodic with a period of 24 hours. This means that we are unable to
% remove the sesonality of season 4 with our usual ways.