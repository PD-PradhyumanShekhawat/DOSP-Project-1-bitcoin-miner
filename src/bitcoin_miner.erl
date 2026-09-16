-module(bitcoin_miner).

-export([
    mine_range/3,       % for convinient testing
    mine_range/4        % This is the actual function used by the boss
]).



mine_range(K, Start, End) ->                                %%  Search all candidate numbers from Start to End, and 
    mine_range(K, Start, End, "55742970").         %%  return the ones whose hashes have at least K leading zeroes

mine_range(K, Start, End, GatorLinkId) ->
    mine_range(K, Start, End, GatorLinkId, []).

mine_range(_K, Current, End, _GatorLinkId, Results)
        when Current > End ->
    lists:reverse(Results);

mine_range(K, Current, End, GatorLinkId, Results) ->
    Candidate = bitcoin_utils:make_candidate(GatorLinkId, Current),

    Hash = crypto:hash(sha256, Candidate),

    HexHash = bitcoin_utils:hash_to_hex(Hash),
    
    case bitcoin_utils:has_leading_zeroes(HexHash, K) of
        true ->
            mine_range(
                K,
                Current + 1,
                End,
                GatorLinkId,
                [{Candidate, HexHash} | Results]
            );

        false ->
            mine_range(
                K,
                Current + 1,
                End,
                GatorLinkId,
                Results
            )
    end.