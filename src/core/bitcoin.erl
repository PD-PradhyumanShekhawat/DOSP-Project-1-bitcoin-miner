-module(bitcoin).

-export([main/1]).

main([Argument]) ->
    case string:to_integer(Argument) of
        {K, ""} ->
            start_server(K);

        _ ->
            start_worker(Argument)
    end;

main(_) ->
    io:format(
        "Usage: bitcoin <number_of_zeroes | server_ip>~n"
    ).

start_server(K) ->
    WorkUnit = 10000,
    TotalWork = 1000000,
    WorkerCount =
        erlang:system_info(schedulers_online),
    GatorLinkId = "pr.shekhawat",

    BossPid =
        bitcoin_boss:start(
            K,
            WorkUnit,
            TotalWork,
            WorkerCount,
            GatorLinkId
        ),

    wait_for_boss(BossPid).

start_worker(ServerIP) ->
    GatorLinkId = "pr.shekhawat",

    ServerNode =
        list_to_atom(
            "bitcoin_server@" ++ ServerIP
        ),

    bitcoin_worker:start_remote(
        ServerNode,
        GatorLinkId
    ),

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



















% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                      Version 2.0.0                      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   

% -module(bitcoin).

% -export([main/1]).

% main([Argument]) ->
%     case string:to_integer(Argument) of
%         {K, ""} ->
%             start_server(K);

%         _ ->
%             start_worker(Argument)
%     end;

% main(_) ->
%     io:format(
%         "Usage: bitcoin <number_of_zeroes | server_ip>~n"
%     ).

% start_server(K) ->
%     WorkUnit = 10000,
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

% start_worker(ServerIP) ->
%     GatorLinkId = "55742970",

%     ServerNode =
%         list_to_atom(
%             "bitcoin_server@" ++ ServerIP
%         ),

%     bitcoin_worker:start_remote(
%         ServerNode,
%         GatorLinkId
%     ),

%     wait_forever().

% wait_for_boss(BossPid) ->
%     case is_process_alive(BossPid) of
%         true ->
%             timer:sleep(100),
%             wait_for_boss(BossPid);
%         false ->
%             ok
%     end.

% wait_forever() ->
%     receive
%         stop ->
%             ok;
%         _ ->
%             wait_forever()
%     end.






















%%%%%%%%%%%%%%                      Version 1.0.0                      %%%%%%%%%%%%%%




% -module(bitcoin).

% -export([main/1]).

% main([KString]) ->
%     {K, ""} = string:to_integer(KString),

%     WorkUnit = 10000,
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

%     wait_for_boss(BossPid);

% main(_) ->
%     io:format("Usage: bitcoin <number_of_zeroes>~n").

% wait_for_boss(BossPid) ->
%     case is_process_alive(BossPid) of
%         true ->
%             timer:sleep(100),
%             wait_for_boss(BossPid);
%         false ->
%             ok
%     end.