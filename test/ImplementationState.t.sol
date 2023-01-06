// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

// Vendors
import {Test} from "forge-std/Test.sol";
import {stdStorageSafe, StdStorage} from "forge-std/StdStorage.sol";

// Fixtures
import {Harness} from "./fixtures/Harness.sol";

// Tests
import {ImplementationState} from "./implementations/ImplementationState.sol";

/**
 * @title Implementation State Test
 *
 * @dev Storage layout:
 * | Name                    | Type                                                | Slot | Offset | Bytes |
 * |-------------------------|-----------------------------------------------------|------|--------|-------|
 * | _reentrancyLock         | uint256                                             | 0    | 0      | 32    |
 * | _owner                  | address                                             | 1    | 0      | 20    |
 * | _pendingOwner           | address                                             | 2    | 0      | 20    |
 * | _modules                | mapping(uint32 => address)                          | 3    | 0      | 32    |
 * | _proxies                | mapping(uint32 => address)                          | 4    | 0      | 32    |
 * | _trusts                 | mapping(address => struct TBaseState.TrustRelation) | 5    | 0      | 32    |
 * | __gap                   | uint256[44]                                         | 6    | 0      | 1408  |
 * | _implementationState0   | bytes32                                             | 50   | 0      | 32    |
 * | _implementationState1   | uint256                                             | 51   | 0      | 32    |
 * | _implementationState2   | address                                             | 52   | 0      | 20    |
 * | getImplementationState3 | address                                             | 53   | 0      | 20    |
 * | getImplementationState4 | bool                                                | 53   | 20     | 1     |
 * | _implementationState5   | mapping(address => uint256)                         | 54   | 0      | 32    |
 */
contract ImplementationStateTest is Test, Harness {
    using stdStorageSafe for StdStorage;

    // =======
    // Storage
    // =======

    ImplementationState public state;

    // =====
    // Setup
    // =====

    function setUp() public virtual {
        state = new ImplementationState();
    }

    // =====
    // Tests
    // =====

    function testVerifyStorageSlots(
        bytes32 message_,
        uint256 number_,
        address location_,
        bool flag_
    ) external BrutalizeMemory {
        state.setImplementationState0(message_);
        state.setImplementationState1(number_);
        state.setImplementationState2(location_);
        state.setImplementationState3(location_);
        state.setImplementationState4(flag_);
        state.setImplementationState5(location_, number_);

        /**
         * | Name                    | Type                                                | Slot | Offset | Bytes |
         * |-------------------------|-----------------------------------------------------|------|--------|-------|
         * | _implementationState0   | bytes32                                             | 50   | 0      | 32    |
         */
        assertEq(
            stdstore
                .target(address(state))
                .sig("getImplementationState0()")
                .find(),
            50
        );
        assertEq(
            stdstore
                .target(address(state))
                .sig("getImplementationState0()")
                .read_bytes32(),
            message_
        );

        /**
         * | Name                    | Type                                                | Slot | Offset | Bytes |
         * |-------------------------|-----------------------------------------------------|------|--------|-------|
         * | _implementationState1   | uint256                                             | 51   | 0      | 32    |
         */
        assertEq(
            stdstore
                .target(address(state))
                .sig("getImplementationState1()")
                .find(),
            51
        );
        assertEq(
            stdstore
                .target(address(state))
                .sig("getImplementationState1()")
                .read_uint(),
            number_
        );

        /**
         * | Name                    | Type                                                | Slot | Offset | Bytes |
         * |-------------------------|-----------------------------------------------------|------|--------|-------|
         * | _implementationState2   | address                                             | 52   | 0      | 20    |
         */
        assertEq(
            stdstore
                .target(address(state))
                .sig("getImplementationState2()")
                .find(),
            52
        );
        assertEq(
            stdstore
                .target(address(state))
                .sig("getImplementationState2()")
                .read_address(),
            location_
        );

        // Due to StdStorage not supporting packed slots at this point in time we access
        // the underlying storage slots directly.

        bytes32[] memory reads;
        bytes32 current;

        /**
         * | Name                    | Type                                                | Slot | Offset | Bytes |
         * |-------------------------|-----------------------------------------------------|------|--------|-------|
         * | getImplementationState3 | address                                             | 53   | 0      | 20    |
         */
        vm.record();
        state.getImplementationState3();
        (reads, ) = vm.accesses(address(state));
        assertEq(uint256(reads[0]), 53);
        current = vm.load(address(state), bytes32(reads[0]));
        assertEq(address(uint160(uint256(current))), location_);

        /**
         * | Name                    | Type                                                | Slot | Offset | Bytes |
         * |-------------------------|-----------------------------------------------------|------|--------|-------|
         * | getImplementationState4 | bool                                                | 53   | 20     | 1     |
         */
        vm.record();
        state.getImplementationState4();
        (reads, ) = vm.accesses(address(state));
        assertEq(uint256(reads[0]), 53);
        current = vm.load(address(state), bytes32(reads[0]));
        assertEq(uint8(uint256(current) >> (20 * 8)), _castBoolToUInt8(flag_));

        /**
         * | Name                    | Type                                                | Slot | Offset | Bytes |
         * |-------------------------|-----------------------------------------------------|------|--------|-------|
         * | _implementationState5   | mapping(address => uint256)                         | 54   | 0      | 32    |
         */
        vm.record();
        state.getImplementationState5(location_);
        (reads, ) = vm.accesses(address(state));
        assertEq((reads[0]), keccak256(abi.encode(location_, uint256(54))));
        current = vm.load(address(state), bytes32(reads[0]));
        assertEq(uint256(current), number_);
    }

    // TODO: add test cases around storage clashes, what happens and can they be resolved?

    // =========
    // Utilities
    // =========

    function _castBoolToUInt8(bool x) internal pure returns (uint8 r) {
        assembly {
            r := x
        }
    }
}
