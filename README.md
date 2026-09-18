# COP5615 Project 1 - Bitcoin Miner

Distributed Operating Systems Principles — Project 1

## Team

- Pradhyuman Singh Shekhawat, UFID: 55742970, Email: pr.shekhawat@ufl.edu
- Keerthana Prabhakaran, UFID: 20255736 , Email: kprabhakaran@ufl.edu

## Project Overview

This project implements a Bitcoin-like miner in Erlang using the Actor Model.

The program searches for candidate strings whose SHA-256 hash begins with a specified
number of leading zeroes. Mining work is divided into ranges and assigned to worker
actors by a boss actor.

The implementation supports:

- SHA-256 hashing
- Leading-zero verification
- GatorLink ID prefixed candidate generation
- Actor-based parallelism
- Multiple CPU cores
- Dynamic work allocation
- Distributed workers on other machines
- Automated testing
- Work-unit benchmarking

## Requirements

For a required value of `k`, the program searches for candidate strings whose
SHA-256 hash begins with `k` zeroes.

For example:

```text
k = 4
```

requires hashes beginning with:

```text
0000
```

Each candidate has the form:

```text
pr.shekhawat;<nonce>
```

The output format is:

```text
input<TAB>SHA-256-hash
```

The project specification also requires the following SHA-256 result:

```text
Input:
COP5615 is a boring class

SHA-256:
fb4431b6a2df71b6cbad961e08fa06ee6fff47e3bc14e977f4b2ea57caee48a4
```

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
├── benchmark/
│   ├── bitcoin_benchmark.erl
│   └── run_benchmark.sh
├── docs/
│   ├── benchmark_results.csv
│   ├── k4_output.txt
│   ├── k4_time.txt
│   ├── k4_summary.txt
│   └── k4_highest_zero.txt
├── run_k4.sh
├── Makefile
├── README.md
└── .gitignore
```

## Implementation

### Actor Model

The mining computation is organized using Erlang actors.

The boss actor:

1. Creates and manages worker actors.
2. Divides the nonce search space into work units.
3. Assigns ranges to workers.
4. Receives completed results from workers.
5. Assigns additional work when workers become available.
6. Tracks the completion of the complete search space.

Each worker actor receives a range of candidate nonces, performs the SHA-256
calculations, and sends discovered coins back to the boss.

This allows multiple workers to operate concurrently while keeping work allocation
centralized in the boss actor.

### Multi-Core Execution

The local server creates worker actors based on the number of online Erlang
schedulers.

For the final measurement machine:

```text
8 schedulers
8 worker actors
```

The CPU/REAL-time ratio from the final run was:

```text
5.655
```

which demonstrates concurrent CPU utilization across multiple schedulers.

## Running the Program

Compile the project:

```bash
rm -rf ebin
mkdir ebin

erlc -o ebin src/actors/*.erl src/core/*.erl src/utils/*.erl
```

Start Erlang:

```bash
erl -pa ebin
```

Run the miner by specifying the required number of leading zeroes:

```erlang
bitcoin:main(["4"]).
```

For `k = 4`, the program searches for hashes beginning with four zeroes.

## Distributed Mining

The program can also operate with workers running on other machines.

### Server

The server is started by providing the required number of leading zeroes:

```text
bitcoin <number_of_zeroes>
```

For example:

```text
bitcoin 4
```

The server creates local worker actors and waits for remote workers to connect.

### Remote Worker

A worker can connect to a server by providing the server IP address:

```text
bitcoin <server_ip>
```

For example:

```text
bitcoin 192.168.40.197
```

Remote workers do not display mining results. They receive work from the server,
perform the assigned mining computation, and return the results to the server.
The server is responsible for displaying the discovered coins.

Communication between the boss and workers uses Erlang process messaging and
distributed Erlang nodes.

## Performance

A work unit is the number of candidate sub-problems assigned to a worker in a
single request from the boss.

Different work-unit sizes were benchmarked using `k = 4` and a total search space
of one million candidates.

The benchmark results were:

| Work unit | Real time | User time | System time | CPU time | CPU/REAL |
|---:|---:|---:|---:|---:|---:|
| 1,000 | 1.14 s | 6.56 s | 0.24 s | 6.80 s | 5.965 |
| 5,000 | 1.10 s | 6.54 s | 0.28 s | 6.82 s | 6.200 |
| 10,000 | 1.10 s | 6.52 s | 0.29 s | 6.81 s | 6.191 |
| 50,000 | 1.24 s | 6.41 s | 0.27 s | 6.68 s | 5.387 |
| 100,000 | 1.50 s | 6.22 s | 0.25 s | 6.47 s | 4.313 |

The `5,000` work-unit size was selected from this benchmark because it achieved
the lowest measured real time, tied with `10,000`, while also producing the
highest CPU/REAL ratio in the measured runs.

The final implementation uses a work unit of:

```text
10,000 candidates
```

The difference between 5,000 and 10,000 was small in this benchmark, so the
final implementation retained 10,000 as the configured value.

Performance varies with hardware and system load.

## Final k = 4 Results

The final local execution used:

```text
k = 4
Total candidates = 1,000,000
Worker actors = 8
Schedulers = 8
```

The final run found:

```text
Coins found: 9

Real time: 1.19 seconds
User time: 6.50 seconds
System time: 0.23 seconds
CPU time: 6.730 seconds
CPU/REAL ratio: 5.655
```

The nine valid coins found were:

```text
pr.shekhawat;384638     0000261c062882e7487951b7b6efbfba36f727328a4eb325e855c67c24e28ad9
pr.shekhawat;531213     00004b62d9c40c384759777dfb56a4054bafdfbbd5b372ebd5a5c74b84b4e957
pr.shekhawat;548978     00003e2d5da3f6b8928946a42cefca9dfbcf629d1a58bc1ce27f757307b35f4b
pr.shekhawat;549988     00003775d931492340880ea1850c8f696c779a9bc09d9c1c8ac915bf0f42fad3
pr.shekhawat;569273     00005b1e8bf568f6627f83845289b73c0952c5285a8eff4c38c37b68d7af538b
pr.shekhawat;758163     000057e301107c11b3fa09c44bba7785685375fe61c99858c0db19bad7deacff
pr.shekhawat;844952     0000eab08bcb26bbdad7c7f4364d02cc4e8ad7eb2c8aa08af3b93e5e4f2487b3
pr.shekhawat;895091     00007e70e7208dd692ab45fb57142701406657ea8db210879be566174d9ef1b0
pr.shekhawat;988854     0000e37a4e74c52015d4a14a81f498a40adb410ebbbb02e28c0ca8db446e954f
```

### Coin with the Most Leading Zeroes

The coin with the greatest number of leading zeroes found in the final run was:

```text
pr.shekhawat;384638
```

with:

```text
0000261c062882e7487951b7b6efbfba36f727328a4eb325e855c67c24e28ad9
```

This hash contains four leading zeroes.

## Testing

The project includes an EUnit test suite covering:

- SHA-256 hashing
- Hash-to-hex conversion
- Leading-zero detection
- Candidate generation
- Mining over ranges
- The required problem-statement hash
- Worker behavior
- Boss/work allocation behavior
- Multiple worker execution

Final test result:

```text
Passed: 21
Failed: 0
```

## Distributed Testing

The distributed implementation was tested using:

```text
Server:
MacBook Pro
8 schedulers

Remote worker:
Windows laptop
4 schedulers
```

The remote worker operates without displaying mining results; discovered coins
are returned to the server.

The distributed implementation uses Erlang's actor/process messaging model for
communication between the server and remote worker.

## Documentation

Additional measurements and final execution artifacts are stored in `docs/`:

- `benchmark_results.csv` — work-unit benchmark measurements
- `k4_output.txt` — complete final `k = 4` mining output
- `k4_time.txt` — timing information
- `k4_summary.txt` — final performance summary
- `k4_highest_zero.txt` — highest leading-zero result

## Summary

The project implements a parallel and distributed Bitcoin-like miner using Erlang
actors. The boss actor manages the search space and dynamically assigns ranges to
worker actors. Workers independently perform SHA-256 mining and return valid
coins to the boss.

The final local `k = 4` execution searched one million candidates using eight
worker actors and produced nine valid coins with a CPU/REAL-time ratio of 5.655.
