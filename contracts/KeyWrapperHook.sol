// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import {BaseHook} from "periphery-next/BaseHook.sol";
import {Hooks} from "v4-core/libraries/Hooks.sol";

import {PoolId} from "v4-core/types/PoolId.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";

contract KeyWrapperHook is BaseHook {
    using PoolId for IPoolManager.PoolKey;
    WrappedFriendFactory public constant wrappedFactory =
        WrappedFriendFactory(0x68250Bf6d105Fe33f3120C5AfF385160d54EB5F2);

    constructor(IPoolManager _poolManager) BaseHook(_poolManager) {}

    function getHooksCalls() public pure override returns (Hooks.Calls memory) {
        return
            Hooks.Calls({
                beforeInitialize: false,
                afterInitialize: false,
                beforeModifyPosition: true,
                afterModifyPosition: true,
                beforeSwap: false,
                afterSwap: false,
                beforeDonate: false,
                afterDonate: false
            });
    }

    using PoolIdLibrary for IPoolManager.PoolKey;

    function afterModifyPosition(
        address sender,
        PoolKey calldata key,
        IPoolManager.ModifyPositionParams calldata params,
        BalanceDelta delta,
        bytes calldata hookData
    ) external returns (bytes4) {
        // Do something
        return KeyWrapperHook.afterModifyPosition.selector;
    }
}
