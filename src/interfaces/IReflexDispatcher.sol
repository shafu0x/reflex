// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

// Interfaces
import {TReflexBase, IReflexBase} from "./IReflexBase.sol";

/**
 * @title Reflex Dispatcher Test Interface
 */
interface TReflexDispatcher is TReflexBase {
    // ======
    // Errors
    // ======

    error CallerNotTrusted();

    error InvalidOwner();

    error InvalidModuleAddress();

    error MessageTooShort();

    // ======
    // Events
    // ======

    event ModuleAdded(uint32 indexed moduleId_, address indexed moduleImplementation_, uint32 indexed moduleVersion_);

    event OwnershipTransferred(address indexed user_, address indexed newOwner_);
}

/**
 * @title Reflex Dispatcher Interface
 */
interface IReflexDispatcher is IReflexBase, TReflexDispatcher {
    // =======
    // Methods
    // =======

    function moduleIdToModuleImplementation(uint32 moduleId_) external view returns (address);

    function moduleIdToProxy(uint32 moduleId_) external view returns (address);

    function dispatch() external;
}
