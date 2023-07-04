// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

// Interfaces
import {IReflexModule} from "../src/interfaces/IReflexModule.sol";

// Fixtures
import {ImplementationFixture} from "./fixtures/ImplementationFixture.sol";

// Mocks
import {MockImplementationModule} from "./mocks/MockImplementationModule.sol";

/**
 * @title Implementation Endpoint Test
 */
contract ImplementationEndpointTest is ImplementationFixture {
    // =========
    // Constants
    // =========

    uint32 internal constant _MODULE_SINGLE_ID = 777;
    uint16 internal constant _MODULE_SINGLE_TYPE = _MODULE_TYPE_SINGLE_ENDPOINT;

    // =======
    // Storage
    // =======

    MockImplementationModule public singleModuleV1;
    MockImplementationModule public singleModuleEndpoint;

    // =====
    // Setup
    // =====

    function setUp() public virtual override {
        super.setUp();
    }

    // =====
    // Tests
    // =====

    function testUnitRevertCreateModuleWithMaliciousEndpoint() external {
        singleModuleV1 = new MockImplementationModule(
            IReflexModule.ModuleSettings({moduleId: _MODULE_SINGLE_ID, moduleType: _MODULE_SINGLE_TYPE})
        );

        address[] memory moduleAddresses = new address[](1);
        moduleAddresses[0] = address(singleModuleV1);

        vm.expectRevert(IReflexModule.EndpointInvalid.selector);
        installerEndpoint.addModules(moduleAddresses);

        singleModuleEndpoint = MockImplementationModule(dispatcher.getEndpoint(_MODULE_SINGLE_ID));
    }
}
