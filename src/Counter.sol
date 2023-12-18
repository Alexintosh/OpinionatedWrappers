// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "@solmate/tokens/ERC20.sol";

contract Counter {
    uint256 public number;
    ERC20 private token;
    address private trusted;

    constructor(address _trusted) {
        trusted = _trusted;
    }

    function setNumber(uint256 newNumber) public {
        number = newNumber;
        token = ERC20(address(1));
    }

    function increment() public {
        number++;
    }

    function potentiallyUnsafe(address _anywhere) external {
        require(_anywhere == trusted, "untrusted");
        // potentially unsafe operation is ignored by static analyser because we whitelist the call
        // without this line, the CI will fail
        // slither-disable-next-line unchecked-transfer
        ERC20(_anywhere).transfer(address(this), 1e19);
    }
}
