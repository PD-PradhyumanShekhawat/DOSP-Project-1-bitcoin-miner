-module(bitcoin).

-export([main/1]).

main([Argument]) ->
    case string:to_integer(Argument) of
        {K, ""} ->
            start_server(K);

        _ ->
            start_worker(Argument)
    end.

start_server(K) ->
    WorkUnit = 10000,
    TotalWork = 10000000,
    WorkerCount = erlang:system_info(schedulers_online),

    GatorLinkId = "kprabhakaran",

    BossPid =
        bitcoin_boss:start(K, WorkUnit, TotalWork, WorkerCount, GatorLinkId),

    wait_for_boss(BossPid).

start_worker(ServerIP) ->
    GatorLinkId = "pr.shekhawat",

    ServerNode = list_to_atom("bitcoin_server@" ++ ServerIP),
io:format("Server node: ~p~n", [ServerNode]),
    bitcoin_worker:start_remote(ServerNode, GatorLinkId),

    wait_forever().

wait_for_boss(BossPid) ->
    case is_process_alive(BossPid) of
        true ->
            timer:sleep(100),
            wait_for_boss(BossPid);
        false ->
            ok
    end.

wait_forever() ->
    receive
        stop ->
            ok;
        _ ->
            wait_forever()
    end.