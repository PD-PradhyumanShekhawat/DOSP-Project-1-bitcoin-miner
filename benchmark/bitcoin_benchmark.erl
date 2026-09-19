-module(bitcoin_benchmark).

-export([run/0]).

run() ->
    WorkUnits =
        [1000, 5000, 10000, 50000, 100000],

    K = 4,
    TotalWork = 1000000,

    WorkerCount =
        erlang:system_info(schedulers_online),

    io:format(
        "work_unit,real_seconds,user_seconds,sys_seconds,cpu_seconds,cpu_real_ratio~n"
    ),

    lists:foreach(
        fun(WorkUnit) ->
            {Real, User, Sys} =
                timer:tc(
                    fun() ->
                        run_benchmark(
                            K,
                            WorkUnit,
                            TotalWork,
                            WorkerCount
                        )
                    end
                ),

            RealSeconds = Real / 1000000,
            UserSeconds = User / 1000000,
            SysSeconds = Sys / 1000000,
            CpuSeconds = UserSeconds + SysSeconds,

            Ratio =
                case RealSeconds of
                    0 ->
                        0.0;

                    _ ->
                        CpuSeconds / RealSeconds
                end,

            io:format(
                "~p,~.2f,~.2f,~.2f,~.3f,~.3f~n",
                [
                    WorkUnit,
                    RealSeconds,
                    UserSeconds,
                    SysSeconds,
                    CpuSeconds,
                    Ratio
                ]
            )
        end,
        WorkUnits
    ).

run_benchmark(
    K,
    WorkUnit,
    TotalWork,
    WorkerCount
) ->
    BossPid =
        bitcoin_boss:start_silent(
            K,
            WorkUnit,
            TotalWork,
            WorkerCount,
            "pr.shekhawat"
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