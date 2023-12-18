// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC20, ERC20} from "@oz/token/ERC20/ERC20.sol";
import {ERC20Wrapper} from "@oz/token/ERC20/extensions/ERC20Wrapper.sol";
import {ERC20Permit} from "@oz/token/ERC20/extensions/ERC20Permit.sol";


/**
 * @title Opinionated Wrappers
 * @author Alexintosh
 * @notice 
 * 
 * *Features:*
 * Auto reset allowance after transfer from
 * Revert on infinite approval or use mitigation strategies
 * Enforce Time based approval in permit (nobody needs it for 200 years)
 * 
 */
abstract contract owERC20 is ERC20Wrapper, ERC20Permit {

    // Available settings regaring the use of Allowance
    enum SettingsAllowance {
        RemoveAllowance,
        DefaultERC20
    }

    // Available settings regaring the use of Approve
    enum SettingsApprove {
        MaxBalanceOverInfinite,
        RevertOnInfinite,
        UseMaxAllowedValue,
        DefaultERC20
    }

    // Available settings regaring the use of Permit
    enum SettingsPermit {
        OneMinute,
        ThirtyMinute, // Probably best for most cases, considering RFQ take time
        Custom,
        DefaultERC20
    }
    
    mapping (address => SettingsAllowance) uAllowanceSetting;
    mapping (address => SettingsApprove) uApproveSetting;
    mapping (address => uint256) uApproveSettingMaxAllowedValue;
    mapping (address => SettingsPermit) uPermitSetting;
    mapping (address => uint256) uPermitCustomSetting;

    constructor(IERC20 _underlying) ERC20Wrapper(_underlying) {
    }

    function decimals() public view override(ERC20, ERC20Wrapper) returns (uint8) {
        super.decimals();
    }

    /**
     * @dev Modified behaviour of {IERC20-approve} to match user preferences.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public override(ERC20) virtual returns (bool) {
        address owner = _msgSender();
        SettingsApprove preference = uApproveSetting[owner];

        // behaves as usual
        if(value != type(uint256).max || preference == SettingsApprove.DefaultERC20) {
            _approve(owner, spender, value);
            return true;
        }
        
        // Use max balance instead of infinite
        if(preference == SettingsApprove.MaxBalanceOverInfinite) {
            _approve(owner, spender, balanceOf(owner));
        }

        if(preference == SettingsApprove.RevertOnInfinite) {
            revert("uint256.max not allowed");
        }

        if(preference == SettingsApprove.UseMaxAllowedValue) {
            uint256 _val = value > uApproveSettingMaxAllowedValue[owner] ? uApproveSettingMaxAllowedValue[owner] : value;
            _approve(owner, spender, _val);
        }

        return true;
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `value` and User Settings.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 value) internal override(ERC20) virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }

            // @notice By default approval is always set to zero after transferFrom is called
            if(uAllowanceSetting[owner] == SettingsAllowance.RemoveAllowance) {
                unchecked {
                    _approve(owner, spender, 0, false);
                }    
            } else {
                unchecked {
                    _approve(owner, spender, currentAllowance - value, false);
                }
            }
        }
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public override(ERC20Permit) virtual {
        uint256 oDeadline;

        if(uPermitSetting[owner] == SettingsPermit.OneMinute) oDeadline = block.timestamp + 1 minutes;
        if(uPermitSetting[owner] == SettingsPermit.ThirtyMinute) oDeadline = block.timestamp + 30 minutes;
        if(uPermitSetting[owner] == SettingsPermit.Custom) oDeadline = block.timestamp + uPermitCustomSetting[owner];
        if(uPermitSetting[owner] == SettingsPermit.DefaultERC20) oDeadline = deadline;

        super.permit(owner, spender, value, oDeadline, v, r, s);
    }

    // TODO
    // setters

}
