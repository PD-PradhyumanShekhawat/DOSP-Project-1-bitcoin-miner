-module(bitcoin_benchmark).

-export([
    run/0,
    run/1,
    benchmark/5
]).

run() ->
    run([
        {4, 1000, 1000000},
        {4, 10000, 1000000},
        {4, 100000, 1000000}
    ]).

run(Configurations) ->
    WorkerCount =
        erlang:system_info(schedulers_online),

    GatorLinkId = "pr.shekhawat",

    lists:foreach(
        fun({K, WorkUnit, TotalWork}) ->
            {Time, _Result} =
                timer:tc(
                    bitcoin_benchmark,
                    benchmark,
                    [
                        K,
                        WorkUnit,
                        TotalWork,
                        WorkerCount,
                        GatorLinkId
                    ]
                ),

            io:format(
                "k=~p work_unit=~p total_work=~p workers=~p real_seconds=~.3f~n",
                [
                    K,
                    WorkUnit,
                    TotalWork,
                    WorkerCount,
                    Time / 1000000
                ]
            )
        end,
        Configurations
    ).

benchmark(
    K,
    WorkUnit,
    TotalWork,
    WorkerCount,
    GatorLinkId
) ->
    BossPid =
        bitcoin_boss:start_silent(
            K,
            WorkUnit,
            TotalWork,
            WorkerCount,
            GatorLinkId
        ),

    wait_for_boss(BossPid).

wait_for_boss(BossPid) ->
    case is_process_alive(BossPid) of
        true ->
            timer:sleep(10),
            wait_for_boss(BossPid);

        false ->
            ok
    end.






















% -module(benchmark).

% -export([run/1]).

% run(WorkUnit) ->
%     K = 4,
%     TotalWork = 1000000,
%     WorkerCount = erlang:system_info(schedulers_online),
%     GatorLinkId = "55742970",

%     BossPid =
%         bitcoin_boss:start(
%             K,
%             WorkUnit,
%             TotalWork,
%             WorkerCount,
%             GatorLinkId
%         ),

%     wait_for_boss(BossPid).

% wait_for_boss(BossPid) ->
%     case is_process_alive(BossPid) of
%         true ->
%             timer:sleep(50),
%             wait_for_boss(BossPid);
%         false ->
%             ok
%     end.