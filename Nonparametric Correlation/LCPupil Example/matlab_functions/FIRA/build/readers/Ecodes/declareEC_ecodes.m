% script declareEC_ecodes

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global EC

if isempty(EC)

    EC = struct( ...
        'EYINWD',       1006,   ...
        'SACMAD',       1007,   ...
        'FPONCD',       1010,   ...
        'FPONBLINKCD',	1012,   ...
        'FPOFFCD',      1025,   ...
        'ELESTM',       1059,   ...
        'STOFFCD',      1101,   ...
        'TARGONCD',     3000,   ...
        'TARGC1CD',     3001,   ...
        'TARGC2CD',     3002,   ...
        'ALLOFFCD',     4904,   ...
        'CORRECTCD',    4905,   ...
        'WRONGCD',      4906,   ...
        'NOCHCD',       4907,   ...
        'FIX1CD',       4913,   ...
        'GOCOHCD',      4901,   ...
        'I_FIXXCD',     8001,   ...
        'I_FIXYCD',     8002,   ...
        'I_TRG1XCD',    8008,   ...
        'I_TRG1YCD',    8009,   ...
        'I_TRG2XCD',    8012,   ...
        'I_DOTDIRCD',   8010,   ...
        'I_COHCD',      8011,   ...
        'I_TRG2YCD',    8013,   ...
        'I_TRIALIDCD',  8017   ...
        );
end