function nears_ = nearest(data, categories)% nears_ = nearest(data, categories)% % returns array of values from "categories" that are% nearest to the given data% categories is 1xN% data is Mx1categories = categories(:)';data       = data(:);Lnan       = isnan(data);a = repmat(categories, length(data), 1);b = repmat(data, 1, length(categories));[y,I]        = min(abs(a-b),[],2);nears_       = categories(I)';nears_(Lnan) = nan;