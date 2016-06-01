%------------------------------------
% BEGIN: function BattSizingCost.m
%------------------------------------
function [Mayer,Lagrange]=BattSizingCost(sol)

global AmbientTemp NumofBattPacks DesiredTemp TempFactor StrInParallel;

t0 = sol.initial.time;
x0 = sol.initial.state;
tf = sol.terminal.time;
xf = sol.terminal.state;
t  = sol.time;
x  = sol.state;
u  = sol.control;

ActualTemp = AmbientTemp + x(:,4)/TempFactor; %'/TempFactor' comes from Simulink Thermal Model
% ActualTemp = 25 + x(:,4)/TempFactor; %'/TempFactor' comes from Simulink Thermal Model

%%%%Battery Model Data 
SOC_tab = [0;5;10;15;20;30;40;50;60;70;80;85;90;95;100];
T_tab = [-15   -10    -5     0     5    15    25    35    45];

Tau1_tab = [99.6758,26.6657,40.2205,94.8008,61.8171,26.7788,41.8356,59.9413,87.8424;22.1513,14.9951,24.7529,56.7214,64.2421,76.2886,31.8964,50.6352,95.0902;23.8039,19.9362,20.8855,60.9571,28.8551,66.3875,23.9964,20.9352,8.3577;20.8147,33.3656,23.6125,12.8744,26.6124,26.7783,22.0459,70.8287,34.7169;12.281,16.2331,10.9604,13.244,21.0312,20.1462,22.8271,70.8317,79.142;12.2681,12.0166,20.8199,20.4907,20.902,16.8788,22.026,61.3274,88.7628;20.912,11.0119,20.5355,16.9916,27.8752,12.9193,22.0441,50.7373,43.6768;15.8494,15.9531,20.8582,18.1665,25.8689,12.978,21.0356,51.6256,17.2553;21.6841,13.9987,22.3876,30.9213,16.7569,11.5493,11.1756,31.2316,65.749;25.0679,18.9411,22.6131,20.6864,21.7652,16.8716,20.8174,51.0809,84.2417;12.8321,16.0367,25.4889,29.7742,25.8369,13.9088,22.0347,52.239,14.8254;46.8377,13.9897,28.7539,15.8512,28.3332,19.8189,22.0306,51.0525,53.4867;22.1559,19.1493,51.2955,41.2021,23.6044,17.6234,22.0657,17.8619,56.7001;40.6067,25.871,5.0602,18.7574,31.3705,15.8885,25.9956,41.373,1.0654;43.1416,16.3232,6.208,2.5339,41.5878,56.4788,24.0139,68.9062,2.6462;];
Tau2_tab = [124.1346,537.5894,894.2293,796.3834,60.2786,269.5939,485.546,816.0191,526.997;361.4616,310.9741,310.2825,412.891,268.3474,243.0644,284.755,241.203,392.7538;896.7949,111.4121,181.6692,221.8359,333.7943,233.7999,495.05,230.6096,98.4733;910.3526,125.7574,276.6613,418.9778,980.4002,242.5309,476.3261,146.8113,102.2602;927.1229,307.7197,394.6327,748.4848,772.4399,330.8067,194.544,638.8467,79.7271;807.7247,316.8193,297.3766,629.2068,968.2306,240.5831,432.8391,706.93,125.998;990.3873,319.9805,311.2078,411.3216,661.1344,235.3529,492.7191,899.6758,201.0129;937.6998,305.6168,289.6244,596.5159,577.0596,236.6449,493.3021,891.0418,216.7037;911.0238,300.7988,307.9273,947.7839,528.4335,240.5909,485.5343,645.399,107.0413;955.9397,324.8034,315.5728,534.1022,595.2636,240.975,466.434,997.3538,106.4893;962.7704,295.5026,384.019,601.2757,526.9533,250.1939,482.8309,935.8617,126.451;487.3288,267.0282,125.9931,525.4469,678.0851,143.5909,429.1589,676.7659,74.9896;598.7799,237.2861,128.0699,542.0659,547.9907,240.6782,662.8978,42.3733,73.294;134.4671,191.0307,141.4976,234.0861,174.0392,236.5169,515.2891,500.6547,76.9897;964.3942,101.0098,220.1249,749.5858,114.6199,293.3608,848.9749,639.7304,624.191;];
B1_tab = [0.0674,0.06,0.0496,0.0162,0.0558,0.0488,0.002,0.0678,0.0694;0.0071,0.0781,0.0129,0.0151,0.0899,0.0035,0.0839,0.0095,0.0027;0.0154,0.0421,0.004,0.0123,0.0115,0.0085,0.0092,0.0047,0.0017;0.0146,0.0097,0.0132,0.0114,0.0105,0.0085,0.0085,0.0057,0.001;0.0109,0.0084,0.0119,0.0105,0.0105,0.0087,0.0086,0.0057,0.0013;0.0123,0.0056,0.0072,0.0117,0.0104,0.0077,0.0086,0.0065,0.0012;0.0137,0.0075,0.0151,0.0118,0.0104,0.0079,0.0079,0.0057,0.0019;0.0147,0.006,0.0108,0.0106,0.0114,0.0085,0.0086,0.0048,0.0011;0.0136,0.0103,0.0111,0.0127,0.0135,0.0085,0.0047,0.0029,0.0012;0.015,0.0095,0.0127,0.0122,0.0114,0.0069,0.0091,0.0058,0.001;0.0183,0.0103,0.0177,0.013,0.0127,0.0085,0.0088,0.0059,0.0014;0.0386,0.0101,0.0204,0.0151,0.0162,0.0085,0.0126,0.0065,0.001;0.0246,0.0093,0.0117,0.0258,0.0186,0.0084,0.0107,0.0057,0.0015;0.0363,0.0038,0.0773,0.0345,0.0187,0.0212,0.0087,0.0062,0.0086;0.0645,0.0939,0.059,0.0331,0.0121,0.0155,0.018,0.0072,0.0207;];
B2_tab = [0.0661,0.0108,0.0289,0.0434,0.0572,0.0867,0.0731,0.0093,0.0498;0.0836,0.0079,0.0238,0.0575,0.0745,0.0473,0.0827,0.0069,0.0645;0.0759,0.0825,0.052,0.0403,0.0515,0.0168,0.0385,0.0087,0.005;0.0921,0.0577,0.0192,0.0459,0.0469,0.0163,0.0116,0.0089,0.0038;0.0903,0.0658,0.0384,0.0647,0.0289,0.0191,0.018,0.0093,0.0057;0.0329,0.0668,0.0292,0.0385,0.0197,0.0153,0.0135,0.0084,0.0074;0.0715,0.0617,0.0254,0.0452,0.0074,0.0169,0.0163,0.0036,0.0057;0.0767,0.0621,0.0286,0.0422,0.0176,0.0161,0.0144,0.0077,0.005;0.0691,0.0461,0.0259,0.055,0.0146,0.0163,0.0168,0.0069,0.0046;0.0746,0.0584,0.023,0.0446,0.014,0.0151,0.0144,0.0022,0.0055;0.0793,0.0485,0.03,0.0422,0.017,0.0152,0.0167,0.0088,0.0038;0.0342,0.0583,0.0276,0.0298,0.019,0.0104,0.0163,0.0088,0.0039;0.0025,0.0209,0.0185,0.0646,0.0192,0.0313,0.0152,0.0041,0.0049;0.076,0.0772,0.0828,0.0461,0.0174,0.0163,0.0106,0.0088,0.0049;0.025,0.0685,0.004,0.0338,0.0463,0.0607,0.0165,0.0091,0.0626;];
R0_tab = [0.0726,0.003,0.0168,0.0044,0.0265,0.0925,0.0604,0.0111,0.0644;0.0549,0.0156,0.0348,0.0334,0.0258,0.0111,0.0097,0.0109,0.0011;0.0467,0.0616,0.0313,0.0281,0.0184,0.0247,0.0084,0.0109,0.0105;0.0438,0.0442,0.0268,0.0237,0.0184,0.0157,0.0101,0.0109,0.0104;0.0417,0.0388,0.0245,0.0208,0.017,0.0136,0.0102,0.0109,0.0104;0.0414,0.039,0.0281,0.0232,0.0155,0.0147,0.0092,0.0109,0.0104;0.0433,0.0386,0.0252,0.0219,0.017,0.0129,0.0102,0.0109,0.0104;0.0406,0.0395,0.0258,0.0226,0.018,0.0134,0.0103,0.0106,0.0104;0.0426,0.0386,0.0278,0.0236,0.0139,0.011,0.0101,0.0107,0.0104;0.0438,0.0395,0.0272,0.0236,0.0157,0.0148,0.0103,0.0106,0.0104;0.0415,0.0395,0.0269,0.0252,0.0187,0.0139,0.0103,0.0109,0.0104;0.0399,0.0391,0.0276,0.0261,0.018,0.0166,0.0102,0.011,0.0104;0.0454,0.0439,0.0363,0.0271,0.0191,0.0195,0.0103,0.0118,0.0104;0.0526,0.058,0.0321,0.0259,0.0196,0.0157,0.0197,0.0124,0.0104;0.0354,0.0411,0.0268,0.0124,0.0418,0.0189,0.0385,0.0189,0.0066;];

v0_tab = [3.22578400497240;2.85303301782300;2.87200377539360;2.44375422292500;2.46043608481240;2.77773067902000;3.09804757044900;3.18054424608600;3.08080703837290];
alpha_tab = [0.109125911999000;0.356604109000000;0.407542627000000;0.796180211000000;0.800116242000000;0.456330221000000;0.159382770999000;0.100624164999000;0.156088417000000];
beta_tab = [7.27450500000000;17.9146592000000;18.0060037000000;23.9750603000000;15.0463223000000;17.3758911000000;5.41373830000000;3.05247558970000;8.77031230000000];
epsilon_tab = [0.00116117200990000;0.00643747600000000;0.00133145200990000;0.00203514400000000;0.00199099000000000;0.0101811610990000;0.0186072490000000;0.0561588400000000;0.00190268200000000];
gamma_tab = [0.0309918964990000;0.146930055000000;0.101323451000000;0.111379798000000;0.0961617950000000;0.111446664000000;0.0633176150000000;0.0701219790000000;0.111251555000000];
zeta_tab = [0.00141379300000000;0.0460074869990000;0.0626091819990000;0.0417796019990000;0.00274912505997000;0.00480409719990000;0.0872888340000000;0.00167566201999000;0.0721124260000000];

%yi = interp1(x,y,xi,'linear')
SoC = x(:,1)*100;

v0 = interp1(T_tab,v0_tab,ActualTemp,'spline');
alpha = interp1(T_tab,alpha_tab,ActualTemp,'spline');
beta = interp1(T_tab,beta_tab,ActualTemp,'spline');
gamma = interp1(T_tab,gamma_tab,ActualTemp,'spline');
epsilon = interp1(T_tab,epsilon_tab,ActualTemp,'spline');
zeta = interp1(T_tab,zeta_tab,ActualTemp,'spline');

R0 = interp2(T_tab,SOC_tab,R0_tab,ActualTemp,SoC);
Tau1 = interp2(T_tab,SOC_tab,Tau1_tab,ActualTemp,SoC);
R1 = interp2(T_tab,SOC_tab,B1_tab,ActualTemp,SoC);
Tau2 = interp2(T_tab,SOC_tab,Tau2_tab,ActualTemp,SoC);
R2 = interp2(T_tab,SOC_tab,B2_tab,ActualTemp,SoC);

C1 = Tau1./R1;
C2 = Tau2./R2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Voc = v0+alpha.*(1-exp(-beta.*x(:,1)))+gamma.*x(:,1)+zeta.*(1-exp(-epsilon./(1-x(:,1))));
Vbatt = Voc - x(:,2) - x(:,3) - u.*R0;

P_Les = (56.5*StrInParallel)*u.*Vbatt;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

P_Load_Tab_1day = 15e3*[0 0 0 0 0 0 0 1 1 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0]';
P_Load_Tab = [P_Load_Tab_1day; P_Load_Tab_1day; ...
               P_Load_Tab_1day; P_Load_Tab_1day];

% 10 PHEVs in JANUARY with area of 12m^2 and PVs with eff of 15%
P_pv_Tab_Jan = (10*.15*12)*[0 0 0 0 0 0 0 0 69 234 402 433 474 ...
                            383 313 113 165 17 0 0 0 0 0 0]';
                        
% 10 PHEVs in APRIL with area of 12m^2 and PVs with eff of 15%
P_pv_Tab_Apr = (10*.15*12)*[0 0 0 0 0 0 42 88 174 231 162 330 421 201 ...
                            186 294 115 91 28 0 0 0 0 0]';

% 10 PHEVs in JULY with area of 12m^2 and PVs with eff of 15%
P_pv_Tab_July = (10*.15*12)*[0 0 0 0 0 0 109 276 454 634 762 ...
                             870 910 889 804 667 509 330 150 ...
                             11 0 0 0 0 ]';

% 10 PHEVs in OCTOBER with area of 12m^2 and PVs with eff of 15%
P_pv_Tab_Oct = (10*.15*12)*[0 0 0 0 0 0 0 0 196 351 472 542 550 378 ...
                            397 276 111 0 0 0 0 0 0 0]';                         
                         
%9.9 cents ave per KWh in Australia. Price in US$
Aus_WhPrice_Tab = 1e-6*3.4*[22.5 16 13 17 21 24 28 32 36 40 42 38 39 ...
                            37 35 42 32 27 26 33 30 22 24 23]';  

%Watt/Hour Price in Ohio/commercial for 31Jan10. Price in US$                     
OH_WhPrice_Tab_Jan = 1e-3*[0.099551735 0.096614901 0.109032853 0.103852925 ...
                           0.104777912 0.100291725 0.101309211 0.12355515 ...
                           0.107853494 0.086578791 0.093654942 0.084220074 ...
                           0.07950264 0.08380383 0.079965134 0.072357115 ...
                           0.061997259 0.083942578 0.099597984 0.100546096 ...
                           0.108015367 0.119346459 0.092938077 0.093007451]'; 

%Watt/Hour Price in Ohio/commercial for 31Apr10. Price in US$                     
OH_WhPrice_Tab_Apr = 1e-3*[0.078382725 0.067387989 0.071173518 0.071674544 ...
                           0.082557941 0.099676328 0.118687479 0.190946553 ...
                           0.105911317 0.109140151 0.111283429 0.120580243 ...
                           0.09881345 0.113064854 0.122500843 0.105410291 ...
                           0.100901058 0.115458645 0.087568201 0.086371305 ...
                           0.123892581 0.102598979 0.080832185 0.074318848]';

                    
%Watt/Hour Price in Ohio/commercial for 31Jul10. Price in US$                    
OH_WhPrice_Tab_July = 1e-3*[0.081903887;0.093611441;0.086655488;0.068212418;0.068653288; ...
                       0.06796749;0.067894012;0.069633;0.079797507;0.092778686; ...
                       0.108086679;0.099195797;0.102967686;0.101473626;0.10502508; ... 
                       0.107719287;0.144042094;0.108478564;0.109776682;0.102918701; ...
                       0.106886532;0.113181179;0.094493181;0.099563188;];

%Watt/Hour Price in Ohio/commercial for 31Oct10. Price in US$                   
OH_WhPrice_Tab_Oct = 1e-3*[0.087489456 0.084446345 0.067841541 0.082858635 ...
                           0.087026374 0.083520181 0.093311061 0.111272035 ...
                           0.102010391 0.103895797 0.100257294 0.100158062 ... 
                           0.099033434 0.100091907 0.104722729 0.100323449 ...
                           0.096817255 0.093972607 0.098371888 0.10128269 ...
                           0.106872754 0.106111976 0.097445723 0.092484129]';
                 
TimeHours = 3600*[1:1:24*4]; %3600secs x 24hours x 4days                
                 
P_Load = interp1(TimeHours,P_Load_Tab,t,'spline');

P_pv_Tab = [P_pv_Tab_July; P_pv_Tab_Oct; P_pv_Tab_Jan; P_pv_Tab_Apr];

OH_WhPrice = [OH_WhPrice_Tab_July; OH_WhPrice_Tab_Oct; ...
                OH_WhPrice_Tab_Jan; OH_WhPrice_Tab_Apr];  


P_pv = interp1(TimeHours,P_pv_Tab,t,'spline');
WattSecPrice = 1/3600*interp1(TimeHours,OH_WhPrice,t,'spline'); %Watt Sec Price in US$
%Price_pv = 0.3/1000/3600; %Price per Wh per sec.
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Mayer = 1e1*(100*xf(1) - 50)^2 + 0e1*(AmbientTemp + xf(4)/TempFactor - DesiredTemp)^2; %'/TempFactor' comes from Simulink Thermal Model
Mayer = 0;
Lagrange = 1e0*( P_Load - P_pv - P_Les ).*WattSecPrice; %+ P_pv*Price_pv; 
%Lagrange = zeros(size(t));

%------------------------------------
% END: function BattSizingCost.m
%------------------------------------
