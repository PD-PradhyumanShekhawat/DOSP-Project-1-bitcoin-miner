-module(bitcoin_boss).

-export([
    start/5
]).

start(K, WorkUnit, TotalWork, WorkerCount, GatorLinkId) ->
    spawn(fun() -> boss_init(K, WorkUnit, TotalWork, WorkerCount, GatorLinkId) end).

boss_init(K, WorkUnit, TotalWork, WorkerCount, GatorLinkId) ->
    register(bitcoin_boss, self()),

    io:format(
        "Starting ~p worker actors on ~p schedulers.~n",
        [
            WorkerCount,
            erlang:system_info(schedulers_online)
        ]
    ),

    {Workers, NextStart} = start_workers(WorkerCount, K, WorkUnit, TotalWork, GatorLinkId, 0, #{}),
    timer:sleep(1000),
    boss_loop(K, WorkUnit, TotalWork, GatorLinkId, NextStart, Workers).

start_workers(0, _K, _WorkUnit, _TotalWork, _GatorLinkId, NextStart, Workers) ->
    {Workers, NextStart};

start_workers(Count, K, WorkUnit, TotalWork, GatorLinkId, NextStart, Workers) ->
    case NextStart < TotalWork of
        true ->
            WorkerPid = bitcoin_worker:start(self(), GatorLinkId),
            {NextWork, UpdatedWorkers} = assign_work(WorkerPid, K, WorkUnit, TotalWork, NextStart, Workers),
            start_workers(Count - 1, K, WorkUnit, TotalWork, GatorLinkId, NextWork, UpdatedWorkers);

        false ->
            {Workers, NextStart}
    end.

boss_loop(K, WorkUnit, TotalWork, GatorLinkId, NextStart, Workers) ->
    receive
        {register_worker, WorkerPid, WorkerGatorLinkId} ->
            io:format(
                "Remote worker registered: ~p~n",
                [WorkerPid]
            ),

            case NextStart < TotalWork of
                true ->
                    {NextWork, NewWorkers} = assign_work(WorkerPid, K, WorkUnit, TotalWork, NextStart, Workers),
                    boss_loop(K, WorkUnit, TotalWork, WorkerGatorLinkId, NextWork, NewWorkers);

                false ->
                    WorkerPid ! stop,
                    boss_loop(K, WorkUnit, TotalWork, GatorLinkId, NextStart, Workers)
            end;

        {work_complete, WorkerPid, _Start, _End, Results} ->
            print_results(Results),
            UpdatedWorkers = maps:remove(WorkerPid, Workers),
            case NextStart < TotalWork of
                true ->
                    {NextWork, NewWorkers} = assign_work(WorkerPid, K, WorkUnit, TotalWork, NextStart, UpdatedWorkers),
                    boss_loop(K, WorkUnit, TotalWork, GatorLinkId, NextWork, NewWorkers);

                false ->
                    WorkerPid ! stop,

                    case maps:size(UpdatedWorkers) of
                        0 ->
                            io:format(
                                "Mining complete. Searched ~p candidates.~n",
                                [TotalWork]
                            ),
                            unregister(bitcoin_boss),
                            ok;

                        _ ->
                            boss_loop(K, WorkUnit, TotalWork, GatorLinkId, NextStart, UpdatedWorkers)
                    end
            end
    end.

assign_work(WorkerPid, K, WorkUnit, TotalWork, NextStart, Workers) ->
    End = min(NextStart + WorkUnit - 1, TotalWork - 1),
    WorkerPid ! {work, K, NextStart, End},
    {End + 1, maps:put(WorkerPid, {NextStart, End}, Workers)}.

print_results(Results) ->
    lists:foreach(fun({Candidate, Hash}) -> io:format("~s\t~s~n", [Candidate, Hash]) end, Results).
