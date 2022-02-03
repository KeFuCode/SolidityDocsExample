// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract SimplePaymentChannel {
    address payable public sender; // 发送付款的账户
    address payable public recipient; // 接收付款的账户
    uint256 public expiration; // 如果接收人没有主动关闭，则会超时

    constructor (address payable recipientAddress, uint256 duration) payable {
        sender = payable(msg.sender);
        recipient = recipientAddress;
        expiration = block.timestamp + duration;
    }

    /// 收款人可以随时通过提供被发件人签名的金额来关闭通道。
    /// 收件人将收到该金额，其余的将返回给发件人
    function close(uint amount, bytes memory signature) external {
        require(msg.sender == recipient);
        require(isValidSignature(amount, signature));

        recipient.transfer(amount);
        selfdestruct(sender);
    }

    /// 发送方可以随时延长过期时间
    function extend(uint256 newExpiration) external {
        require(msg.sender == sender);
        require(newExpiration > expiration);
    
        expiration = newExpiration;
    }

    /// 如果在没有接收者关闭通道的情况下达到超时，
    /// 以太币被释放回发送者。
    function claimTimeout() external {
        require(block.timestamp >= expiration);
        selfdestruct(sender);
    }

    function isValidSignature(uint256 amount, bytes memory signature) internal view returns (bool) {
        bytes32 message = prefixed(keccak256(abi.encodePacked(this, amount)));
        
        // 检查签名是否来自付款发送人
        return recoverSigner(message, signature) == sender;
    }

    /// 这下面的所有函数都取自本章
    /// '创建和验证签名' 章节。

    function splitSignature(bytes memory sig) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        require(sig.length == 65);

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

        return ecrecover(message, v, r, s);
    }

    /// 构建一个前缀哈希来模仿 eth_sign 的行为。
    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}