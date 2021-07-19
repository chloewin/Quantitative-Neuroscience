function [fits_,sems_,stats_,preds_,resids_] = ...    quickLG_fit(data)%% QUICKLG_FIT fits a weibull function to psychometric data using%   maximum likelihood maximization under binomial assumptions. It uses%   quick_err for error calculation. The three parameters returned in%   fits_ are alpha (threshold), beta (slope/shape term) and lapse (the%   lapse rate). Assumes a guess rate (gamma) of 0.5, as in a 2AFC task.%% Usage: [fits_,sems_,stats_,preds_,resids_] = ...%           quick_fit(data, error_flag)%% Arguments:%  data       ... in 3 columns...%                   data(1) = x%                   data(2) = fraction correct (0..1)%                   data(3) = number of observations%% Returns:%  fits_      ... [alpha; beta; lapse; guess]%                   alpha is threshold%                   beta is the slope/shape term%                   lapse is the lapse rate%                   guess is guess rate%  sems_      ... Standard errors of the fits. Approximated using the%                   numerical HESSIAN returned by fmincon (default)%                   or monte carlo method (if error_flag is given)%  stats_     ... [fitLLR Deviance p]%                   fitLLR is the log likelihood of obtaining the %                       data given the fit (returned by quick_err)%                   Deviance is 2(dataLLR - fitLLR)%                   p is probability from chi^2 pdf with df = #blocks-3%  preds_     ... A vector of the probability of making a correct %                   choice given the fit%  resids_    ... Residual deviance% 	4/1/95 to use optimization toolbox, contsrained fit -- nope%  		old code is quickfit_no_opt.m% 	12/11/96  jdr & mns fixed guessing bug (we hope) %	7/13/01 jig updated, cleaned up and changed fmins to fmincon%   9/8/05 updated by jig to include statsif nargin < 1 || isempty(data)    return;endif nargin < 2    lapse = [];end% use linear interpolation to guess alpha% next line takes x and %-cor columns, flips them and interpolates along% x to find the value corresponding to .8 correct.  The interpolation% requires monotonic %-cor column, so we sort the matrix 1st.% Remember, it's just a guess.gpct    = 0.82;row_lo = max(find(data(:,2)<=gpct));if isempty(row_lo)              % no percent correct > gpct    a_guess = min(data(1,2));elseif row_lo == size(data,1)   % no percent correct < gpct    a_guess = max(data(end,2));else                            % interpolate    row_hi = row_lo + 1;    a_guess = data(row_lo,1) + (data(row_hi,1) - data(row_lo,1)) * ...        (gpct - data(row_lo,2)) / (data(row_hi,2) - data(row_lo,2));end%% do the fit[fits_,f,e,o,l,g,H] = fmincon('quickLG_err', ...    [a_guess 1    1-max(data(:,2))  0.5]', [], [], [], [], ...    [0.001   0.01 0                 0.1]', ...    [1000    50   0.5               0.9]', ...    [], optimset('LargeScale', 'off', ...    'Display', 'off', 'Diagnostics', 'off'), data);   % standard errors% The covariance matrix is the negative of the inverse of the % hessian of the natural logarithm of the probability of observing % the data set given the optimal parameters.% For now, use the numerically-estimated HESSIAN returned by fmincon% (which remember is computed from -log likelihood)if nargout > 1        % error_type is flag .. if not given (default), use Hessian    if nargin < 3 || isempty(error_flag)        % -H because we used -logL in quick_err        sems_ = sqrt(diag(-((-H)^(-1))));                if ~isempty(lapse)            sems_ = [sems_; 0];        end            else        % try getting monte-carlo simulated errors        num_sets = 50;        mcfits   = zeros(num_sets, length(fits_));        dat      = data;        for i = 1:num_sets            data(:,2)   = binornd(dat(:,3),dat(:,2))./dat(:,3);            mcfits(i,:) = quick_fit(data, lapse)';        end                %   means = mean(mcfits)        sems_  = [fits_ - prctile(mcfits,16)' prctile(mcfits,84)' - fits_];    endend% return statsif nargout > 2        % log likelihood of the fits ("M1" in Watson)    % is just the negative of the error function    M1 = -quick_err(fits_, data);        % deviance is 2(M0 - M1), where    % M0 is the log likelihood of the data ("saturated model")    ys = data(:, 2);    % avoid log(0)    ys(ys==0) = 0.0001;    ys(ys==1) = 1 - 0.0001;    M0 = sum(data(:, 3).*(ys.*log(ys)+(1-ys).*log(1-ys)));    dev = 2*(M0-M1);        % probability is from cdf    if isempty(lapse)        p = 1 - chi2cdf(dev, size(data, 1) - 3);    else        p = 1 - chi2cdf(dev, size(data, 1) - 2);    end        stats_ = [M1 dev p];end% return the predicted probability (of a correct response) for each observationif nargout > 3    preds_ = quick_val(data(:,1), fits_(1), fits_(2), fits_(3));end% return the deviance residuals ... these are the square roots%   of each deviance computed individually, signed according to%   the direction of the arithmatic residual y_i - p_i.% See Wichmann & Hill, 2001, "The psychometric function: I. Fitting,%   sampling, and goodness of fitif nargout > 4    % avoid log(0)    ys = data(:,2);    ys(ys==0) = 0.0001;    ys(ys==1) = 1 - 0.0001;    resids_ = sign(ys - preds_) .* sqrt(2.*data(:,3).* ...        (ys.*log(ys./preds_) + (1-ys).*log((1-ys)./(1-preds_))));end