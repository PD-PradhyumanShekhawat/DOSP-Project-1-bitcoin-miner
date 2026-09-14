-module(bitcoin_worker).

-export([start/1]).

start(BossPid) ->
    spawn(fun() -> worker_loop(BossPid) end).

worker_loop(BossPid) ->
    receive
        {work, K, Start, End} ->
            Results = bitcoin_miner:mine_range(K, Start, End),
            BossPid ! {work_complete, self(), Start, End, Results},
            worker_loop(BossPid)
    end.


















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