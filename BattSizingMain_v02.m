% -----------------------------
% Batt Sizing Problem
% Assuming Batt Pack = 56.5x8 -> 452 Cells.
% Single Cell Vnom = 3.3154V @ 80%
% Level I   = 120VAC @ 12A -> 1.44KW.
% Level II  = 240VAC @ 32A -> 7.68KW.
% Level III = 480VAC @ 400A (3ph) -> 576KW.
%
% Voltage and Currents equivalents for a single cell
% in the Batt Pack.
%
% This version deals with the problem of charging the LES
% during four days.  Hence, the concept of PHASES is used.
%
% There is in place the restrictions for SoC of being 0.5 at the 
% beginning and end of each of the 4 days.
% -----------------------------


global AmbientTemp NumofBattPacks DesiredTemp TempFactor StrInParallel;

for NumofBattPacks = 1:1,
    
    tic; %Measuring time variable.

    init_mt_model_full_tl;

    InitialDeltaTemp = 0;    %Initial Batt and Ambient Temp Difference in C.
    AmbientTemp = 25;        %Ambient Temperature in C.
    DesiredTemp = 35;        %Desired Final Temperature in C.
    TempFactor = 5;          %Factor used in the Thermal Model.
    StrInParallel = 8*NumofBattPacks;     %Number of Strings in Parallel. 

    %Battery Cell Capacity
    Cap25 = 2.1879; %1 Cell Cap @ Temperature = 25 C.

    x10 = 0.5;
    x20 = 0;
    x30 = 0;
    x40 = InitialDeltaTemp*TempFactor; %Initial Delta Temperature, in C.
    x1f = 0.5;                         %'*TempFactor' comes from Simulink Thermal Model
    x4f = (DesiredTemp - AmbientTemp)*TempFactor; %Final desired Delta temperature;
    x1min = 0.20;
    x1max = 0.80;
    x2min = -1.05;
    x2max = 1.05;
    x3min = x2min;
    x3max = x2max;
    x4min = 0; %Temperatue values in C.
    x4max = (40 - AmbientTemp)*TempFactor;  %Temperatue values in C. 
                                            % >35 C is considered 
                                            % dangerous for the Battery.
                                
    param_min = [];
    param_max = [];

    path_min = [3; 0];% 0];                 %Vbatt, Charger Power included. Level 2 = 7.68KW.
    path_max = [3.8; 16.9*8/StrInParallel]; %Vbatt/#Cells in Series; 3.8; 3.3425; 
                                            %1.5KW-> 3.3425W/cell; 7.68KW-> 16.9 W/cell];
    event_min = [x10; x1f];                 %Events: terminal and/or initial constraints,
    event_max = [x10; x1f];                 %Events: aka Boundary Conditions.
    duration_min = [];
    duration_max = [];

    for iphase = 1:4,                       %July, Oct, Jan and April
        limits(iphase).nodes          = 2;
        limits(iphase).time.min       = 3600*24*[(iphase-1) (iphase)];
        limits(iphase).time.max       = 3600*24*[(iphase-1) (iphase)];
        limits(iphase).state.min(1,:) = [x10-.1 x1min x1f-.1];
        limits(iphase).state.max(1,:) = [x10+.1 x1max x1f+.1];
        limits(iphase).state.min(2,:) = [x2min x2min x2min];
        limits(iphase).state.max(2,:) = [x2max x2max x2max];
        limits(iphase).state.min(3,:) = [x3min x3min x3min];
        limits(iphase).state.max(3,:) = [x3max x3max x3max];
        limits(iphase).state.min(4,:) = [x4min x4min x4min];
        limits(iphase).state.max(4,:) = [x4max x4max x4max];
        limits(iphase).control.min    = -5.1259*8/StrInParallel; %Level 1 -> -0.9609A
                                                                 %Level 2 -> -5.1259A
        limits(iphase).control.max    = 5.1259*8/StrInParallel;
        limits(iphase).parameter.min  = param_min;
        limits(iphase).parameter.max  = param_max;
        limits(iphase).path.min       = path_min;
        limits(iphase).path.max       = path_max;
        limits(iphase).event.min      = event_min; %Events: terminal or initial constraints.
        limits(iphase).event.max      = event_max; %Events: terminal or initial constraints.
        limits(iphase).duration.min    = [];
        limits(iphase).duration.max    = [];
        % limits(iphase).intervals      = [1];
        % limits(iphase).nodesperint    = [10];
    
        if iphase < 4,
            linkages(iphase).left.phase = iphase;
            linkages(iphase).right.phase = iphase+1;
            linkages(iphase).min = -1e-6*[1; 1; 1; 1];
            linkages(iphase).max = 1e-6*[1; 1; 1; 1];
        end
    end
    
    load SolutionGuessSeasons;

    iphase = 1;
    guess(iphase).time = GuessJuly.solution.time;
    guess(iphase).state = GuessJuly.solution.state;
    guess(iphase).control = GuessJuly.solution.control;
    guess(iphase).parameter       = [];

    iphase = 2;
    guess(iphase).time = GuessOct.solution.time;
    guess(iphase).state = GuessOct.solution.state;
    guess(iphase).control = GuessOct.solution.control;
    guess(iphase).parameter       = [];
    
    iphase = 3;
    guess(iphase).time = GuessJan.solution.time;
    guess(iphase).state = GuessJan.solution.state;
    guess(iphase).control = GuessJan.solution.control;
    guess(iphase).parameter       = [];    
    
    iphase = 4;
    guess(iphase).time = GuessApr.solution.time;
    guess(iphase).state = GuessApr.solution.state;
    guess(iphase).control = GuessApr.solution.control;
    guess(iphase).parameter       = [];
    
    setup.guess = guess;

    clear x10 x20 x30 x40 x1f x2f x4f x1min x4min x1max x2min x2max x3min x3max x4max 
    clear param_min param_max path_min path_max event_min event_max
    clear duration_min duration_max Cap25 iphase

    setup.name  = 'Battery Sizing OCP';
    %setup.method = 'gauss';
    setup.funcs.cost = 'BattSizingCost_v02';
    setup.funcs.dae = 'BattSizingDae';
    setup.funcs.event = 'BattSizingEvent_v02'; %Events: terminal or initial constraints.
    setup.funcs.link = 'BattSizingLink';
    setup.limits = limits;
    setup.guess = guess;
    setup.linkages = linkages;
    setup.derivatives = 'numerical';
    setup.direction = 'increasing';
    setup.autoscale = 'on';

    %%%% For GPOPS 3.1 %%%%%%%%
    % setup.solver = 'snopt';
    % setup.mesh.grid = 'hp';
    % setup.mesh.tolerance = 1e-4;
    % setup.mesh.iteration = 25;
    % setup.mesh.on = 'yes';
    % setup.mesh.guess = 'yes';
    % setup.mesh.nodelimit = 200;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    output = gpops(setup);
    solution = output.solution;

    ElapsedTime(NumofBattPacks) = toc; %Measuring time variable.

    TotalSolution(NumofBattPacks).solution = solution;
    TotalSolution(NumofBattPacks).ElapsedTime = ElapsedTime;

    save mySolution TotalSolution
    
    clear setup limits guess solution 
    clear AmbientTemp DesiredTemp Tempfactor InitialDeltaTemp

end
%------------------------------------
% END: script BattSizingMain_v02.m
%------------------------------------

