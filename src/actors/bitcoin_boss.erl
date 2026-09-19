-module(bitcoin_boss).

-export([
    start/5,
    start_silent/5
]).

start(K, WorkUnit, TotalWork, WorkerCount, GatorLinkId) ->
    spawn(fun() ->
        boss_init(
            K,
            WorkUnit,
            TotalWork,
            WorkerCount,
            GatorLinkId,
            true
        )
    end).

start_silent(K, WorkUnit, TotalWork, WorkerCount, GatorLinkId) ->
    spawn(fun() ->
        boss_init(
            K,
            WorkUnit,
            TotalWork,
            WorkerCount,
            GatorLinkId,
            false
        )
    end).

boss_init(
    K,
    WorkUnit,
    TotalWork,
    WorkerCount,
    GatorLinkId,
    PrintResults
) ->
    register(bitcoin_boss, self()),

    io:format(
        "Starting ~p worker actors on ~p schedulers.~n",
        [
            WorkerCount,
            erlang:system_info(schedulers_online)
        ]
    ),

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
        NextStart,
        Workers,
        PrintResults
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
    NextStart,
    Workers,
    PrintResults
) ->
    receive
        {register_worker, WorkerPid, _WorkerGatorLinkId} ->
            case NextStart < TotalWork of
                true ->
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

                    NewWorkers =
                        maps:put(
                            WorkerPid,
                            {NextStart, End},
                            Workers
                        ),

                    boss_loop(
                        K,
                        WorkUnit,
                        TotalWork,
                        End + 1,
                        NewWorkers,
                        PrintResults
                    );

                false ->
                    WorkerPid ! stop,

                    boss_loop(
                        K,
                        WorkUnit,
                        TotalWork,
                        NextStart,
                        Workers,
                        PrintResults
                    )
            end;

        {
            work_complete,
            WorkerPid,
            Start,
            End,
            Results
        } ->
            case maps:is_key(WorkerPid, Workers) of
                true ->
                    print_results(Results, PrintResults),

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
                                NewEnd + 1,
                                NewWorkers,
                                PrintResults
                            );

                        false ->
                            WorkerPid ! stop,

                            case maps:size(UpdatedWorkers) of
                                0 ->
                                    io:format(
                                        "Mining complete. Searched ~p candidates.~n",
                                        [TotalWork]
                                    ),
                                    unregister(bitcoin_boss);

                                _ ->
                                    boss_loop(
                                        K,
                                        WorkUnit,
                                        TotalWork,
                                        NextStart,
                                        UpdatedWorkers,
                                        PrintResults
                                    )
                            end
                    end;

                false ->
                    boss_loop(
                        K,
                        WorkUnit,
                        TotalWork,
                        NextStart,
                        Workers,
                        PrintResults
                    )
            end;

        stop ->
            stop_workers(maps:keys(Workers)),
            unregister(bitcoin_boss);

        _Other ->
            boss_loop(
                K,
                WorkUnit,
                TotalWork,
                NextStart,
                Workers,
                PrintResults
            )
    end.

print_results([], _PrintResults) ->
    ok;

print_results(Results, true) ->
    lists:foreach(
        fun({Candidate, Hash}) ->
            io:format(
                "~s~t~s~n",
                [
                    binary_to_list(Candidate),
                    Hash
                ]
            )
        end,
        Results
    );

print_results(_Results, false) ->
    ok.

stop_workers([]) ->
    ok;

stop_workers([WorkerPid | Rest]) ->
    WorkerPid ! stop,
    stop_workers(Rest).