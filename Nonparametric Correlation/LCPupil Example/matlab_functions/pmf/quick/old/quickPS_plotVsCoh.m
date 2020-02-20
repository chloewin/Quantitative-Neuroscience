function quickPS_plotVsCoh(dat, fit, ax)% function quickPS_plotVsCoh(dat, fit, ax)% check argsif nargin < 1 | isempty(dat)	return;endif nargin < 2  fit = [];endif nargin < 3 | isempty(ax)	ax = axes;else	axes(ax);end% Coherence and Time axescax = 0.001 * ((2).^[0:.5:9])';        % list of coherencestime_bins = [99 175; 175 250; 325 400; 475 555]/1000;%% COLLECT MODEL "DATA"if ~isempty(fit)  % generate list of coh- and time-dependent predictions from the model  pred = nans(length(cax),size(time_bins,1));  for i = 1:size(time_bins,1)	 pred(:,i) = quickPS_val(cax, mean(time_bins(i,:)), fit(1), fit(2), fit(3));  endend%% COLLECT REAL DATA for different times, cohs% matrix of selection arrays for different coherencescvals = unique(dat(:,1));pcor  = nans(length(cvals), size(time_bins,1));for c = 1:length(cvals)  Lc = dat(:,1) == cvals(c);  for t = 1:size(time_bins,1)	 Lt = dat(:,2)>=time_bins(t,1) & dat(:,2)<=time_bins(t,2);	 Ls = Lc & Lt;	 if sum(Ls)		pcor(c,t) = sum(dat(Ls,3))/sum(Ls);	 end  endend%% PLOTco = {'k' 'r' 'g' 'b'};hold on;for i = 1:size(time_bins,1)  hobs(i) = plot(cvals,pcor(:,i),'o', 'MarkerSize', 6, ...					  'MarkerFaceColor',co{i},'MarkerEdgeColor',co{i});  if ~isempty(fit)	 hpred(i) = plot(cax, pred(:,i),'Color',co{i},'LineWidth',2);  endendjigax(ax, 10);set(ax,'XLim',[.010 .512],'XTick',[32 64 128 256 512]/1000,...'XTickLabel',num2str([32 64 128 256 512]' / 10), ...'XScale', 'log');set(ax,'YLim', [0.45 1.0], 'YTick',[.5:.1:1])xlabel('Motion strength (% coh)')ylabel('Performance (% correct)')