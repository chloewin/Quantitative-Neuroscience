function modes_ = nanmode(in)% function modes_ = nanmode(in)%% gets the modes of a column vector, ignoring nans% returns:%   modes_ ... sorted list of unique values, in decending frequency% written by jigif isempty(in)        modes_ = [];    returnend% find the unique valuesin = in(:);[d,c] = munique(in(~isnan(in)));[y,i] = sort(c);modes_ = d(flipdim(i,1));