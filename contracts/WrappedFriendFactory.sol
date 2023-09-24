// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.0;

import {WrappedFriend} from "./WrappedFriend.sol";

contract WrappedFriendFactory {
    address public immutable deployer;
    uint256 public fee = 500;
    uint256 internal constant FEE_DENOMINATOR = 10_000;
    address[] public allFriends;
    mapping(address target => address erc20) public getFriend;
    mapping(address target => uint256 amount) public royalties;

    constructor() {
        deployer = msg.sender;
    }

    receive() external payable {}

    /// @notice Buy new shares and wrap them into ERC20 tokens
    /// @param target The address of the FriendTech account being wrapped
    /// @param shares The number of shares to sell
    function mint(
        address target,
        uint256 shares
    ) external payable returns (address payable friend) {
        if (getFriend[target] == address(0)) {
            bytes memory bytecode = type(WrappedFriend).creationCode;
            bytes32 salt = keccak256(abi.encodePacked(target));
            assembly {
                friend := create2(0, add(bytecode, 32), mload(bytecode), salt)
            }
            WrappedFriend(friend).initialize(target);
            allFriends.push(friend);
            getFriend[target] = friend;
        } else {
            friend = payable(getFriend[target]);
        }

        if (shares > 0) {
            uint256 remaining = WrappedFriend(friend).mint{value: msg.value}(
                shares
            );
            WrappedFriend(friend).transfer(
                msg.sender,
                WrappedFriend(friend).balanceOf(address(this))
            );
            uint256 cost = msg.value - remaining;
            uint256 royalty = (cost * fee) / FEE_DENOMINATOR;
            royalties[deployer] += royalty / 2;
            royalties[target] += royalty / 2;
            require(
                remaining >= royalty,
                "WrappedFriendFactory: not enough eth"
            );
            msg.sender.call{value: remaining - royalty}("");
        }
    }

    /// @notice Burn ERC20 tokens to unwrap and sell the corresponding shares
    /// @param target The address of the FriendTech account being wrapped
    /// @param shares The number of shares to sell
    function burn(
        address target,
        uint256 shares
    ) external payable returns (address payable friend) {
        friend = payable(getFriend[target]);
        uint256 proceeds = WrappedFriend(friend).burn(msg.sender, shares);
        uint256 royalty = (proceeds * fee) / FEE_DENOMINATOR;
        royalties[deployer] += royalty / 2;
        royalties[target] += royalty / 2;
        msg.sender.call{value: proceeds - royalty}("");
    }

    /// @notice Claim wrapped royalties for your FriendTech account
    function claimRoyalty() external {
        uint256 amount = royalties[msg.sender];
        royalties[msg.sender] = 0;
        msg.sender.call{value: amount}("");
    }

    function setFee(uint256 _fee) external {
        require(msg.sender == deployer, "auth");
        fee = _fee;
    }
}
