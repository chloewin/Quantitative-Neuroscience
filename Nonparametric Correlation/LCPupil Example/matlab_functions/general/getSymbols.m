function [symnames,symbols] = getSymbols% [symnames,symbols] = getSymbols%	function to return cell arrays with lists of symbol names and their%	corresponding plot symbol codes% RCS info: $Id$%% jpg - 6/2/98symarray = {...	'point',	'.';...	'circle',	'o';...	'cross',	'x';...	'plus sign',	'+';...	'asterisk',	'*';...	'square',	'a';...	'diamond',	'd';...	'triangle up',	'^';...	'triangle down','v';...	'triangle left','<';...	'triangle right','>';...	'pentagram',	'p';...	'hexagram',	'h'};symnames = symarray(:,1);symbols = symarray(:,2);	