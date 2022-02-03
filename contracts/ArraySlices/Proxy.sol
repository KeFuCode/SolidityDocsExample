// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.5 <0.9.0;

contract Proxy {
    /// @dev 管理 Proxy 的客户端合约地址，即本合约
    address client;

    constructor(address _client) {
        client = _client;
    }

    /// 在对地址参数进行基本验证后，将调用转发到客户端实现的 “setOwner(address)”。
    function forward(bytes calldata _payload) external {
        bytes4 sig =  bytes4(_payload[:4]);
        // 由于截断行为，bytes4(_payload) 执行相同。
        // bytes4 sig = bytes4(_payload);
        if (sig == bytes4(keccak256("setOwner(address)"))) {
            address owner = abi.decode(_payload[4:], (address));
            require(owner != address(0), "Address of owner cannot be zero.");
        }
        (bool status, ) = client.delegatecall(_payload);
        require(status, "Forward call failed.");
    }
}