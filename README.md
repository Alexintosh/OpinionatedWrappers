# ✨ Opinionated Wrappers ✨
The discussion about approve() always ends with either:

- We need to replace the ERC20 standard
- We need more opnionated wallets
- We need an alternative to the EVM

What if there is another way?
✨ Introducining Opinionated Wrappers ✨

Opinionated Wrappers (ow) are retro-compatible tokens allowing users to consistently enforce best practices without relaying on dapps and wallets to do the right thing.

An infinite approval which lives indefinitely onchain is extremely dangerous! BUT it makes sense at the standard level to allow for all options.
We should think at ERC20s as low level tech and build interfaces on top for most users instead.
Having common users deal with ERC20s is like giving them root access by default.

OW by default automatically reset the allowance to 0 after transferFrom() is called.

You can explicitly default to the classic ERC20 behaviour if needed. 

Goodbye reminding to remove approvals 👋

Dapps always ask for uint256.max, with OW users can explicitly decide to:

- Use max balance instead of uint256.max
- Revert when uint256.max is requested
- Enforce a custom value set by the user

You can always fallback to default behaviour

Shoudn't wallet and dapp be responsable?

Relaying on wallets to create safeguards will always result in inconsistent user experiences.
OW enforces user's selected best practices across all wallets and dapps.

**Can we just replace ERC20s?**

Well... No.
The is no turning back, the network effect is just to strong, it will take years to do it and it's likely to fail.
https://twitter.com/ChainLinkGod/status/1736194798598639636

**What about smart contract wallets and AA?**

First, it's not a silver bullet, the problem is likely to amplify instead.

Second, people want to use EOAs, implementing safeguards should NOT force users to switch to a completely new way of doing things!

https://twitter.com/GalloDaSballo/status/1736697338968572305


**Didn't permit fixed this?**
No, because it's again a low level tool.
It makes sense as a standard to allow the deadline to be 2000 years from now.
It doesn't make sense for 99.99% of real use cases.

https://twitter.com/StakeWithPride/status/1736228804950204425

OW enforces realistic values for using off-chain signatures with permit by limiting the most dangerous scenarios.

You can always default to the low level behaviour if needed.


----------------------------


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
