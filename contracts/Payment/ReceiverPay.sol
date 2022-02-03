// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract ReceiverPay {
    address owner = msg.sender;

    mapping(uint256 => bool) usedNonces;

    constructor() payable {}

    function claimPayment(uint256 amount, uint256 nonce, bytes memory signature) external {
        require(!usedNonces[nonce]);
        usedNonces[nonce] = true;
    
        // 重建在客户端签名的消息
        bytes32 message = prefixed(keccak256(abi.encodePacked(msg.sender, amount, nonce, this)));

        require(recoverSigner(message, signature) == owner);

        payable(msg.sender).transfer(amount);
    }

    /// 破坏合约，并回收剩余的资金
    function shutdown() external {
        require(msg.sender == owner);
        selfdestruct(payable(msg.sender));
    }

    /// 签名方法
    function splitSignature(bytes memory sig) internal pure returns (uint8 v, bytes32 r, bytes32 s)  {
        require(sig.length == 65);
        
        // 内联汇编，可以减少gas消耗，使用yul汇编语言
        assembly {
            // 长度前缀之后第一个32字节
            r := mload(add(sig, 32))
            // 第二个32字节
            s := mload(add(sig, 64))
            // 最后的字节(第二个32字节后的首个字节)
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    function recoverSigner(bytes32 message, bytes memory sig) internal pure returns (address) {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);

        // ecrecover 复原使用圆锥曲线加密对应的公钥
        return ecrecover(message, v, r, s);
    }

    // 构建一个前缀哈希来模仿 eth_sign 的行为
    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}