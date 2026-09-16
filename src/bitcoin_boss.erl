-module(bitcoin_boss).

-export([
    start/2, 
    start/3
]).

start(K, WorkUnit) ->
    start(K, WorkUnit, "55742970").

start(K, WorkUnit, GatorLinkId) ->
    spawn(fun() ->
        boss_init(K, WorkUnit, GatorLinkId)
    end).

boss_init(K, WorkUnit, GatorLinkId) ->
    WorkerCount = erlang:system_info(schedulers_online),

    io:format(
        "Starting ~p worker actors on ~p schedulers.~n",
        [WorkerCount, WorkerCount]
    ),

    TotalWork = WorkerCount * WorkUnit,

    {Workers, NextStart} =
        start_workers(
            WorkerCount,
            K,
            WorkUnit,
            TotalWork,
            GatorLinkId,
            0,
            #{}
        ),

    boss_loop(
        K,
        WorkUnit,
        TotalWork,
        GatorLinkId,
        NextStart,
        Workers
    ).

start_workers(
        0,
        _K,
        _WorkUnit,
        _TotalWork,
        _GatorLinkId,
        NextStart,
        Workers
    ) ->
    {Workers, NextStart};

start_workers(
        Count,
        K,
        WorkUnit,
        TotalWork,
        GatorLinkId,
        NextStart,
        Workers
    ) ->
    case NextStart < TotalWork of
        true ->
            WorkerPid =
                bitcoin_worker:start(
                    self(),
                    GatorLinkId
                ),

            End =
                min(
                    NextStart + WorkUnit - 1,
                    TotalWork - 1
                ),

            WorkerPid ! {
                work,
                K,
                NextStart,
                End
            },

            UpdatedWorkers =
                maps:put(
                    WorkerPid,
                    {NextStart, End},
                    Workers
                ),

            start_workers(
                Count - 1,
                K,
                WorkUnit,
                TotalWork,
                GatorLinkId,
                End + 1,
                UpdatedWorkers
            );

        false ->
            {Workers, NextStart}
    end.

boss_loop(
    K,
    WorkUnit,
    TotalWork,
    GatorLinkId,
    NextStart,
    Workers
) ->
    receive
        {work_complete, WorkerPid, _Start, _End, Results} ->
            print_results(Results),

            UpdatedWorkers =
                maps:remove(
                    WorkerPid,
                    Workers
                ),

            case NextStart < TotalWork of
                true ->
                    NewEnd =
                        min(
                            NextStart + WorkUnit - 1,
                            TotalWork - 1
                        ),

                    WorkerPid ! {
                        work,
                        K,
                        NextStart,
                        NewEnd
                    },

                    NewWorkers =
                        maps:put(
                            WorkerPid,
                            {NextStart, NewEnd},
                            UpdatedWorkers
                        ),

                    boss_loop(
                        K,
                        WorkUnit,
                        TotalWork,
                        GatorLinkId,
                        NewEnd + 1,
                        NewWorkers
                    );

                false ->
                    case maps:size(UpdatedWorkers) of
                        0 ->
                            io:format(
                                "Mining complete. Searched ~p candidates.~n",
                                [TotalWork]
                            ),
                            ok;

                        _ ->
                            boss_loop(
                                K,
                                WorkUnit,
                                TotalWork,
                                GatorLinkId,
                                NextStart,
                                UpdatedWorkers
                            )
                    end
            end
    end.

print_results([]) ->
    ok;

print_results([{Candidate, Hash} | Rest]) ->
    io:format(
        "~s\t~s~n",
        [Candidate, Hash]
    ),
    print_results(Rest).

































%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                VERSION 2.0.0          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%                           The following version ran indefinitely on my machine, and I had to manually terminate it.
%%%                           The Boss assigns ranges to workers and gives completed workers new ranges.
%%%                           The initial implementation ran indefinitely because there was no total-work limit.
%%%                           A finite search limit was later added to allow controlled execution and benchmarking.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% -module(bitcoin_boss).

% -export([
%     start/2, 
%     start/3
% ]).

% start(K, WorkUnit) ->
%     start(K, WorkUnit, "55742970").

% start(K, WorkUnit, GatorLinkId) ->
%     spawn(fun() ->
%         boss_init(K, WorkUnit, GatorLinkId)
%     end).

% boss_init(K, WorkUnit, GatorLinkId) ->
%     WorkerCount = erlang:system_info(schedulers_online),

%     io:format(
%         "Starting ~p worker actors on ~p schedulers.~n",
%         [WorkerCount, WorkerCount]
%     ),

%     {Workers, NextStart} =
%         start_workers(
%             WorkerCount,
%             K,
%             WorkUnit,
%             GatorLinkId,
%             0,
%             #{}
%         ),

%     boss_loop(
%         K,
%         WorkUnit,
%         GatorLinkId,
%         NextStart,
%         Workers
%     ).

% start_workers(0, _K, _WorkUnit, _GatorLinkId, NextStart, Workers) ->
%     {Workers, NextStart};

% start_workers(
%         Count,
%         K,
%         WorkUnit,
%         GatorLinkId,
%         NextStart,
%         Workers
%     ) ->
%     WorkerPid =
%         bitcoin_worker:start(
%             self(),
%             GatorLinkId
%         ),

%     End = NextStart + WorkUnit - 1,

%     WorkerPid ! {
%         work,
%         K,
%         NextStart,
%         End
%     },

%     UpdatedWorkers =
%         maps:put(
%             WorkerPid,
%             {NextStart, End},
%             Workers
%         ),

%     start_workers(
%         Count - 1,
%         K,
%         WorkUnit,
%         GatorLinkId,
%         End + 1,
%         UpdatedWorkers
%     ).

% boss_loop(
%         K,
%         WorkUnit,
%         GatorLinkId,
%         NextStart,
%         Workers
%     ) ->
%     receive
%         {work_complete, WorkerPid, _Start, End, Results} ->
%             print_results(Results),

%             case maps:is_key(WorkerPid, Workers) of
%                 true ->
%                     NewStart = End + 1,
%                     NewEnd = NewStart + WorkUnit - 1,

%                     WorkerPid ! {
%                         work,
%                         K,
%                         NewStart,
%                         NewEnd
%                     },

%                     UpdatedWorkers =
%                         maps:put(
%                             WorkerPid,
%                             {NewStart, NewEnd},
%                             Workers
%                         ),

%                     boss_loop(
%                         K,
%                         WorkUnit,
%                         GatorLinkId,
%                         max(NextStart, NewEnd + 1),
%                         UpdatedWorkers
%                     );

%                 false ->
%                     boss_loop(
%                         K,
%                         WorkUnit,
%                         GatorLinkId,
%                         NextStart,
%                         Workers
%                     )
%             end
%     end.

% print_results([]) ->
%     ok;

% print_results([{Candidate, Hash} | Rest]) ->
%     io:format(
%         "~s\t~s~n",
%         [Candidate, Hash]
%     ),

%     print_results(Rest).













%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                VERSION 1.0.0          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%
%%%             The following version is the simplest version of the boss, which simply spawns a worker.
%%%             Version 1.0.0 is the initial Boss implementation using a single worker actor.
%%%             The worker receives a range, returns its results, and is assigned another range.
%%%             This version has no finite stopping condition and does not effectively utilize multiple cores.
%%%             Version 2.0.0 was developed to address these limitations.
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




% -module(bitcoin_boss).                                     %% Boss is basically the manager

% -export([start/2]).

% start(K, WorkUnit) ->
%     spawn(fun() -> boss_loop(K, WorkUnit, 0, #{}) end).

% boss_loop(K, WorkUnit, NextStart, Workers) ->
%     WorkerPid = bitcoin_worker:start(self()),

%     WorkerPid ! {work, K, NextStart, NextStart + WorkUnit - 1},

%     NewWorkers =
%         maps:put(
%             WorkerPid,
%             {NextStart, NextStart + WorkUnit - 1},
%             Workers
%         ),

%     receive
%         {work_complete, WorkerPid, _Start, End, Results} ->
%             print_results(Results),

%             NextRangeStart = End + 1,

%             WorkerPid ! {
%                 work,
%                 K,
%                 NextRangeStart,
%                 NextRangeStart + WorkUnit - 1
%             },

%             UpdatedWorkers =
%                 maps:put(
%                     WorkerPid,
%                     {NextRangeStart, NextRangeStart + WorkUnit - 1},
%                     NewWorkers
%                 ),

%             boss_loop(
%                 K,
%                 WorkUnit,
%                 NextRangeStart,
%                 UpdatedWorkers
%             )
%     end.

% print_results([]) ->
%     ok;

% print_results([{Candidate, Hash} | Rest]) ->
%     io:format("~s\t~s~n", [Candidate, Hash]),
%     print_results(Rest).