// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

// Mocks
import {MockImplementationState} from "./MockImplementationState.sol";
import {MockReflexModule} from "./MockReflexModule.sol";

/**
 * @title Mock Implementation Module
 */
contract MockImplementationModule is MockReflexModule, MockImplementationState {
    // ===========
    // Constructor
    // ===========

    /**
     * @param moduleSettings_ Module settings.
     */
    constructor(ModuleSettings memory moduleSettings_) MockReflexModule(moduleSettings_) {}
}