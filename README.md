# Smart Contract Boilerplate

![Status][test-status]

This is a starter package for setting up a new Foundry project for Auxo. It builds on the foundry starter with a few additional setup steps and defined conventions that we use in Auxo projects.

# Setup

Ensure you have nodejs, yarn and [foundry](https://book.getfoundry.sh/getting-started/installation) installed. Docker is recommended for locally running static analysis.

You can install dependencies with the following command:

```sh
forge build && yarn
```

# CI

Continuous integration is setup via [Github actions](./.github/workflows/run-tests.yml). The following checks are run:

-   Check Formatting has been run with `forge fmt`
-   Run the test suite with `forge test`
-   Check no 'high' or 'medium' priority vulnerabilities are left unaddressed in the static analyser

# Conventions

Below are a list of recommended conventions. Most of these are optional but will give a consistent style between contracts.

## Formatting

Formatting is handled by `forge fmt`. We use the default settings provided by foundry.
You can enable format on save in your own editor but out the box it's not setup. The CI hook will reject any PRs where the formatter has not been run.

A small `.editorconfig` file has been added that standardises things like line endings and indentation, this matches `forge fmt` so the style won't change drastically when you save.

## Linting

`solhint` is installed to provide additional inline linting recommendations for code conventions. You must have NodeJS running for it to work.

## Imports and Remappings

We use import remappings to resolve import paths. Remappings should be prefixed with an `@` symbol and added to `remappings.txt`, in the format:

> Note: ds-test is used internally by forge-std and so leave it as it is.

```
@[shortcut]/=[original-path]/
```

For example:

```
@solmate/=lib/solmate/src/
```

> Remappings may need to be added in multiple config files so that they can be accessed by different tools. For Slither, run `python3 analysis/remappings.py` to add the existing remappings to a `slither.config.json` file.

# Tests

Run tests:

```
forge test [--mp path/to/test/file.sol]
```

Fetch coverage

```
forge coverage
```

# Static Analysis

You can perform static analysis on your contracts using [Slither](https://github.com/crytic/slither). This will run a series of checks against known exploits and highlight where issues may be raised.

## Installing

Slither has a number of dependencies and configuration settings before it can work. You are welcome to install these yourself, but the Dockerfile will handle all of this for you.

There is also an official [Trail of Bits security toolkit](https://github.com/trailofbits/eth-security-toolbox/) you can use, we will not go into detail here.

Both the toolkit and the Dockerfile require docker to be installed. I also recommend you run docker using WSL if you're using Windows.

## Running the Container

The Dockerfile installs dependencies and creates a `/work` directory which mounts the current working directory.

```sh
# make run script executable
chmod +x analyze.sh

# run the docker command
./analyze.sh
```

The analyze script builds and runs the container before dropping you into a shell. You can run slither from there with the `slither` command. You may need to change the solidity compiler you are using, in which case run `solc-select` to get a list of options for installing and selecting specific compilers.

## Addressing issues

CI will fail on unaddressed 'high' or 'medium' issues. These can either be ignored by adding inline comments to solidity files OR using the `--triage-mode` flag provided by slither.

An example inline comment:

```js
function potentiallyUnsafe(address _anywhere) external {
    require(_anywhere == trusted, "untrusted");
    // potentially unsafe operation is ignored by static analyser because we whitelist the call
    // without the next line, the CI will fail
    // slither-disable-next-line unchecked-transfer
    ERC20(_anywhere).transfer(address(this), 1e19);
}
```

# Badges

Edit the markdown in this section to customise badges here.

[test-status]: https://github.com/AuxoDAO/foundry-template/actions/workflows/forge-test.yml/badge.svg

# References

Config Reference for Foundry:

-   https://book.getfoundry.sh/reference/config/
