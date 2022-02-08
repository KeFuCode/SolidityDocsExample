// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.22 <0.9.0;

contract OwnedToken {
    // `TokenCreator` 是下面定义的合约类型。
     // 只要不用于创建新合约，就可以引用它。
    TokenCreator creator;
    address owner;
    bytes32 name;

    // 这是注册 creator和分配 name 的构造函数。 
    constructor(bytes32 _name) {
        // 状态变量是通过它们的名字而不是通过 `this.owner` 来访问的。
        // 函数可以直接访问，也可以通过 `this.f` 访问，
        // 但后者提供了函数的 external view。 尤其是在构造函数中，
        // 你不应该从外部访问函数，
        // 因为该函数还不存在。
        // 详情请看下一节。 
        owner = msg.sender;

        // 我们执行从 `address` 到 `TokenCreator` 的显式类型转换，并假设调用合约的类型是 `TokenCreator`，
        // 没有真正的方法来验证这一点。
        // 这不会创建新合约。
        creator = TokenCreator(msg.sender);
        name = _name;
    }

    function changeName(bytes32 newName) public {
        // 只有创建者可以更改名称。
        // 我们根据地址来比较合约，地址可以通过显式转换为地址来检索。
        if (msg.sender == address(creator)) 
            name = newName;
    }

    function transfer(address newOwner) public {
        // 只有当前所有者可以转让代币。
        if (msg.sender != owner) return;

        // 我们询问 creator 合约是否应该使用下面定义的 `TokenCreator` 合约的函数进行转移。
        // 如果调用失败（例如由于气体不足），执行也会在此处失败。
        if (creator.isTokenTransferOK(owner, newOwner))
            owner = newOwner;
    }
}

contract TokenCreator {
    function createToken(bytes32 name) public returns (OwnedToken tokenAddress) {
        // 创建一个新的 `Token` 合约并返回它的地址。
        // 从 JavaScript 方面来看，这个函数的返回类型是 `address`，因为这是 ABI 中最接近的类型。
        return new OwnedToken(name);
    }

    function changeName(OwnedToken tokenAddress, bytes32 name) public {
        // 同样，`tokenAddress` 的外部类型只是 `address`。
        tokenAddress.changeName(name);
    }

    function isTokenTransferOK(address currentOwner, address newOwner) public pure returns (bool ok) {
        // 检查任意条件以查看传输是否应该继续
        return keccak256(abi.encodePacked(currentOwner, newOwner))[0] == 0x7f;
    }
}