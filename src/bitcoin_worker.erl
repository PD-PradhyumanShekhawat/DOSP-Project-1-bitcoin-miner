-module(bitcoin_worker).

-export([
    start/2,
    start_remote/2
]).

%% Local worker: BossPid is a process on the same Erlang node.
start(BossPid, GatorLinkId) ->
    spawn(fun() ->
        worker_loop(BossPid, GatorLinkId)
    end).

%% Remote worker: connect to the Boss node and register with it.
start_remote(ServerNode, GatorLinkId) ->
    spawn(fun() ->
        case net_adm:ping(ServerNode) of
            pong ->
                {bitcoin_boss, ServerNode} ! {
                    register_worker,
                    self(),
                    GatorLinkId
                },
                remote_worker_loop(
                    {bitcoin_boss, ServerNode},
                    GatorLinkId
                );

            pang ->
                ok
        end
    end).

worker_loop(BossPid, GatorLinkId) ->
    receive
        {work, K, Start, End} ->
            Results =
                bitcoin_miner:mine_range(
                    K,
                    Start,
                    End,
                    GatorLinkId
                ),

            BossPid ! {
                work_complete,
                self(),
                Start,
                End,
                Results
            },

            worker_loop(BossPid, GatorLinkId);

        stop ->
            ok
    end.

remote_worker_loop(Boss, GatorLinkId) ->
    receive
        {work, K, Start, End} ->
            Results =
                bitcoin_miner:mine_range(
                    K,
                    Start,
                    End,
                    GatorLinkId
                ),

            Boss ! {
                work_complete,
                self(),
                Start,
                End,
                Results
            },

            remote_worker_loop(Boss, GatorLinkId);

        stop ->
            ok
    end.























% -module(bitcoin_worker).

% -export([start/2]).

% start(BossPid, GatorLinkId) ->
%     spawn(fun() ->
%         worker_loop(BossPid, GatorLinkId)
%     end).

% worker_loop(BossPid, GatorLinkId) ->
%     receive
%         {work, K, Start, End} ->
%             Results =
%                 bitcoin_miner:mine_range(
%                     K,
%                     Start,
%                     End,
%                     GatorLinkId
%                 ),

%             BossPid ! {
%                 work_complete,
%                 self(),
%                 Start,
%                 End,
%                 Results
%             },

%             worker_loop(
%                 BossPid,
%                 GatorLinkId
%             );

%         stop ->
%             ok
%     end.


















% -module(bitcoin_worker).

% -export([start/2]).

% start(BossPid, GatorLinkId) ->
%     spawn(fun() -> 
%         worker_loop(BossPid, GatorLinkId) 
%     end).

% worker_loop(BossPid, GatorLinkId) ->
%     receive
%         {work, K, Start, End} ->
%             Results =
%                 bitcoin_miner:mine_range(                   %% The worker calles the bitcoin_miner, & performs calculation
%                     K,
%                     Start,
%                     End,
%                     GatorLinkId
%                 ),

%             BossPid ! {
%                 work_complete,
%                 self(),
%                 Start,
%                 End,
%                 Results
%             },

%             worker_loop(BossPid, GatorLinkId)               %% The worker is not printing anything, it just sends the results to the Boss
%     end.


















%-module(bitcoin_worker).

%-export([
%    start/1
%]).

%start(BossPid) ->
%    spawn(fun() -> worker_loop(BossPid) end).

%worker_loop(BossPid) ->
%    recieve
%        {work, K, Start, End} ->
%            Results = bitcoin_miner:mine_range(K, Start, End),
%
%            BossPid ! (work_complete, self(), Start, End, Results)
%
 %           worker_loop(BossPid)
  %  end.