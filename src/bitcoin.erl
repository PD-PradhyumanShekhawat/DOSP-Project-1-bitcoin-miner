%%%%%%%%%%%%%%                      Version 1.0.0                      %%%%%%%%%%%%%%




-module(bitcoin).

-export([main/1]).

main([KString]) ->
    {K, ""} = string:to_integer(KString),

    WorkUnit = 10000,
    TotalWork = 1000000,
    WorkerCount = erlang:system_info(schedulers_online),
    GatorLinkId = "55742970",

    BossPid =
        bitcoin_boss:start(
            K,
            WorkUnit,
            TotalWork,
            WorkerCount,
            GatorLinkId
        ),

    wait_for_boss(BossPid);

main(_) ->
    io:format("Usage: bitcoin <number_of_zeroes>~n").

wait_for_boss(BossPid) ->
    case is_process_alive(BossPid) of
        true ->
            timer:sleep(100),
            wait_for_boss(BossPid);
        false ->
            ok
    end.