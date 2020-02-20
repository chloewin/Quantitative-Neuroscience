function qdat_ = quick_formatData(dat)%% converts trial-based data to a matrix% used by quick_fit%% input: %  dat  ... [coh correct] x trials% % returns:%  qdat ... [cohs pct_correct num_trials] x cohs%cbins  = unique(dat(dat(:,1)~=0,1));qdat_  = nans(length(cbins), 3);for cc = 1:length(cbins)  Lc = dat(:,1) == cbins(cc);  qdat_(cc,:) = [cbins(cc) sum(dat(Lc,2))/sum(Lc) sum(Lc)];end