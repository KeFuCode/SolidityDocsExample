// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;

// 与之前相同的代码，只是没有注释
struct Data {
    mapping(uint => bool) flags;
}

library Set {
    function insert(Data storage self, uint value) public returns (bool) {
        if (self.flags[value])
            return false; // 已经存在
        self.flags[value] = true;
        return true;  
    }

    function remove(Data storage self, uint value) public returns (bool) {
        if (!self.flags[value])
            return false; // 不存在
        self.flags[value] = false;
        return true; 
    }

    function contains(Data storage self, uint value) public view returns (bool) {
        return self.flags[value];
    }
}

contract C {
    using Set for Data; // 这里是关键的修改
    Data knownValues;

    function register(uint value) public {
        // 这里，所有 Data 类型的变量都有对应的成员函数。
        // 下面的函数调用等同于 `Set.insert(knownValues, value)`
        require(knownValues.insert(value));
    }    
}