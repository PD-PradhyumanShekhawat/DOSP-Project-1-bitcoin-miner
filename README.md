# COP5615 Project 1 - Bitcoin Miner

This project is implemented in Erlang and uses the Actor Model for parallel and distributed computation.

## Group members:
Pradhyuman Singh Shekhawat, UFID: 55742970, Email: [pr.shekhawat@ufl.edu](mailto\:pr.shekhawat@ufl.edu)
Keerthana Prabhakaran,  UFID: 20255736 , Email: [kprabhakaran@ufl.edu](mailto\:kprabhakaran@ufl.edu)

## Project Overview
The program searches for strings whose SHA-256 hash starts with a specified number of zeroes.
The mining work is divided into ranges and processed by worker actors under the control of a boss actor.
The implementation is designed to make use of multiple CPU cores and to support distributed workers running on other machines.

## Current Implementation
The project currently includes:
- SHA-256 hashing using Erlang's `crypto` module
- Verification of hashes with a required number of leading zeroes
- Candidate generation using a GatorLink ID and nonce
- Worker actors for processing ranges of candidate values
- A boss actor that assigns work to workers
- Dynamic assignment of new work when a worker finishes its current range
- Multiple worker actors running concurrently
- Use of the available Erlang schedulers for local parallel execution
- Command-line entry point for starting the miner

## Project Structure
```text
DOSP-Project-1-bitcoin-miner/
├── src/
│   ├── actors/
│   │   ├── bitcoin_boss.erl
│   │   └── bitcoin_worker.erl
│   ├── core/
│   │   ├── bitcoin.erl
│   │   └── bitcoin_miner.erl
│   └── utils/
│       └── bitcoin_utils.erl
├── test/
│   └── bitcoin_tests.erl
├── README.md
└── .gitignore
```

### Source Files
|Filename|Description|
|---|---|
|src/core/bitcoin.erl| Command-line entry point for the program.|
src/actors/bitcoin_boss.erl| Coordinates the mining process. It creates worker actors, assigns ranges of work receives completed results, and assigns additional work to available workers.
|src/actors/bitcoin_worker.erl|Worker actor responsible for receiving a range of candidate values, mining that range, and returning any valid coins to the boss.|
|src/core/bitcoin_miner.erl| Performs the actual mining operation over an assigned range.|
|src/utils/bitcoin_utils.erl| Contains candidate generation, SHA-256 hash conversion, and leading-zero helpers.|

## Steps to Execute
Compile the source files and test:
```bash
mkdir -p ebin
erlc -o ebin src/actors/**.erl src/core/**.erl src/utils/*.erl test/**.erl
```

Run the unit tests:
```bash
erl -noshell -pa ebin -eval 'eunit:test(bitcoin_tests, [verbose]), halt().'
```

Start Erlang with the compiled modules:
```bash
erl -pa ebin
```

The current local entry point accepts the required number of leading zeroes:
```erlang
bitcoin:main(["4"]).
```

For example, 4 searches for hashes beginning with:
```text
0000
```

The program prints each valid coin found by the server in the following format:
```text
input SHA-256-hash
```

## 
### Example 1
The project specification requires:
```text
pr.shekhawat;kjsdfk11
```
to produce:
```text
0d402337f95d018438aad6c7dd75ad6e9239d6060444a7a6b26299b261aa9a8b
```

## Actor Model
The mining work is divided among worker actors.
The boss actor maintains the work allocation and gives each worker a range of candidate values.
When a worker finishes, it sends the results back to the boss and receives another range when more work is available.
This allows multiple workers to operate concurrently while keeping work allocation centralized in the boss.

## Distributed Mining
A server will allow the remote worker running on another machine to connect and receive mining work.
The intended usage is:

**Server:**
```text
bitcoin <number_of_zeroes>
```

**Worker:**
```text
bitcoin <server_ip>
```

## Performance
The work unit is the number of candidate sub-problems assigned to a worker in one
request from the boss. The measurements below used `k = 4`, one million total
candidates, and the number of schedulers reported by
`erlang:system_info(schedulers_online)`.

The implementation is currently configured with a work unit of `10,000`
candidates. The result below is a measurement of that configuration; Results vary with hardware
and system load.

| Work unit | Real time | CPU time | CPU/real ratio |
|---:|---:|---:|---:|
| 10,000 | 0.93 seconds | 6.23 seconds | 6.70 |

For the configured work unit, the `k = 4` run searched one million candidates and
produced these valid results:
```text
kprabhakaran;78238  0000fc9bd6afb4e7dd30bff2a9f801b6804d7ec3fdddcfc48f2df7b6a0e585b5
kprabhakaran;78522  0000e1e3a2acb408262b53969a112f7e837090c62ee62149c767dc3480f6e9eb
kprabhakaran;92671  0000705faf94d50e48e2f60f28941207f18005695aa1359ac0198d5fae75fcb4
kprabhakaran;97494  00009d2473ad7c87fe92487acd95455646acf79ab7050b376128d0014615288c
kprabhakaran;109809 0000eaa5bea24d16295ca50a6a006a1cf4533001d9c3db3b636b3abc2cd9c297
kprabhakaran;182373 0000a410c2ac1c7d673ba3eac5cfa146ea95be4a1b9d624bede000f498a6502f
kprabhakaran;307605 0000f1454ed01f3003ec10630e20711342547669ff44ee6143ca9c28c267a0f5
kprabhakaran;318740 00000fbac30dde39d7f1510e2e5279f6d58e417584f25e70e3f237e284d3aa8d
kprabhakaran;425956 00007657795b1a50efa6fe8043ab5ecfe8eb210c926b31af986e783aacec17e0
kprabhakaran;502086 00000155cb961955801055882f43ec7d25625bb4f82a6ec00662270f757094d7
kprabhakaran;526279 00005b936236eabf92d6bc4288ead15ea24a70470525f0be9e2ebc5ba45c20c2
kprabhakaran;734747 000045c62b9b1b38178b7ac1ecd3b796fadfc98069ce3ce8d6613e4d2a0887ff
kprabhakaran;732964 000085e690b65d543557f82b53dbffe34e17b2b09c5c9e6754c22160e21dbad0
kprabhakaran;763526 000073723c59193ebdcaaa3ac48906b41c0d710a3c0b354f476eedaae6a0aafa
kprabhakaran;908862 0000c4b689b78c5e98a0c8d12038a593eaa69b41bdf3e4c0e690ac47553c5b0b
```

The highest result observed in that run had five
leading zeroes:
```text
kprabhakaran;318740 00000fbac30dde39d7f1510e2e5279f6d58e417584f25e70e3f237e284d3aa8d
kprabhakaran;502086 00000155cb961955801055882f43ec7d25625bb4f82a6ec00662270f757094d7
```
