ERLC = erlc
EBIN = ebin

SOURCES = \
	src/utils/bitcoin_utils.erl \
	src/core/bitcoin_miner.erl \
	src/actors/bitcoin_worker.erl \
	src/actors/bitcoin_boss.erl \
	src/core/bitcoin.erl

TEST = test/bitcoin_tests.erl

.PHONY: all compile test clean benchmark

all: compile

compile:
	mkdir -p $(EBIN)
	$(ERLC) -o $(EBIN) $(SOURCES)

test: compile
	$(ERLC) -o $(EBIN) -pa $(EBIN) $(TEST)
	erl -noshell -pa $(EBIN) -eval "eunit:test(bitcoin_tests, [verbose]), init:stop()."

benchmark: compile
	cd benchmark && ./run_benchmark.sh

clean:
	rm -f $(EBIN)/*.beam