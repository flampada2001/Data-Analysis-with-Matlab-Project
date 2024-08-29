clc
close all
clear

data=xlsread("SeoulBike.xlsx");

bikes=data(:,1);          % Bike counts

% The names of most of the possible distributions are saved
distributions={'birnbaumsaunders' ,'normal', 'exponential', 'gamma', 'lognormal','logistic','poisson','extremevalue','generalizedextremevalue','generalizedpareto', 'halfnormal','inversegaussian','kernel','loglogistic', 'nakagami','negativebinomial'  ,'rayleigh' ,'rician' ,'tlocationscale' ,'weibull'};

% In this cell we save the data fitdist will return to us for each
% fitted distribution for every season
fitted_distributions=cell(length(distributions));

% For every season
for s=1:4

    % We print the seasonn we are working on
    fprintf("<strong>The distribution of Season:%d is worked on:</strong>\n\n",s)
    
    % We find the indeces where season=s and thus we peak the data
    % concerning that season
    s_1_index=find(data(:,11)==s);
    bikes_s=bikes(s_1_index);

    % We create the histogram of the distribution of season s
    subplot(2,2,s)
    histogram(bikes_s, Normalization="pdf")
    hold on
    grid on
    title(sprintf("Histogram of number of bikes rented from season %d (in pdf units)",s))
    xlabel("Number of bikes rented")
    ylabel("Count of bike count in PDF units")


    % The minimum X^2 and  best p-value are initialised
    ch2_min=inf;
    p_val_best=0;

    % for every distribution in distributions
    for i=1:length(distributions)
        % Fit distributions{i} to our data and save the result (parameters
        % of each distributions and so on) on fitted_distributions{i}
        fitted_distributions{i}=fitdist(bikes_s,distributions{i});
    end

    % For every fitted distribution
    for i=1:length(fitted_distributions)
        
        % Do the X^2 goodness of fit test and save p
        [h,p,stats]=chi2gof(bikes_s,'CDF',fitted_distributions{i});
        
        % If the new X^2 is smaller than the smallest X^2 until now then
        % the fit is better
        if ch2_min>stats.chi2stat
            ch2_min=stats.chi2stat;
            p_val_best=p;
            %Thus the best distribution for this season is distributions{i}
            best_distribution=distributions{i};
            best_fitted_distribution=fitted_distributions{i};
        end

        % We print X^2 and the p-value for every test
        fprintf('Testing distribution: %s\n',distributions{i});
        fprintf('Chi-squared statistic value %f\n',stats.chi2stat);
        fprintf('P-value: %f\n',p);
        fprintf('----------------------\n');
    end
    
    % Plot the best fitted distribution

    % 1000 points taken between the minimum and maximum of the bike count
    % for season s
    bike_values =linspace(min(bikes_s),max(bikes_s),1000);
    
    % The number of measurments in season s
    n=length(bikes_s);
    % The values of the pdf calculated at bike_values
    pdf_values=pdf(best_fitted_distribution, bike_values);
    plot(bike_values,pdf_values,'LineWidth',1.5);
    legend("Number of bikes rented",sprintf("Best distribution:"+best_distribution+" with X^2=%.3f and p=%.3f",ch2_min,p_val_best))    
    hold off

    % In the end we print the best distribution, its X^2 and p-value
    fprintf("<strong>The best distribution for Season: %d is %s with a p-value of %f\nand a chi^2 value %f</strong>\n\n",s,best_distribution,p_val_best,ch2_min)

end

%We see that on all 4 seasons the number of bikes per hour seem to follow a
%kernel type distribution, with varying precision. We see that the kernel
%distribution fits better on season 1, then on season 2 then on season 3 
% and so on (The smaller X^2 and the larger the p-value is, the better the
% fit)