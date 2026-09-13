-module(project1).

-export([
    test_hash/0,
    has_leading_zeroes/2,
    mine_range/3
]).

-define(GATOR_LINK_ID, <<"55742970">>).


test_hash() ->
    Hash = crypto:hash(sha256, <<"COP5615 is a boring class">>),
    HexHash = hash_to_hex(Hash),
    io:format("~s~n", [HexHash]).


hash_to_hex(Hash) ->
    binary_to_list(
        list_to_binary(
            io_lib:format("~64.16.0b", [binary:decode_unsigned(Hash)])
        )
    ).


has_leading_zeroes(Hash, K) ->
    Prefix = lists:sublist(Hash, K),
    Prefix =:= lists:duplicate(K, $0).


mine_range(K, Start, End) ->
    mine_range(K, Start, End, 0).


mine_range(_K, Current, End, Count) when Current > End ->
    Count;

mine_range(K, Current, End, Count) ->
    Candidate =
        <<?GATOR_LINK_ID/binary, ";", (integer_to_binary(Current))/binary>>,

    Hash = crypto:hash(sha256, Candidate),

    HexHash = hash_to_hex(Hash),

    case has_leading_zeroes(HexHash, K) of
        true ->
            io:format("~s\t~s~n", [
                binary_to_list(Candidate),
                HexHash
            ]),
            mine_range(K, Current + 1, End, Count + 1);

        false ->
            mine_range(K, Current + 1, End, Count)
    end.