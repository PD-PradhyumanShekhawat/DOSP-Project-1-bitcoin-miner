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

hash_to_hex_parameterized_test_() ->
    [
        ?_test(
            ?assertEqual(
                Expected,
                bitcoin_utils:hash_to_hex(
                    crypto:hash(sha256, Input)
                )
            )
        )
        || {Input, Expected} <- [
            {
                <<"COP5615 is a boring class">>,
                "fb4431b6a2df71b6cbad961e08fa06ee6fff47e3bc14e977f4b2ea57caee48a4"
            },
            {
                {
                    <<"pr.shekhawat;12345">>,
                    "04e793629c46e2a7daee842acfd3351a878ac66254af50b3e6ce5b413a85d537"
                }
            }
        ]
    ].

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

    ?assertNot(
        bitcoin_utils:has_leading_zeroes(
            HexHash,
            1
        )
    ).

has_leading_zeroes_test() ->
    ?assert(
        bitcoin_utils:has_leading_zeroes(
            "000abc",
            3
        )
    ),

    ?assertNot(
        bitcoin_utils:has_leading_zeroes(
            "000abc",
            4
        )
    ),

    ?assertNot(
        bitcoin_utils:has_leading_zeroes(
            "100abc",
            1
        )
    ),

    ?assert(
        bitcoin_utils:has_leading_zeroes(
            "abc",
            0
        )
    ).

has_leading_zeroes_parameterized_test_() ->
    [
        ?_test(
            ?assertEqual(
                Expected,
                bitcoin_utils:has_leading_zeroes(
                    Hash,
                    K
                )
            )
        )
        || {Hash, K, Expected} <- [
            {"000abc", 3, true},
            {"000abc", 4, false},
            {"100abc", 1, false},
            {"abc", 0, true}
        ]
    ].

make_candidate_test() ->
    ?assertEqual(
        <<"pr.shekhawat;42">>,
        bitcoin_utils:make_candidate(
            "pr.shekhawat",
            42
        )
    ).

make_candidate_parameterized_test_() ->
    [
        ?_test(
            ?assertEqual(
                Expected,
                bitcoin_utils:make_candidate(
                    Prefix,
                    Nonce
                )
            )
        )
        || {Prefix, Nonce, Expected} <- [
            {
                "pr.shekhawat",
                42,
                <<"pr.shekhawat;42">>
            },
            {
                "pr.shekhawat",
                9401,
                <<"pr.shekhawat;9401">>
            },
            {
                "test",
                0,
                <<"test;0">>
            }
        ]
    ].

mine_range_test() ->
    ?assertEqual(
        [
            {
                <<"test;2">>,
                "3e189adbf13058c2c8df4a2afe09bcc12611ecee8a7c4df3fb4d06e09b66c3dd"
            },
            {
                <<"test;3">>,
                "6f666844d8420fc5ed19ef796ef5145ac319bda3b2a0f1227b3998dc0dac3b23"
            },
            {
                <<"test;4">>,
                "21552a0e8de5ec67b983605d3cbee3e6cfb93128532bcada977d623a99a500ed"
            }
        ],
        bitcoin_miner:mine_range(
            0,
            2,
            4,
            "test"
        )
    ).

mine_empty_range_test() ->
    ?assertEqual(
        [],
        bitcoin_miner:mine_range(
            1,
            4,
            2,
            "test"
        )
    ).

mine_range_parameterized_test_() ->
    [
        ?_test(
            ?assertEqual(
                Expected,
                bitcoin_miner:mine_range(
                    K,
                    Start,
                    End,
                    Prefix
                )
            )
        )
        || {
            K,
            Start,
            End,
            Prefix,
            Expected
        } <- [
            {
                0,
                2,
                2,
                "test",
                [
                    {
                        <<"test;2">>,
                        "3e189adbf13058c2c8df4a2afe09bcc12611ecee8a7c4df3fb4d06e09b66c3dd"
                    }
                ]
            },
            {
                0,
                4,
                4,
                "pr.shekhawat",
                [
                    {
                        <<"pr.shekhawat;4">>,
                        "16820d818eea7722a88f6e0efa773b22d9733a0a596e85c88928c7f6b45833f0"
                    }
                ]
            },
            {
                1,
                4,
                2,
                "test",
                []
            }
        ]
    ].

boss_start_test() ->
    BossPid =
        bitcoin_boss:start(
            0,
            1,
            1,
            1,
            "test"
        ),

    ?assert(
        is_process_alive(BossPid)
    ),

    ?assert(
        wait_for_process_exit(
            BossPid,
            100
        )
    ).

boss_start_export_test() ->
    ?assert(
        erlang:function_exported(
            bitcoin_boss,
            start,
            5
        )
    ),

    ?assert(
        erlang:function_exported(
            bitcoin_boss,
            start,
            4
        )
    ),

    ?assert(
        erlang:function_exported(
            bitcoin_boss,
            start,
            3
        )
    ),

    ?assert(
        erlang:function_exported(
            bitcoin_boss,
            start,
            2
        )
    ).

worker_start_test() ->
    WorkerPid =
        bitcoin_worker:start(
            self(),
            "test"
        ),

    ?assert(
        is_process_alive(WorkerPid)
    ),

    WorkerPid ! stop,

    timer:sleep(10),

    ?assertNot(
        is_process_alive(WorkerPid)
    ).

worker_start_remote_test() ->
    WorkerPid =
        bitcoin_worker:start_remote(
            'bitcoin_worker@invalid',
            "test"
        ),

    ?assert(
        is_pid(WorkerPid)
    ),

    timer:sleep(100),

    ?assertNot(
        is_process_alive(WorkerPid)
    ).

wait_for_process_exit(_Pid, 0) ->
    false;

wait_for_process_exit(Pid, Attempts) ->
    case is_process_alive(Pid) of
        true ->
            timer:sleep(10),
            wait_for_process_exit(
                Pid,
                Attempts - 1
            );

        false ->
            true
    end.