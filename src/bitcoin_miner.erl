-module(bitcoin_miner).

-export([
    mine_range/3
]).

mine_range(K, Start, End) ->
    mine_range(K, Start, End, "55742970", []).

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