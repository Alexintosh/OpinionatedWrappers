# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

# env var check
check-env :; echo $(ETHERSCAN_API_KEY)

all: clean install build

# Clean the repo
clean :; forge clean

# Install the Modules
install :; foundryup && forge install

# setup foundry, install node modules and initialize husky
build :; forge build && yarn && yarn prepare

# Allow executable scripts
executable :; chmod +x scripts/*

# create an HTML coverage report in ./report (requires lcov & genhtml)
coverage :; forge coverage --no-match-path "test/fork/**/*.sol" --report lcov && genhtml lcov.info -o report --branch-coverage

# Run the slither container
analyze :; python3 analysis/remappings.py && ./analysis/analyze.sh

# run unit tests (and exclude fork tests)
test-unit :; forge test --no-match-path "test/fork/**/*.sol"

test-unit-gas :; forge test --no-match-path "test/fork/**/*.sol" --gas-report

# run unit tests in watch mode
test-unit-w :; forge test --no-match-path "test/fork/**/*.sol" --watch

# run only fork tests (and exclude unit)
# Note: this can take 10 - 20 minutes the first time you run it
test-fork :; forge test --match-path "test/fork/**/*t.sol"

# run all tests
test :; forge test
