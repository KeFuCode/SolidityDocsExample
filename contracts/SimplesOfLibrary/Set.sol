// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;

// 我们定义了一个新的结构体数据类型，用于在调用合约中保存其数据。
struct Data {
    mapping(uint256 => bool) flags;
}

library Set {
    // 注意第一个参数的类型是“storage 引用”，因此只有它的存储地址而不是它的内容作为调用的一部分被传递。
    // 这是库函数的一个特殊功能。
    // 如果函数可以被视为该对象的方法，则调用第一个参数 `self` 是惯用的。
    function insert(Data storage self, uint256 value) public returns (bool) {
        if (self.flags[value] == true) 
            return false; // 已经存在
        self.flags[value] = true;
        return true;
    }

    function remove(Data storage self, uint256 value) public returns (bool) {
        if (!self.flags[value]) 
            return false; // 不存在
        self.flags[value] = false;
        return true;
    }

    function contains(Data storage self, uint256 value)
        public
        view
        returns (bool)
    {
        return self.flags[value];
    }
}

contract C {
    Data knownValues;

    function register(uint256 value) public {
        // 库函数可以在没有库的特定实例的情况下调用，因为“实例”将是当前合约。
        require(Set.insert(knownValues, value));
    }
    // 在这个合约中，如果需要，我们也可以直接访问 knownValues.flags。
}
