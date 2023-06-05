// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

// Sources
import {ReflexBase} from "../../src/ReflexBase.sol";

// Mocks
import {MockReflexEndpoint} from "./MockReflexEndpoint.sol";

/**
 * @title Mock Reflex Base
 */
contract MockReflexBase is ReflexBase {
    // =========
    // Constants
    // =========

    /**
     * @dev `bytes32(uint256(keccak256("reentrancy.counter")) - 1)`
     */
    bytes32 internal constant _REENTRANCY_COUNTER_SLOT =
        0xc2db8520a4cb85e45c0b428b71b461e7932f3b9c2b41fa1662675e79660783f2;

    // ===========
    // Constructor
    // ===========

    constructor() {
        _reentrancyStatus = _REENTRANCY_GUARD_UNLOCKED;
    }

    // ==========
    // Test stubs
    // ==========

    function reentrancyCounter() public view returns (uint256 n_) {
        n_ = _getCounter(_REENTRANCY_COUNTER_SLOT);
    }

    function getReentrancyStatus() public view returns (uint256) {
        return _reentrancyStatus;
    }

    function getReentrancyStatusLocked() public view returns (bool) {
        return _reentrancyStatusLocked();
    }

    function callback() external nonReentrant {
        _increaseCounter(_REENTRANCY_COUNTER_SLOT);
    }

    function countDirectRecursive(uint256 n_) public nonReentrant {
        if (n_ > 0) {
            _increaseCounter(_REENTRANCY_COUNTER_SLOT);
            countDirectRecursive(n_ - 1);
        }
    }

    function countIndirectRecursive(uint256 n_) public nonReentrant {
        if (n_ > 0) {
            _increaseCounter(_REENTRANCY_COUNTER_SLOT);

            (bool success, bytes memory data) = address(this).call(
                abi.encodeWithSignature("countIndirectRecursive(uint256)", n_ - 1)
            );

            if (!success) _revertBytes(data);
        }
    }

    function countAndCall(ReentrancyAttack attacker_) public nonReentrant {
        _increaseCounter(_REENTRANCY_COUNTER_SLOT);

        attacker_.callSender(bytes4(keccak256("callback()")));
    }

    function guardedCheckLocked() public nonReentrant {
        assert(getReentrancyStatusLocked());
        assert(getReentrancyStatus() == _REENTRANCY_GUARD_LOCKED);
    }

    function readCallbackTargetUnprotected() public {}

    function readCallbackTargetProtected() public nonReadReentrant {}

    function readGuardedCheckProtected() public nonReentrant {
        assert(getReentrancyStatusLocked());
        assert(getReentrancyStatus() == _REENTRANCY_GUARD_LOCKED);

        readCallbackTargetProtected();
    }

    function readGuardedCheckUnprotected() public nonReentrant {
        assert(getReentrancyStatusLocked());
        assert(getReentrancyStatus() == _REENTRANCY_GUARD_LOCKED);

        readCallbackTargetUnprotected();
    }

    function unguardedCheckUnlocked() public view {
        assert(!getReentrancyStatusLocked());
        assert(getReentrancyStatus() == _REENTRANCY_GUARD_UNLOCKED);
    }

    function createEndpoint(
        uint32 moduleId_,
        uint16 moduleType_,
        address moduleImplementation_
    ) public returns (address) {
        return _createEndpoint(moduleId_, moduleType_, moduleImplementation_);
    }

    function callInternalModule(uint32 moduleId_, bytes memory input_) public returns (bytes memory) {
        return _callInternalModule(moduleId_, input_);
    }

    function revertBytes(bytes memory errorMessage_) public pure {
        return _revertBytes(errorMessage_);
    }

    // =========
    // Utilities
    // =========

    function _getCounter(bytes32 slot_) internal view returns (uint256 n_) {
        assembly ("memory-safe") {
            n_ := sload(slot_)
        }
    }

    function _setCounter(bytes32 slot_, uint256 n_) internal {
        assembly ("memory-safe") {
            sstore(slot_, n_)
        }
    }

    function _increaseCounter(bytes32 slot_) internal {
        uint256 value = _getCounter(slot_);
        _setCounter(slot_, value + 1);
    }
}

// =========
// Utilities
// =========

contract ReentrancyAttack {
    // ======
    // Errors
    // ======

    error ReentrancyAttackFailed();

    // ==========
    // Test stubs
    // ==========

    function callSender(bytes4 data) external {
        (bool success, ) = msg.sender.call(abi.encodeWithSelector(data));

        if (!success) revert ReentrancyAttackFailed();
    }
}
