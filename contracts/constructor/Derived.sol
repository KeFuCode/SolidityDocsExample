// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Base {
    uint x;
    constructor (uint _x) { x = _x; }
}

// 直接在继承列表中指定参数
contract Derived1 is Base(7) {
    constructor() {}
}

// 或通过派生的构造函数中用 修饰符 "modifier"
contract Derived2 is Base {
    constructor(uint _y) Base(_y * _y) {}
}