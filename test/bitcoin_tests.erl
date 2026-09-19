-module(bitcoin_tests).

-include_lib("eunit/include/eunit.hrl").

hash_to_hex_test() ->
    Hash =
        crypto:hash(
            sha256,
            <<"COP5615 is a boring class">>
        ),

    ?assertEqual(
        "fb4431b6a2df71b6cbad961e08fa06ee6fff47e3bc14e977f4b2ea57caee48a4",
        bitcoin_utils:hash_to_hex(Hash)
    ).

problem_statement_example_test() ->
    Candidate =
        <<"pr.shekhawat;12345">>,

    Hash =
        crypto:hash(
            sha256,
            Candidate
        ),

    HexHash =
        bitcoin_utils:hash_to_hex(Hash),

    ?assertEqual(
        "04e793629c46e2a7daee842acfd3351a878ac66254af50b3e6ce5b413a85d537",
        HexHash
    ),

    ?assert(
        bitcoin_utils:has_leading_zeroes(
            HexHash,
            1
        )
    ),

    ?assertNot(
        bitcoin_utils:has_leading_zeroes(
            HexHash,
            2
        )
    ).

make_candidate_test() ->
    ?assertEqual(
        <<"pr.shekhawat;12345">>,
        bitcoin_utils:make_candidate(
            "pr.shekhawat",
            12345
        )
    ).

make_candidate_zero_test() ->
    ?assertEqual(
        <<"pr.shekhawat;0">>,
        bitcoin_utils:make_candidate(
            "pr.shekhawat",
            0
        )
    ).

make_candidate_large_number_test() ->
    ?assertEqual(
        <<"pr.shekhawat;999999">>,
        bitcoin_utils:make_candidate(
            "pr.shekhawat",
            999999
        )
    ).

leading_zeroes_zero_test() ->
    ?assert(
        bitcoin_utils:has_leading_zeroes(
            "0000abcd",
            0
        )
    ).

leading_zeroes_one_test() ->
    ?assert(
        bitcoin_utils:has_leading_zeroes(
            "0abcdef",
            1
        )
    ).

leading_zeroes_four_test() ->
    ?assert(
        bitcoin_utils:has_leading_zeroes(
            "0000abcd",
            4
        )
    ).

leading_zeroes_four_fail_test() ->
    ?assertNot(
        bitcoin_utils:has_leading_zeroes(
            "000abcde",
            4
        )
    ).

leading_zeroes_nonzero_test() ->
    ?assertNot(
        bitcoin_utils:has_leading_zeroes(
            "1000abcd",
            1
        )
    ).

hash_length_test() ->
    Hash =
        crypto:hash(
            sha256,
            <<"test">>
        ),

    ?assertEqual(32, byte_size(Hash)).

hex_hash_length_test() ->
    Hash =
        crypto:hash(
            sha256,
            <<"test">>
        ),

    Hex =
        bitcoin_utils:hash_to_hex(Hash),

    ?assertEqual(64, length(Hex)).

hex_hash_is_list_test() ->
    Hash =
        crypto:hash(
            sha256,
            <<"test">>
        ),

    Hex =
        bitcoin_utils:hash_to_hex(Hash),

    ?assert(is_list(Hex)).

mine_empty_range_test() ->
    ?assertEqual(
        [],
        bitcoin_miner:mine_range(
            4,
            10,
            5,
            "pr.shekhawat"
        )
    ).

mine_single_range_test() ->
    Results =
        bitcoin_miner:mine_range(
            0,
            0,
            0,
            "pr.shekhawat"
        ),

    ?assertEqual(1, length(Results)).

mine_result_format_test() ->
    Results =
        bitcoin_miner:mine_range(
            0,
            0,
            0,
            "pr.shekhawat"
        ),

    [{Candidate, Hash}] = Results,

    ?assertEqual(
        <<"pr.shekhawat;0">>,
        Candidate
    ),

    ?assertEqual(64, length(Hash)).

mine_result_prefix_test() ->
    Results =
        bitcoin_miner:mine_range(
            0,
            0,
            2,
            "pr.shekhawat"
        ),

    lists:foreach(
        fun({Candidate, _Hash}) ->
            ?assert(
                lists:prefix(
                    "pr.shekhawat;",
                    binary_to_list(Candidate)
                )
            )
        end,
        Results
    ).

mine_hash_verification_test() ->
    Results =
        bitcoin_miner:mine_range(
            1,
            0,
            100,
            "pr.shekhawat"
        ),

    lists:foreach(
        fun({Candidate, Hash}) ->
            ActualHash =
                bitcoin_utils:hash_to_hex(
                    crypto:hash(
                        sha256,
                        Candidate
                    )
                ),

            ?assertEqual(Hash, ActualHash),

            ?assert(
                bitcoin_utils:has_leading_zeroes(
                    Hash,
                    1
                )
            )
        end,
        Results
    ).

mine_result_nonce_order_test() ->
    Results =
        bitcoin_miner:mine_range(
            0,
            0,
            5,
            "pr.shekhawat"
        ),

    Nonces =
        [
            list_to_integer(
                lists:nthtail(
                    length("pr.shekhawat;"),
                    binary_to_list(Candidate)
                )
            )
         || {Candidate, _Hash} <- Results
        ],

    ?assertEqual(
        [0, 1, 2, 3, 4, 5],
        Nonces
    ).

boss_start_test() ->
    Pid =
        bitcoin_boss:start(
            0,
            10,
            10,
            1,
            "pr.shekhawat"
        ),

    ?assert(is_pid(Pid)),

    timer:sleep(100),

    ?assertNot(is_process_alive(Pid)).

boss_multiple_workers_test() ->
    Pid =
        bitcoin_boss:start(
            0,
            10,
            100,
            2,
            "pr.shekhawat"
        ),

    ?assert(is_pid(Pid)),

    timer:sleep(100),

    ?assertNot(is_process_alive(Pid)).

boss_silent_start_test() ->
    Pid =
        bitcoin_boss:start_silent(
            0,
            10,
            10,
            1,
            "pr.shekhawat"
        ),

    ?assert(is_pid(Pid)),

    timer:sleep(100),

    ?assertNot(is_process_alive(Pid)).

worker_start_test() ->
    Boss =
        spawn(fun() ->
            receive
                _ ->
                    ok
            end
        end),

    Worker =
        bitcoin_worker:start(
            Boss,
            "pr.shekhawat"
        ),

    ?assert(is_pid(Worker)),

    Worker ! stop,
    Boss ! stop.