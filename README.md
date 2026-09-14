# COP5615 Project 1 — Bitcoin Miner

READ ME file for Distributed Operating System Principles - Project 1 Date: September 13th September,2026

Group members:

Team 

Pradhyuman Singh Shekhawat, UFID: 55742970, pr.shekhawat@ufl.edu


## Introduction

This project implements a Bitcoin-like mining system in Erlang using the Actor Model.

The program searches for input strings whose SHA-256 hash contains the required number of leading zeroes.

Each input string is prefixed with the GatorLink ID of a team member as required by the project specification.

## Current Implementation Status

### Completed

* SHA-256 hashing using Erlang's `crypto` module
* Verification against the SHA-256 value provided in the project specification
* Conversion of SHA-256 output to hexadecimal representation
* Leading-zero validation
* Candidate generation using a GatorLink ID prefix
* Sequential mining over a specified range
* Separation of mining utilities and mining logic into modules
* Initial Erlang worker actor
* Worker-to-Boss message communication

### In Progress

<!-- * Boss actor
* Multiple worker actors
* Dynamic work assignment
* Multi-core performance optimization
* Work-unit size benchmarking
* Distributed server/worker implementation
* Multi-machine testing
* Final performance measurements -->


## SHA-256 Verification

The project specification provides the following test:

Input:

```text
COP5615 is a boring class
```

Expected SHA-256:

```text
fb4431b6a2df71b6cbad961e08fa06ee6fff47e3bc14e977f4b2ea57caee48a4
```

The implementation produces the expected value.

## Mining

For a required difficulty of `K = 4`, the program searches candidate inputs and checks whether their SHA-256 hash begins with at least four zeroes.

Example structure of a candidate:

```text
GATOR_LINK_ID;NONCE
```

Example:

```text
55742970;9401
```

A valid result has a hash beginning with:

```text
0000
```



To be continued ...



