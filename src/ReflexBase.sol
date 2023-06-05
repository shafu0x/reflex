// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

// Interfaces
import {IReflexBase} from "./interfaces/IReflexBase.sol";

// Sources
import {ReflexEndpoint} from "./ReflexEndpoint.sol";
import {ReflexState} from "./ReflexState.sol";

/**
 * @title Reflex Base
 *
 * @dev Upgradeable, extendable.
 */
abstract contract ReflexBase is IReflexBase, ReflexState {
    // =========
    // Modifiers
    // =========

    /**
     * @dev Explicitly tag a method as being allowed to be reentered.
     */
    modifier reentrancyAllowed() virtual {
        _;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant` function is not supported.
     */
    modifier nonReentrant() virtual {
        // On the first call to `nonReentrant`, _status will be `_REENTRANCY_GUARD_UNLOCKED`.
        if (_reentrancyStatus != _REENTRANCY_GUARD_UNLOCKED) revert Reentrancy();

        // Any calls to `nonReentrant` after this point will fail.
        _reentrancyStatus = _REENTRANCY_GUARD_LOCKED;

        _;

        // By storing the original value once again, a refund is triggered.
        _reentrancyStatus = _REENTRANCY_GUARD_UNLOCKED;
    }

    /**
     * @dev Prevents a contract from reading itself, directly or indirectly in a `nonReentrant` context.
     * Calling a `nonReadReentrant` function from another `nonReadReentrant` function is not supported.
     */
    modifier nonReadReentrant() virtual {
        if (_reentrancyStatusLocked()) revert ReadOnlyReentrancy();

        _;
    }

    // ================
    // Internal methods
    // ================

    /**
     * @dev Create or return existing endpoint by module id.
     * @param moduleId_ Module id.
     * @param moduleType_ Module type.
     * @param moduleImplementation_ Module implementation.
     * @return endpointAddress_ Endpoint address.
     */
    function _createEndpoint(
        uint32 moduleId_,
        uint16 moduleType_,
        address moduleImplementation_
    ) internal virtual returns (address endpointAddress_) {
        if (moduleId_ == 0) revert InvalidModuleId();
        if (moduleType_ != _MODULE_TYPE_SINGLE_ENDPOINT && moduleType_ != _MODULE_TYPE_MULTI_ENDPOINT)
            revert InvalidModuleType();

        if (_endpoints[moduleId_] != address(0)) return _endpoints[moduleId_];

        bytes memory endpointCreationCode = _getEndpointCreationCode(moduleId_);

        assembly ("memory-safe") {
            endpointAddress_ := create(0, add(endpointCreationCode, 0x20), mload(endpointCreationCode))

            // If the code size of `endpointAddress_` is zero, revert.
            if iszero(extcodesize(endpointAddress_)) {
                // Store the function selector of `InvalidEndpoint()`.
                mstore(0x00, 0xf1cbb567)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
        }

        if (moduleType_ == _MODULE_TYPE_SINGLE_ENDPOINT) _endpoints[moduleId_] = endpointAddress_;

        _relations[endpointAddress_] = TrustRelation({
            moduleId: moduleId_,
            moduleType: moduleType_,
            moduleImplementation: moduleImplementation_
        });

        emit EndpointCreated(endpointAddress_);
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to ` _REENTRANCY_GUARD_LOCKED`
     * which indicates there is a `nonReentrant` function in the call stack.
     * @return bool Whether the reentrancy guard is locked.
     */
    function _reentrancyStatusLocked() internal view virtual returns (bool) {
        return _reentrancyStatus == _REENTRANCY_GUARD_LOCKED;
    }

    /**
     * @dev Perform delegatecall to trusted internal module.
     * @param moduleId_ Module id.
     * @param input_ Input data.
     * @return bytes Call result.
     */
    function _callInternalModule(uint32 moduleId_, bytes memory input_) internal returns (bytes memory) {
        (bool success, bytes memory result) = _modules[moduleId_].delegatecall(input_);

        if (!success) _revertBytes(result);

        return result;
    }

    /**
     * @notice Called to get the endpoint implementation for endpoint creation.
     * @dev Method intended to be overriden.
     * @param moduleId_ Module id.
     * @return bytes Endpoint creation code.
     */
    function _getEndpointCreationCode(uint32 moduleId_) internal pure virtual returns (bytes memory) {
        return abi.encodePacked(type(ReflexEndpoint).creationCode, abi.encode(moduleId_));
    }

    /**
     * @dev Unpack message sender from calldata.
     * @return messageSender_ Message sender.
     */
    function _unpackMessageSender() internal pure virtual returns (address messageSender_) {
        // Calldata: [original calldata (N bytes)][original msg.sender (20 bytes)][endpoint address (20 bytes)]
        assembly ("memory-safe") {
            messageSender_ := shr(96, calldataload(sub(calldatasize(), 40)))
        }
    }

    /**
     * @dev Unpack endpoint address from calldata.
     * @return endpointAddress_ Endpoint address.
     */
    function _unpackEndpointAddress() internal pure virtual returns (address endpointAddress_) {
        // Calldata: [original calldata (N bytes)][original msg.sender (20 bytes)][endpoint address (20 bytes)]
        assembly ("memory-safe") {
            endpointAddress_ := shr(96, calldataload(sub(calldatasize(), 20)))
        }
    }

    /**
     * @dev Unpack trailing parameters from calldata.
     * @return messageSender_ Message sender.
     * @return endpointAddress_ Endpoint address.
     */
    function _unpackTrailingParameters()
        internal
        pure
        virtual
        returns (address messageSender_, address endpointAddress_)
    {
        // Calldata: [original calldata (N bytes)][original msg.sender (20 bytes)][endpoint address (20 bytes)]
        assembly ("memory-safe") {
            messageSender_ := shr(96, calldataload(sub(calldatasize(), 40)))
            endpointAddress_ := shr(96, calldataload(sub(calldatasize(), 20)))
        }
    }

    /**
     * @dev Bubble up revert with error message.
     * @param errorMessage_ Error message.
     */
    function _revertBytes(bytes memory errorMessage_) internal pure {
        if (errorMessage_.length > 0) {
            assembly ("memory-safe") {
                revert(add(32, errorMessage_), mload(errorMessage_))
            }
        }

        revert EmptyError();
    }
}
