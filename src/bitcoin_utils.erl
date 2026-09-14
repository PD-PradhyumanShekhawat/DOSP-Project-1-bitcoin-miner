-module(bitcoin_utils).

-export([
    hash_to_hex/1,
    has_leading_zeroes/2,
    make_candidate/2
]).

hash_to_hex(Hash) ->
    binary_to_list(
        list_to_binary(
            io_lib:format("~64.16.0b", [binary:decode_unsigned(Hash)])
        )
    ).

has_leading_zeroes(Hash, K) ->
    Prefix = lists:sublist(Hash, K),
    Prefix =:= lists:duplicate(K, $0).

make_candidate(GatorLinkId, Nonce) ->
    list_to_binary(
        GatorLinkId ++ ";" ++ integer_to_list(Nonce)
    ).