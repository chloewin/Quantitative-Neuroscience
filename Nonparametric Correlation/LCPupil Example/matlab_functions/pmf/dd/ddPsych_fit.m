function [fits_,sems_,stats_,preds_,resids_] = ...    ddPsych_fit(data,fun,lapse)%function [fits_,sems_,stats_,preds_,resids_] = ...%    ddPsych_fit(data,fun,lapse)%% DDPSYCH_FIT fits a drift-diffusion-type model to psychometric data --%   as a function of BOTH motion coherence and viewing time -- using%   maximum likelihood maximization. 'fun' is the name or index of%   a supplied function for computing the underlying decision variable%% 	Input values are:%     data, in 5 columns...%		   data(1) = coh  (0 .. 99.9%)%          data(2) = time (fractional seconds)%          data(3) = dot dir: left (-1) / right (1)%          data(4) = pct or correct (1) / error (0)%          data(5) = (optinal) n%     fun        ... index of function. see ddFun%     lapse      ... optional fixed value of lapse parameter%% 	Return values are:%     fits_   ... see ddPsych_val for details%           fits_(1:end-) ... dvar params%           fits_(end)    ... lapse (included even if sent in as fixed arg)%     sems_   ... Standard errors of the fits. Approximated using the%                   numerical HESSIAN returned by fmincon (default)%     stats_  ... [fitLLR Deviance p]%                   fitLLR is the log likelihood of obtaining the %                       data given the fit (returned by quick_err)%                   Deviance is 2(dataLLR - fitLLR)%                   p is probability from chi^2 pdf with df = #blocks-3%     preds_  ... A vector of the probability of making a correct choice given%                   the fit%     resids_ ... col 1: log diff between model and actual outcomes%                 col 2: log diff between model and actual choices (see below)% Created by jig 9/29/05if nargin < 1 || isempty(data)    returnendif nargin < 2 || isempty(fun)    fun = 1;endif nargin < 2    lapse = [];end[alpha, a0, aT] = ddFun(fun);num_as = size(a0, 1);if nargin < 5 || isempty(lapse)    lapse = [];    inits = cat(1, inits, [0.0 0.0 0.5]);else    lsem  = 0;end% if fitting multiple bins, first fit guess% to all short-time data and lapse from all long-time% dataif nargin >= 6 && size(tbins, 1) > 1 && ~aT && ~bT        % keep track of the number of bins we'll fit    num_bins = size(tbins, 1);    % fit guess    if isempty(guess)                [gfits, gsems] = quickTs_fit(data(data(:,2)<=median(data(:,2)), :), ...            alpha_fun, beta_fun, [], lapse);        inits(num_as+num_bs+1, :) = [];        guess = gfits(end-1);        gsem  = gsems(end-1);    end        % fit lapse    if isempty(lapse)                [lfits, lsems] = quickTs_fit(data(data(:,2)>=median(data(:,2)), :), ...            alpha_fun, beta_fun, [], []);                inits(num_as+num_bs+1, :) = [];        lapse = lfits(end);        lsem  = lsems(end);    endelse        % only one "bin" to fit    num_bins = 1;    tbins    = [min(data(:,2)) max(data(:,2))+1];end% fit all datafits_ = [];sems_ = [];for tt = 1:num_bins    [fits_(:, end+1),f,e,o,l,g,H] = fmincon('quickTs_err', ...        inits(:, 1), [], [], [], [], inits(:, 2), inits(:, 3), [], ...        optimset('LargeScale', 'off', 'Display', 'off', 'Diagnostics', 'off'), ...        data(data(:,2)>=tbins(tt,1)&data(:,2)<tbins(tt,2), :), ...        alpha, num_as, aT, beta, num_bs, bT, guess, lapse);    % Standard errors    %   The covariance matrix is the negative of the inverse of the    %   hessian of the natural logarithm of the probability of observing    %   the data set given the optimal parameters.    %   For now, use the numerically-estimated HESSIAN returned by fmincon    %   (which remember is computed from -log likelihood)    % -H because we used -logL in quick_err    sems_(:, end+1) = sqrt(diag(-((-H)^(-1))));end% add guess, lapse values to end of fits_, sems_ matrices if neccessaryif ~isempty(guess) && ~isempty(lapse)    fits_ = cat(1, fits_, repmat([guess; lapse], 1, size(fits_, 2)));    sems_ = cat(1, sems_, repmat([gsem; lsem], 1, size(sems_, 2)));elseif ~isempty(guess)    fits_ = [fits_(1:end-1, :); repmat(guess, 1, size(fits_, 2)); fits_(end, :)];    sems_ = [fits_(1:end-1, :); repmat(gsem, 1, size(sems_, 2)); sems_(end, :)];elseif ~isempty(lapse)    fits_ = cat(1, fits_, repmat(lapse, 1, size(fits_, 2)));    sems_ = cat(1, sems_, repmat(lsem, 1, size(sems_, 2)));end% return statsif nargout > 2        % log likelihood of the fits ("M1" in Watson)    % is just the negative of the error function    % Use only first fit    M1 = -quickTs_err(fits_(:, 1), data, alpha, num_as, aT, ...        beta, num_bs, bT);        % deviance is 2(M0 - M1), where    % M0 is the log likelihood of the data ("saturated model") --    %   which in this case is, of course, ZERO    dev = -2*M1;        % probability is from cdf    p = 1 - chi2cdf(dev, size(data, 1) - ...        size(fits_, 1) - ~isempty(guess) - ~isempty(lapse));        stats_ = [M1 dev p];end% return the predicted probability (of a correct response) for each observation% again using only first fitif nargout > 3        preds_ = quickTs_val(data(:, 1:end-1), alpha, fits_(1:num_as, 1), ...        aT, beta, fits_(num_as+1:num_as+num_bs, 1), bT, ...        fits_(end-1, 1), fits_(end, 1));end% return the deviance residuals ... these are the square roots%   of each deviance computed individually, signed according to%   the direction of the arithmatic residual y_i - p_i.% See Wichmann & Hill, 2001, "The psychometric function: I. Fitting,%   sampling, and goodness of fitif nargout > 4    % resids on correct/error    cepreds = preds_;    cepreds(data(:, 4) == 0) = 1 - cepreds(data(:, 4) == 0);    cepreds(cepreds==0) = 0.0001;    cepreds(cepreds==1) = 1 - 0.0001;        % choice resids are a little trickier - we have to     %   make predictions based on choice    lrpreds = preds_;    lrpreds(data(:, 3) == -1) = 1 - lrpreds(data(:, 3) == -1);    lrpreds(cepreds==0) = 0.0001;    lrpreds(cepreds==1) = 1 - 0.0001;    choices = data(:, 3);    choices(data(:, 4) == 0) = -choices(data(:, 4) == 0);        % first column is c/e resids    % second column is l/r resids    resids_ = [ ...        (data(:, 4).*2-1) .* sqrt(-2.*log(cepreds)), ...        choices .* sqrt(-2.*log(lrpreds))];    end