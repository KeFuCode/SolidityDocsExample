// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract owned {
    constructor () { owner = payable(msg.sender); }
    address payable owner;
}

contract Destructible is owned {
    function destory() virtual public {
        if (msg.sender == owner) selfdestruct(owner);
    }
}

contract Base1 is Destructible {
    function destory() public virtual override { /* 清除操作1 */ super.destory(); }
}

contract Base2 is Destructible {
    function destory() public virtual override { /* 清除操作2 */ super.destory(); }
}

contract Final is Base1, Base2 {
    function destory() public override(Base1, Base2) { super.destory(); }
}