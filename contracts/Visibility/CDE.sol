// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract C {
    uint private data;

    function f(uint a) private pure returns(uint b) { return a + 1; }
    function setData(uint a) public { data = a; }
    function getData() public view returns(uint) { return data; }
    function compute(uint a, uint b) internal pure returns (uint) { return a + b; }
}

// 这将无法编译
contract D {
    function readData() public {
        C c = new C();
        uint local = c.f(7); // 错误：成员 `f` 不可见
        c.setData(3);
        local = c.getData();
        local = c.compute(3, 5); // 错误：成员 `compute` 不可见
    }
}

contract E is C {
    function g() public {
        C c = new C();
        uint val = compute(3, 5); // 访问内部成员（从继承合约访问父合约成员）
    }
}