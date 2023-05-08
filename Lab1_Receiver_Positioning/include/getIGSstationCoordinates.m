function r_c=getIGSstationCoordinates(stationName)

switch(stationName)
  case 'algo'
    r_c = [918129.4000 -4346071.2000  4561977.8000]';
  case 'hour'
    r_c = [4186737.654    834900.165   4723624.127]';
%    r_c = [3718453.601    863438.894   5092633.433]';
  case 'hlfx'
    r_c = [2018905.8000 -4069070.5200  4462415.4100]';
  case 'lckS'
    r_c = [2261359.445    841464.338   5884828.523]';
  case 'lctS'
    r_c = [4627533.566    119143.900   4373345.611]';
  case 'lcnS'
    r_c = [3718453.601    863438.894   5092633.433]';
  case 'N_EGGD0130'
    r_c = [4186737.654    834900.165   4723624.127]';
  case 'evnobe'
    r_c = [4186737.654    834900.165   4723624.127]';
  case 'lcoS'
    r_c = [4186737.654    834900.165   4723624.127]';
  case 'ffmj'
    r_c = [4053456.1550   617729.4350  4869395.4750]';
  case 'kiru'
    r_c = [2251420.9328   862817.1406  5885476.6048]'; %kiru
  case 'gope'
    r_c = [3979316.4450  1050312.2550  4857066.9060]';
  case 'graz'
    r_c = [4194424.1280  1162702.4540  4647245.1980]';
  case 'ieng'
    r_c = [4476537.4104   600431.3929  4488761.1633]'; %ieng
  case 'mad2'
    r_c = [4849202.3989  -360328.9943  4114913.1884]'; %mad2
  case 'madr'
    r_c = [4849202.3940  -360328.9929  4114913.1862]'; %madr
  case 'mate'
    r_c = [4641952.5415  1393047.4758  4133289.0685]';
  case 'mobn'
    r_c = [2936432.1400  2178364.5000  5208858.1800]';
  case 'tlse'
    %r_c = [4627854.3231   119667.7959   4372995.7087]';%tlse from rinex header
    r_c = [4627854.4338   119640.1544  4372997.288]';%tlse from nasa tlse webpage
  case 'obe2'
    r_c = [4186558.3625   835027.4144  4723759.4465]'; %obe2 2005
    %r_c = [4186575.0000   835012.0000  4723760.0000]';%2003
    %r_c = [4186561.2322   835028.8346  4723758.3112]';
    %r_c=[4186575 835012 4723760]';
  case 'onsa'
    r_c = [3370658.8318   711876.9387  5349786.7450]';
  case 'ohi2'
    r_c = [1525809.7478 -2432478.7092 -5676166.6599]';
  case 'hert'
    r_c = [4033461.0385  23537.6625    4924318.1645]'; %hert
  case 'sulp'
    r_c = [3765296.5894  1677559.7419  4851297.5022]'; %sulp   
  case 'pots'
    r_c = [3800689.6333   882077.3949  5028791.3131]'; %pots
  case 'ptbb'
    r_c = [3844060.0000   709661.2701  5023129.5100]';
  case 'joze'
    r_c = [3664938.4340  1409153.9645  5009572.3074]';   %joze
  case 'not1'
    r_c = [4934547.5095  1321262.8224  3806459.1951]'; %not1
  case 'usno'
    r_c = [1112189.9031 -4842955.0319  3985352.2376]'; %usno
  case 'usn3'
    r_c = [1112162.2251 -4842853.6241  3985496.0746]'; %usn3
  case 'will'
    r_c = [-2084258.0160 -3313872.9800  5019853.0810]';
  case 'wtzr'
    r_c = [4075579.0457   931853.6826  4801568.1643]';
  case 'wtzz'
    r_c = [4075576.1952   931853.5654  4801567.1781]';
  case 'yebe'
    r_c = [4848724.8929  -261632.4814  4123093.9053]';
  case 'yell'
    r_c = [-1224452.4000 -2689216.0000  5633638.2000]';
  case 'zimj'
    r_c = [4331294.0430   567541.9820  4633135.6250]';
  case 'isco'
    r_c = [326077.5221 -6340127.2997 612125.9023]';
  case 'wtzs'
    r_c = [4075535.300 931822.185 4801608.915]';  
  case 'nya1'
    r_c = [1202434 252632 6237772]';
  otherwise
    error(['No coordinates available for station ' station '!']);
end