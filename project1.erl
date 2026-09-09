-module(project1).

% has_leading_zeros(hash, K) ->
%     Prefix = lists:sublist(Hash, K),
%     Prefix =:= lists:duplicates(K, $0).

-export([test_hash/0, has_leading_zeros/2]).

test_hash() ->
    Hash = crypto:hash(sha256, <<"COP5615 is a boring class">>),
    HexHash = binary_to_list(
        list_to_binary(
            io_lib:format("~64.16.0b", [binary:decode_unsigned(Hash)])
        )
    ),
    io:format("~s~n", [HexHash]).

has_leading_zeros(Hash, K) ->
    Prefix = lists:sublist(Hash, K),
    Prefix =:= lists:duplicate(K, $0).

%    crypto:hash(sha256, <<"COP5615 is a boring class">>).