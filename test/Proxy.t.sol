// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

// Interfaces
import {TBaseModule} from "../src/interfaces/IBaseModule.sol";
import {TProxy} from "../src/interfaces/IProxy.sol";

// Internals
import {Proxy} from "../src/internals/Proxy.sol";

// Fixtures
import {Harness} from "./fixtures/Harness.sol";

/**
 * @title Proxy Test
 */
contract ProxyTest is TProxy, Harness {
    // =======
    // Storage
    // =======

    Proxy public proxy;

    // =====
    // Setup
    // =====

    function setUp() public virtual override {
        super.setUp();

        proxy = new Proxy(777, 777);
    }

    // =====
    // Tests
    // =====

    function testResolveInvalidImplementationToZeroAddress() external {
        assertEq(proxy.implementation(), address(0));
    }

    function testSentinelSideEffectsDelegateCall(bytes memory data_) public BrutalizeMemory {
        // This should never happen in any actual deployments.
        vm.startPrank(address(0));

        (bool success, bytes memory data) = address(proxy).call(
            // Prepend random data input with `sentinel()` selector.
            abi.encodePacked(bytes4(keccak256("sentinel()")), data_)
        );

        // Expect `delegatecall` to return `true` on call to non-contract address.
        assertTrue(success);

        // Expect return data to be empty, result is `popped`.
        assertEq(abi.encodePacked(data), abi.encodePacked(""));

        vm.stopPrank();
    }
}
