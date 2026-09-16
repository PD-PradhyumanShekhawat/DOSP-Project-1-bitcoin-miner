# COP5615 Project 1 — Bitcoin Miner

READ ME file for Distributed Operating System Principles - Project 1 Due Date: September 21st September,2026


Team: Awesome Blossom (`TODO`: Don't forget to change this before submission)

Group members:

Pradhyuman Singh Shekhawat, UFID: 55742970, Email: pr.shekhawat@ufl.edu
Keerthana ______P________,  UFID: , Email: 

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
│   ├── bitcoin.erl
│   ├── bitcoin_boss.erl
│   ├── bitcoin_worker.erl
│   ├── bitcoin_miner.erl
│   └── bitcoin_utils.erl
├── test/
├── benchmark/
├── docs/
├── Makefile
├── README.md
└── .gitignore


Source Files

1. bitcoin.erl

Command-line entry point for the program.

2. bitcoin_boss.erl

Coordinates the mining process. It creates worker actors, assigns ranges of work,
 receives completed results, and assigns additional work to available workers.

3. bitcoin_worker.erl

Worker actor responsible for receiving a range of candidate values, 
mining that range, and returning any valid coins to the boss.

4. bitcoin_miner.erl

Performs the actual mining operation over a given range.

5. bitcoin_utils.erl

Contains utility functions for candidate generation, SHA-256 hash conversion, 
and leading-zero verification.


Running the Program

Compile the source files:

erlc -o ebin src/*.erl


Start Erlang with the compiled modules:

erl -pa ebin


The current local entry point accepts the required number of leading zeroes:

bitcoin:main(["4"]).


For example, 4 searches for hashes beginning with:

0000


The program prints each valid coin found by the server in the following format:

input<TAB>SHA-256-hash
Required Hash Verification


The project specification requires:

COP5615 is a boring class

to produce:

fb4431b6a2df71b6cbad961e08fa06ee6fff47e3bc14e977f4b2ea57caee48a4


The implementation uses SHA-256 for the required hashing operation.


Actor Model

The mining work is divided among worker actors.

The boss actor maintains the work allocation and gives each worker a range of candidate values. 
When a worker finishes, it sends the results back to the boss and receives another range when more work is available.

This allows multiple workers to operate concurrently while keeping work allocation centralized in the boss.


Distributed Mining

The final implementation will allow a worker running on another machine to connect to the server and receive mining work.

The intended usage is:


Server:
bitcoin <number_of_zeroes>

Worker:
bitcoin <server_ip>

Remote workers will not print mining results. Results will be returned to the server, 
which is responsible for displaying the discovered coins.

Performance

The project requires measuring the effect of different work-unit sizes.

A work unit is the number of candidate sub-problems assigned to a worker in one request from the boss.

The final report will include:

Work-unit size used for the final implementation
How the work-unit size was selected
Runtime for k = 4
CPU time
Real time
CPU/Real time ratio
Largest number of working machines used
Coin found with the greatest number of leading zeroes
Results

To be completed after the final benchmarking and distributed tests.

Testing

Testing will cover:

SHA-256 verification
Candidate generation
Leading-zero validation
Mining over a range
Worker/boss communication
Multiple local workers
Distributed workers
Final k = 4 execution


Requirements

This project is implemented in Erlang and uses the Actor Model for parallel and distributed computation.

The final implementation follows the project requirements for:

SHA-256 hashing
Leading-zero mining
GatorLink ID prefixing
Actor-based parallelism
Dynamic work allocation
Multi-core execution
Distributed workers
Performance measurement

