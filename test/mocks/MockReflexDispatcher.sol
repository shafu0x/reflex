// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

// Sources
import {ReflexDispatcher} from "../../src/ReflexDispatcher.sol";

/**
 * @title Mock Reflex Dispatcher
 */
contract MockReflexDispatcher is ReflexDispatcher {
    // ===========
    // Constructor
    // ===========

    constructor(address owner_, address installerModule_) ReflexDispatcher(owner_, installerModule_) {}
}