// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

// Interfaces
import {TReflexInstaller} from "../src/interfaces/IReflexInstaller.sol";
import {IReflexModule} from "../src/interfaces/IReflexModule.sol";

// Fixtures
import {ReflexFixture} from "./fixtures/ReflexFixture.sol";

// Mocks
import {MockReflexInstaller} from "./mocks/MockReflexInstaller.sol";
import {MockReflexModule} from "./mocks/MockReflexModule.sol";

/**
 * @title Reflex Installer Test
 */
contract ReflexInstallerTest is TReflexInstaller, ReflexFixture {
    // =========
    // Constants
    // =========

    bytes4 internal constant _VALID = 0;

    uint32 internal constant _MODULE_SINGLE_ID = 100;
    uint16 internal constant _MODULE_SINGLE_TYPE = _MODULE_TYPE_SINGLE_ENDPOINT;
    uint16 internal constant _MODULE_SINGLE_VERSION_V1 = 1;
    uint16 internal constant _MODULE_SINGLE_VERSION_V2 = 2;
    uint16 internal constant _MODULE_SINGLE_VERSION_V3 = 3;
    uint16 internal constant _MODULE_SINGLE_VERSION_V4 = 4;
    bool internal constant _MODULE_SINGLE_UPGRADEABLE_V1 = true;
    bool internal constant _MODULE_SINGLE_UPGRADEABLE_V2 = true;
    bool internal constant _MODULE_SINGLE_UPGRADEABLE_V3 = false;
    bool internal constant _MODULE_SINGLE_UPGRADEABLE_V4 = false;

    uint32 internal constant _MODULE_MULTI_ID = 101;
    uint16 internal constant _MODULE_MULTI_TYPE = _MODULE_TYPE_MULTI_ENDPOINT;
    uint16 internal constant _MODULE_MULTI_VERSION_V1 = 1;
    uint16 internal constant _MODULE_MULTI_VERSION_V2 = 2;
    uint16 internal constant _MODULE_MULTI_VERSION_V3 = 3;
    uint16 internal constant _MODULE_MULTI_VERSION_V4 = 4;
    bool internal constant _MODULE_MULTI_UPGRADEABLE_V1 = true;
    bool internal constant _MODULE_MULTI_UPGRADEABLE_V2 = true;
    bool internal constant _MODULE_MULTI_UPGRADEABLE_V3 = false;
    bool internal constant _MODULE_MULTI_UPGRADEABLE_V4 = false;

    uint32 internal constant _MODULE_INTERNAL_ID = 102;
    uint16 internal constant _MODULE_INTERNAL_TYPE = _MODULE_TYPE_INTERNAL;
    uint16 internal constant _MODULE_INTERNAL_VERSION_V1 = 1;
    uint16 internal constant _MODULE_INTERNAL_VERSION_V2 = 2;
    uint16 internal constant _MODULE_INTERNAL_VERSION_V3 = 3;
    uint16 internal constant _MODULE_INTERNAL_VERSION_V4 = 4;
    bool internal constant _MODULE_INTERNAL_UPGRADEABLE_V1 = true;
    bool internal constant _MODULE_INTERNAL_UPGRADEABLE_V2 = true;
    bool internal constant _MODULE_INTERNAL_UPGRADEABLE_V3 = false;
    bool internal constant _MODULE_INTERNAL_UPGRADEABLE_V4 = false;

    // =======
    // Storage
    // =======

    MockReflexModule public singleModuleV1;
    MockReflexModule public singleModuleV2;
    MockReflexModule public singleModuleV3;

    MockReflexModule public multiModuleV1;
    MockReflexModule public multiModuleV2;
    MockReflexModule public multiModuleV3;

    MockReflexModule public internalModuleV1;
    MockReflexModule public internalModuleV2;
    MockReflexModule public internalModuleV3;

    // =====
    // Setup
    // =====

    function setUp() public virtual override {
        super.setUp();

        // Scenario:
        // - V1 is the initial module.
        // - V2 is the next version, still upgradeable.
        // - V3 is the next version, not upgradeable.
        // - V4 is never used, expected to throw.

        singleModuleV1 = new MockReflexModule(
            IReflexModule.ModuleSettings({
                moduleId: _MODULE_SINGLE_ID,
                moduleType: _MODULE_SINGLE_TYPE,
                moduleVersion: _MODULE_SINGLE_VERSION_V1,
                moduleUpgradeable: _MODULE_SINGLE_UPGRADEABLE_V1
            })
        );

        singleModuleV2 = new MockReflexModule(
            IReflexModule.ModuleSettings({
                moduleId: _MODULE_SINGLE_ID,
                moduleType: _MODULE_SINGLE_TYPE,
                moduleVersion: _MODULE_SINGLE_VERSION_V2,
                moduleUpgradeable: _MODULE_SINGLE_UPGRADEABLE_V2
            })
        );

        singleModuleV3 = new MockReflexModule(
            IReflexModule.ModuleSettings({
                moduleId: _MODULE_SINGLE_ID,
                moduleType: _MODULE_SINGLE_TYPE,
                moduleVersion: _MODULE_SINGLE_VERSION_V3,
                moduleUpgradeable: _MODULE_SINGLE_UPGRADEABLE_V3
            })
        );

        multiModuleV1 = new MockReflexModule(
            IReflexModule.ModuleSettings({
                moduleId: _MODULE_MULTI_ID,
                moduleType: _MODULE_MULTI_TYPE,
                moduleVersion: _MODULE_MULTI_VERSION_V1,
                moduleUpgradeable: _MODULE_MULTI_UPGRADEABLE_V1
            })
        );

        multiModuleV2 = new MockReflexModule(
            IReflexModule.ModuleSettings({
                moduleId: _MODULE_MULTI_ID,
                moduleType: _MODULE_MULTI_TYPE,
                moduleVersion: _MODULE_MULTI_VERSION_V2,
                moduleUpgradeable: _MODULE_MULTI_UPGRADEABLE_V2
            })
        );

        multiModuleV3 = new MockReflexModule(
            IReflexModule.ModuleSettings({
                moduleId: _MODULE_MULTI_ID,
                moduleType: _MODULE_MULTI_TYPE,
                moduleVersion: _MODULE_MULTI_VERSION_V3,
                moduleUpgradeable: _MODULE_MULTI_UPGRADEABLE_V3
            })
        );

        internalModuleV1 = new MockReflexModule(
            IReflexModule.ModuleSettings({
                moduleId: _MODULE_INTERNAL_ID,
                moduleType: _MODULE_INTERNAL_TYPE,
                moduleVersion: _MODULE_INTERNAL_VERSION_V1,
                moduleUpgradeable: _MODULE_INTERNAL_UPGRADEABLE_V1
            })
        );

        internalModuleV2 = new MockReflexModule(
            IReflexModule.ModuleSettings({
                moduleId: _MODULE_INTERNAL_ID,
                moduleType: _MODULE_INTERNAL_TYPE,
                moduleVersion: _MODULE_INTERNAL_VERSION_V2,
                moduleUpgradeable: _MODULE_INTERNAL_UPGRADEABLE_V2
            })
        );

        internalModuleV3 = new MockReflexModule(
            IReflexModule.ModuleSettings({
                moduleId: _MODULE_INTERNAL_ID,
                moduleType: _MODULE_INTERNAL_TYPE,
                moduleVersion: _MODULE_INTERNAL_VERSION_V3,
                moduleUpgradeable: _MODULE_INTERNAL_UPGRADEABLE_V3
            })
        );
    }

    // =====
    // Tests
    // =====

    function testUnitModuleSettings() external {
        _verifyModuleConfiguration(
            singleModuleV1,
            _MODULE_SINGLE_ID,
            _MODULE_SINGLE_TYPE,
            _MODULE_SINGLE_VERSION_V1,
            _MODULE_SINGLE_UPGRADEABLE_V1
        );

        _verifyModuleConfiguration(
            singleModuleV2,
            _MODULE_SINGLE_ID,
            _MODULE_SINGLE_TYPE,
            _MODULE_SINGLE_VERSION_V2,
            _MODULE_SINGLE_UPGRADEABLE_V2
        );

        _verifyModuleConfiguration(
            singleModuleV3,
            _MODULE_SINGLE_ID,
            _MODULE_SINGLE_TYPE,
            _MODULE_SINGLE_VERSION_V3,
            _MODULE_SINGLE_UPGRADEABLE_V3
        );

        _verifyModuleConfiguration(
            multiModuleV1,
            _MODULE_MULTI_ID,
            _MODULE_MULTI_TYPE,
            _MODULE_MULTI_VERSION_V1,
            _MODULE_MULTI_UPGRADEABLE_V1
        );

        _verifyModuleConfiguration(
            multiModuleV2,
            _MODULE_MULTI_ID,
            _MODULE_MULTI_TYPE,
            _MODULE_MULTI_VERSION_V2,
            _MODULE_MULTI_UPGRADEABLE_V2
        );

        _verifyModuleConfiguration(
            multiModuleV3,
            _MODULE_MULTI_ID,
            _MODULE_MULTI_TYPE,
            _MODULE_MULTI_VERSION_V3,
            _MODULE_MULTI_UPGRADEABLE_V3
        );

        _verifyModuleConfiguration(
            internalModuleV1,
            _MODULE_INTERNAL_ID,
            _MODULE_INTERNAL_TYPE,
            _MODULE_INTERNAL_VERSION_V1,
            _MODULE_INTERNAL_UPGRADEABLE_V1
        );

        _verifyModuleConfiguration(
            internalModuleV2,
            _MODULE_INTERNAL_ID,
            _MODULE_INTERNAL_TYPE,
            _MODULE_INTERNAL_VERSION_V2,
            _MODULE_INTERNAL_UPGRADEABLE_V2
        );

        _verifyModuleConfiguration(
            internalModuleV3,
            _MODULE_INTERNAL_ID,
            _MODULE_INTERNAL_TYPE,
            _MODULE_INTERNAL_VERSION_V3,
            _MODULE_INTERNAL_UPGRADEABLE_V3
        );
    }

    // ===============
    // Ownership tests
    // ===============

    function testFuzzTransferOwnership(address user_) external {
        vm.assume(user_ != address(0));

        assertEq(installerEndpoint.owner(), address(this));
        assertEq(installerEndpoint.pendingOwner(), address(0));

        vm.expectEmit(true, false, false, false);
        emit OwnershipTransferStarted(address(this), user_);
        installerEndpoint.transferOwnership(user_);

        assertEq(installerEndpoint.owner(), address(this));
        assertEq(installerEndpoint.pendingOwner(), user_);
    }

    function testFuzzRevertTransferOwnershipNotOwner(address user_) external {
        vm.assume(user_ != address(0) && user_ != installerEndpoint.owner() && user_ != address(dispatcher));
        assumeNoPrecompiles(user_);

        vm.startPrank(user_);

        vm.expectRevert(Unauthorized.selector);
        installerEndpoint.transferOwnership(_users.Alice);

        vm.stopPrank();
    }

    function testFuzzAcceptOwnership(address user_) external {
        vm.assume(user_ != address(0) && user_ != address(dispatcher));
        assumeNoPrecompiles(user_);

        assertEq(installerEndpoint.owner(), address(this));
        assertEq(installerEndpoint.pendingOwner(), address(0));

        vm.expectEmit(true, false, false, false);
        emit OwnershipTransferStarted(address(this), user_);
        installerEndpoint.transferOwnership(user_);

        assertEq(installerEndpoint.owner(), address(this));
        assertEq(installerEndpoint.pendingOwner(), user_);

        vm.startPrank(user_);

        vm.expectEmit(true, false, false, false);
        emit OwnershipTransferred(address(this), user_);
        installerEndpoint.acceptOwnership();

        vm.stopPrank();

        assertEq(installerEndpoint.owner(), user_);
        assertEq(installerEndpoint.pendingOwner(), address(0));
    }

    function testFuzzRevertTransferOwnershipNotPendingOwner(address user_, address target_) external {
        vm.assume(user_ != address(0) && target_ != address(0) && user_ != target_ && user_ != address(dispatcher));
        assumeNoPrecompiles(user_);
        assumeNoPrecompiles(target_);

        assertEq(installerEndpoint.owner(), address(this));
        assertEq(installerEndpoint.pendingOwner(), address(0));

        vm.expectEmit(true, false, false, false);
        emit OwnershipTransferStarted(address(this), target_);
        installerEndpoint.transferOwnership(target_);

        assertEq(installerEndpoint.owner(), address(this));
        assertEq(installerEndpoint.pendingOwner(), target_);

        vm.startPrank(user_);

        vm.expectRevert(Unauthorized.selector);
        installerEndpoint.acceptOwnership();

        vm.stopPrank();

        assertEq(installerEndpoint.owner(), address(this));
        assertEq(installerEndpoint.pendingOwner(), target_);
    }

    function testUnitRenounceOwnership() external {
        assertEq(installerEndpoint.owner(), address(this));
        assertEq(installerEndpoint.pendingOwner(), address(0));

        vm.expectEmit(true, false, false, false);
        emit OwnershipTransferred(address(this), address(0));
        installerEndpoint.renounceOwnership();

        assertEq(installerEndpoint.owner(), address(0));
        assertEq(installerEndpoint.pendingOwner(), address(0));
    }

    function testFuzzRenounceOwnershipWithPendingOwner(address user_) external {
        vm.assume(user_ != address(0));
        assumeNoPrecompiles(user_);

        assertEq(installerEndpoint.owner(), address(this));
        assertEq(installerEndpoint.pendingOwner(), address(0));

        vm.expectEmit(true, false, false, false);
        emit OwnershipTransferStarted(address(this), user_);
        installerEndpoint.transferOwnership(user_);

        assertEq(installerEndpoint.owner(), address(this));
        assertEq(installerEndpoint.pendingOwner(), user_);

        vm.expectEmit(true, false, false, false);
        emit OwnershipTransferred(address(this), address(0));
        installerEndpoint.renounceOwnership();

        assertEq(installerEndpoint.owner(), address(0));
        assertEq(installerEndpoint.pendingOwner(), address(0));
    }

    function testFuzzRevertRenounceOwnershipNotOwner(address user_) external {
        vm.assume(user_ != address(0) && user_ != installerEndpoint.owner() && user_ != address(dispatcher));
        assumeNoPrecompiles(user_);

        vm.startPrank(user_);

        vm.expectRevert(Unauthorized.selector);
        installerEndpoint.renounceOwnership();

        vm.stopPrank();
    }

    function testUnitRevertTransferOwnershipZeroAddress() external {
        vm.expectRevert(ZeroAddress.selector);
        installerEndpoint.transferOwnership(address(0));
    }

    // ============
    // Module tests
    // ============

    function testUnitRevertAddNonContract() external {
        address[] memory moduleAddresses = new address[](1);
        moduleAddresses[0] = address(1);

        vm.expectRevert();
        installerEndpoint.addModules(moduleAddresses);
    }

    function testUnitRevertNonModuleIdContract() external {
        address[] memory moduleAddresses = new address[](1);
        moduleAddresses[0] = address(dispatcher);

        vm.expectRevert();
        installerEndpoint.addModules(moduleAddresses);
    }

    function testUnitRevertUpgradeModulesModuleNonexistent() external {
        address[] memory moduleAddresses = new address[](1);
        moduleAddresses[0] = address(
            new MockReflexModule(
                IReflexModule.ModuleSettings({
                    moduleId: 777,
                    moduleType: _MODULE_SINGLE_TYPE,
                    moduleVersion: 777,
                    moduleUpgradeable: true
                })
            )
        );

        vm.expectRevert(abi.encodeWithSelector(ModuleNonexistent.selector, 777));
        installerEndpoint.upgradeModules(moduleAddresses);
    }

    function testUnitRevertUpgradeModulesNonContract() external {
        address[] memory moduleAddresses = new address[](1);
        moduleAddresses[0] = address(1);

        vm.expectRevert();
        installerEndpoint.upgradeModules(moduleAddresses);
    }

    function testUnitRevertUpgradeModulesNonModuleIdContract() external {
        address[] memory moduleAddresses = new address[](1);
        moduleAddresses[0] = address(dispatcher);

        vm.expectRevert();
        installerEndpoint.upgradeModules(moduleAddresses);
    }

    // ============================
    // Single-endpoint module tests
    // ============================

    function testUnitAddModulesSingleEndpoint() public {
        _addModule(singleModuleV1, _VALID);

        address singleModuleImplementationV1 = dispatcher.moduleIdToModuleImplementation(_MODULE_SINGLE_ID);
        address singleModuleEndpointV1 = dispatcher.moduleIdToEndpoint(_MODULE_SINGLE_ID);

        assertEq(singleModuleImplementationV1, address(singleModuleV1));
        assertTrue(singleModuleEndpointV1 != address(0));
    }

    function testUnitRevertAddModulesExistentSingleEndpoint() external {
        _addModule(singleModuleV1, _VALID);

        _addModule(singleModuleV1, TReflexInstaller.ModuleExistent.selector);
    }

    function testUnitUpgradeModulesSingleEndpoint() public {
        testUnitAddModulesSingleEndpoint();

        address singleModuleImplementationV1 = dispatcher.moduleIdToModuleImplementation(_MODULE_SINGLE_ID);
        address singleModuleEndpointV1 = dispatcher.moduleIdToEndpoint(_MODULE_SINGLE_ID);

        _upgradeModule(singleModuleV2, _VALID);

        address singleModuleImplementationV2 = dispatcher.moduleIdToModuleImplementation(_MODULE_SINGLE_ID);
        address singleModuleEndpointV2 = dispatcher.moduleIdToEndpoint(_MODULE_SINGLE_ID);

        assertEq(singleModuleEndpointV1, singleModuleEndpointV2);
        assertTrue(singleModuleImplementationV1 != singleModuleImplementationV2);
        assertEq(singleModuleImplementationV2, address(singleModuleV2));
    }

    function testUnitRevertUpgradeInvalidVersionSingleEndpoint() external {
        _addModule(singleModuleV1, _VALID);
        _upgradeModule(singleModuleV2, _VALID);

        _upgradeModule(singleModuleV1, TReflexInstaller.ModuleInvalidVersion.selector);
        _upgradeModule(singleModuleV2, TReflexInstaller.ModuleInvalidVersion.selector);
    }

    function testUnitRevertUpgradeInvalidTypeSingleEndpoint() external {
        _addModule(singleModuleV1, _VALID);
        _upgradeModule(singleModuleV2, _VALID);

        MockReflexModule singleModuleInvalidType = new MockReflexModule(
            IReflexModule.ModuleSettings({
                moduleId: _MODULE_SINGLE_ID,
                moduleType: _MODULE_MULTI_TYPE,
                moduleVersion: _MODULE_SINGLE_VERSION_V3,
                moduleUpgradeable: _MODULE_SINGLE_UPGRADEABLE_V3
            })
        );

        _upgradeModule(singleModuleInvalidType, TReflexInstaller.ModuleInvalidType.selector);
    }

    function testUnitRevertUpgradeModulesNonUpgradeableSingleEndpoint() external {
        _addModule(singleModuleV1, _VALID);
        _upgradeModule(singleModuleV2, _VALID);
        _upgradeModule(singleModuleV3, _VALID);

        _upgradeModule(
            new MockReflexModule(
                IReflexModule.ModuleSettings({
                    moduleId: _MODULE_SINGLE_ID,
                    moduleType: _MODULE_SINGLE_TYPE,
                    moduleVersion: _MODULE_SINGLE_VERSION_V4,
                    moduleUpgradeable: _MODULE_SINGLE_UPGRADEABLE_V4
                })
            ),
            TReflexInstaller.ModuleNotUpgradeable.selector
        );
    }

    // ===========================
    // Multi-endpoint module tests
    // ===========================

    function testUnitAddModulesMultiEndpoint() public {
        _addModule(multiModuleV1, _VALID);

        address multiModuleImplementationV1 = dispatcher.moduleIdToModuleImplementation(_MODULE_MULTI_ID);
        address multiModuleEndpointV1 = dispatcher.moduleIdToEndpoint(_MODULE_MULTI_ID);

        assertEq(multiModuleImplementationV1, address(multiModuleV1));
        assertEq(multiModuleEndpointV1, address(0));
    }

    function testUnitRevertAddModulesExistentMultiEndpoint() external {
        _addModule(multiModuleV1, _VALID);

        _addModule(multiModuleV1, TReflexInstaller.ModuleExistent.selector);
    }

    function testUnitUpgradeModulesMultiEndpoint() public {
        testUnitAddModulesMultiEndpoint();

        address multiModuleImplementationV1 = dispatcher.moduleIdToModuleImplementation(_MODULE_MULTI_ID);

        _upgradeModule(multiModuleV2, _VALID);

        address multiModuleImplementationV2 = dispatcher.moduleIdToModuleImplementation(_MODULE_MULTI_ID);
        address multiModuleEndpointV2 = dispatcher.moduleIdToEndpoint(_MODULE_MULTI_ID);

        assertTrue(multiModuleImplementationV1 != multiModuleImplementationV2);
        assertEq(multiModuleEndpointV2, address(0));
        assertEq(multiModuleImplementationV2, address(multiModuleV2));
    }

    function testUnitRevertUpgradeInvalidVersionMultiEndpoint() external {
        _addModule(multiModuleV1, _VALID);
        _upgradeModule(multiModuleV2, _VALID);

        _upgradeModule(multiModuleV1, TReflexInstaller.ModuleInvalidVersion.selector);
        _upgradeModule(multiModuleV2, TReflexInstaller.ModuleInvalidVersion.selector);
    }

    function testUnitRevertUpgradeInvalidTypeMultiEndpoint() external {
        _addModule(multiModuleV1, _VALID);
        _upgradeModule(multiModuleV2, _VALID);

        MockReflexModule multiModuleInvalidType = new MockReflexModule(
            IReflexModule.ModuleSettings({
                moduleId: _MODULE_MULTI_ID,
                moduleType: _MODULE_INTERNAL_TYPE,
                moduleVersion: _MODULE_MULTI_VERSION_V3,
                moduleUpgradeable: _MODULE_MULTI_UPGRADEABLE_V3
            })
        );

        _upgradeModule(multiModuleInvalidType, TReflexInstaller.ModuleInvalidType.selector);
    }

    function testUnitRevertUpgradeModulesNonUpgradeableMultiEndpoint() external {
        _addModule(multiModuleV1, _VALID);
        _upgradeModule(multiModuleV2, _VALID);
        _upgradeModule(multiModuleV3, _VALID);

        _upgradeModule(
            new MockReflexModule(
                IReflexModule.ModuleSettings({
                    moduleId: _MODULE_MULTI_ID,
                    moduleType: _MODULE_MULTI_TYPE,
                    moduleVersion: _MODULE_MULTI_VERSION_V4,
                    moduleUpgradeable: _MODULE_MULTI_UPGRADEABLE_V4
                })
            ),
            TReflexInstaller.ModuleNotUpgradeable.selector
        );
    }

    function testUnitAddModulesInternal() public {
        _addModule(internalModuleV1, _VALID);

        address internalModuleImplementationV1 = dispatcher.moduleIdToModuleImplementation(_MODULE_INTERNAL_ID);
        address internalModuleEndpointV1 = dispatcher.moduleIdToEndpoint(_MODULE_INTERNAL_ID);

        assertEq(internalModuleImplementationV1, address(internalModuleV1));
        assertEq(internalModuleEndpointV1, address(0));
    }

    function testUnitRevertAddModulesExistentInternal() external {
        _addModule(internalModuleV1, _VALID);

        _addModule(internalModuleV1, TReflexInstaller.ModuleExistent.selector);
    }

    function testUnitUpgradeModulesInternal() public {
        testUnitAddModulesInternal();

        address internalModuleImplementationV1 = dispatcher.moduleIdToModuleImplementation(_MODULE_INTERNAL_ID);

        _upgradeModule(internalModuleV2, _VALID);

        address internalModuleImplementationV2 = dispatcher.moduleIdToModuleImplementation(_MODULE_INTERNAL_ID);
        address internalModuleEndpointV2 = dispatcher.moduleIdToEndpoint(_MODULE_INTERNAL_ID);

        assertTrue(internalModuleImplementationV1 != internalModuleImplementationV2);
        assertEq(internalModuleEndpointV2, address(0));
        assertEq(internalModuleImplementationV2, address(internalModuleV2));
    }

    function testUnitRevertUpgradeInvalidVersionInternal() external {
        _addModule(internalModuleV1, _VALID);
        _upgradeModule(internalModuleV2, _VALID);

        _upgradeModule(internalModuleV1, TReflexInstaller.ModuleInvalidVersion.selector);
        _upgradeModule(internalModuleV2, TReflexInstaller.ModuleInvalidVersion.selector);
    }

    function testUnitRevertUpgradeInvalidTypeInternal() external {
        _addModule(internalModuleV1, _VALID);
        _upgradeModule(internalModuleV2, _VALID);

        MockReflexModule internalModuleInvalidType = new MockReflexModule(
            IReflexModule.ModuleSettings({
                moduleId: _MODULE_INTERNAL_ID,
                moduleType: _MODULE_SINGLE_TYPE,
                moduleVersion: _MODULE_INTERNAL_VERSION_V3,
                moduleUpgradeable: _MODULE_INTERNAL_UPGRADEABLE_V3
            })
        );

        _upgradeModule(internalModuleInvalidType, TReflexInstaller.ModuleInvalidType.selector);
    }

    function testUnitRevertUpgradeModulesNonUpgradeableInternal() external {
        _addModule(internalModuleV1, _VALID);
        _upgradeModule(internalModuleV2, _VALID);
        _upgradeModule(internalModuleV3, _VALID);

        _upgradeModule(
            new MockReflexModule(
                IReflexModule.ModuleSettings({
                    moduleId: _MODULE_INTERNAL_ID,
                    moduleType: _MODULE_INTERNAL_TYPE,
                    moduleVersion: _MODULE_INTERNAL_VERSION_V4,
                    moduleUpgradeable: _MODULE_INTERNAL_UPGRADEABLE_V4
                })
            ),
            TReflexInstaller.ModuleNotUpgradeable.selector
        );
    }

    // ===============
    // Installer tests
    // ===============

    function testUnitUpgradeInstaller() external {
        assertEq(dispatcher.moduleIdToModuleImplementation(_MODULE_ID_INSTALLER), address(installerModuleV1));
        assertTrue(dispatcher.moduleIdToEndpoint(_MODULE_ID_INSTALLER) == address(installerEndpoint));

        _upgradeModule(installerModuleV2, _VALID);

        assertEq(dispatcher.moduleIdToModuleImplementation(_MODULE_ID_INSTALLER), address(installerModuleV2));
        assertTrue(dispatcher.moduleIdToEndpoint(_MODULE_ID_INSTALLER) == address(installerEndpoint));

        testUnitUpgradeModulesSingleEndpoint();

        testUnitUpgradeModulesMultiEndpoint();

        testUnitUpgradeModulesInternal();
    }

    // =========
    // Utilities
    // =========

    function _addModule(IReflexModule module_, bytes4 selector_) internal {
        address[] memory moduleAddresses = new address[](1);
        moduleAddresses[0] = address(module_);

        if (selector_ == _VALID) {
            vm.expectEmit(true, true, false, false);
            emit ModuleAdded(module_.moduleId(), address(module_), module_.moduleVersion());
        } else {
            vm.expectRevert(abi.encodeWithSelector(selector_, module_.moduleId()));
        }

        installerEndpoint.addModules(moduleAddresses);
    }

    function _upgradeModule(IReflexModule module_, bytes4 selector_) internal {
        address[] memory moduleAddresses = new address[](1);
        moduleAddresses[0] = address(module_);

        if (selector_ == _VALID) {
            vm.expectEmit(true, true, false, false);
            emit ModuleUpgraded(module_.moduleId(), address(module_), module_.moduleVersion());
        } else {
            vm.expectRevert(abi.encodeWithSelector(selector_, module_.moduleId()));
        }

        installerEndpoint.upgradeModules(moduleAddresses);
    }
}
