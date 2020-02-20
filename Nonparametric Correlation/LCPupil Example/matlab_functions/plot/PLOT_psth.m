function [xs_, ys_] = PLOT_psth(spikeC, wrt, begins, ends, bin_size, ax)%function [xs_, ys_] = PLOT_psth(spikeC, wrt, begins, ends, bin_size, ax)%% plots a PSTH from a bunch of rasters% % arguments:%  spikeC   ... Cell array of raster data (rows are trials)%                   {[times1 x n1]; [times2 x n2]; ... [timesn x nn]}%  wrt      ... (trials x 1) array of times to plot with respect to (time == 0)%  begins   ... (trials x 1) array of times to start showing%  ends     ... (trials x 1) array of times to end showing%  bin_size ... scalar (in ms)%  ax       ... axis to plot on% check argsif nargin < 1	return;end% if no wrt array, plot wrt time 0 (which should be fpon)if nargin < 2 || isempty(wrt)	wrt = zeros(length(spikeC), 1);elseif isscalar(wrt)    wrt = wrt*ones(length(spikeC),1);end% begins, ends can be emptyif nargin < 3 || isempty(begins)	begins = -10000*ones(length(spikeC), 1);elseif isscalar(begins)	begins = begins*ones(length(spikeC), 1);    endif nargin < 4 || isempty(ends)	ends =  10000*ones(length(spikeC), 1);elseif isscalar(ends)	ends = ends*ones(length(spikeC), 1);    end% bin_size is a scalarif nargin < 5 || isempty(bin_size)	bin_size = 1;endbin_size = round(bin_size); % make sure it's an integerif nargin < 6 	ax = axes;end% make the arraysmaxa    = max(ends   - wrt);mina    = min(begins - wrt);wrt_new = wrt + mina - 1;      % everything wrt relative index of min valuecbegins = begins - wrt_new;cends   = ends   - wrt_new;Plen    = maxa   - mina + 1;Slen    = length(spikeC);% loop through each trial, counting spikes & binscounts  = zeros(Plen, Slen, 2);for ii = 1:Slen	x = spikeC{ii};	x = x(x>=begins(ii) & x<=ends(ii)) - wrt_new(ii);	if ~isempty(x)		counts(round(x), ii, 1) = 1;	end	counts(cbegins(ii):cends(ii), ii, 2) = 1;end% these are in 1 ms incrementsxs = (mina:maxa)';						% normalize by number of trials in each bin, convert to spikes/secys = (1000/bin_size)*(sum(counts(:,:,1), 2)./sum(counts(:,:,2), 2));% group by bin_sizenum_bins = floor(length(ys)/bin_size);rmat     = zeros(bin_size, num_bins);rmat(:)  = cumsum(ones(bin_size*num_bins,1));xbins    = xs(rmat(round(bin_size/2), :));ybins    = sum(ys(rmat), 1)';% plotif ~isempty(ax)    axes(ax);    hold on;    if ~isempty(xbins) && ~isempty(ybins)        plot(xbins, ybins, 'k-');        % bar(xbins, ybins, 'k');        plot([0 0], [min(ybins) max(ybins)], 'k--');        % limits_ is [xmin xmax ymin ymax]        limits = [min(xbins) max(xbins) 0 max(ybins)];    else        limits = [0 0 0 0];    end    jigax(gca, 12);    %xlabel('Time (ms)');    %ylabel('Spikes/Sec/trial');endif nargout == 2    xs_ = xbins;    ys_ = ybins;end