// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.2 <0.9.0;

contract Test {
    uint x;
    // 所有发送到这个合约的消息都会调用这个函数（没有其他函数）。
    // 向这个合约发送以太币会导致异常，
    // 因为回退函数没有 `payable` 修饰符。
    fallback() external { x = 1; }
}

// 这个合约会保留所有发送给它的以太币，没有办法返还。
contract TestPayable {
    uint x;
    uint y;
    // 除了纯转账外，所有对合约的调用都会调用这个函数．
    // (因为除了 receive 函数外，没有其他的函数).
    // 任何对合约非空 calldata 调用会执行 fallback 函数(即使是调用函数附加 ether).
    fallback() external payable { x = 1; y = msg.value; }

    // 纯转账调用这个函数，
    // 例如对每个空 calldata 的调用
    receive() external payable { x = 2; y = msg.value; }
}

contract Caller {
    function callTest(Test test) public returns (bool) {
        (bool success,) = address(test).call(abi.encodeWithSignature("nonExistingFunction()"));
        require(success);
        // test.x 结果变为 1。

        // address(test) 将不允许直接调用 ``send``，因为 ``test`` 没有应付回退功能。
        // 它必须被转换为 ``address payable`` 类型才能允许调用 ``send`` 。
        address payable testPayable = payable(address(test));

        // 如果有人向该合约发送以太币，
        // 传输将失败，即此处返回 false。
        return testPayable.send(2 ether);
    }

    function callTestPayable(TestPayable test) public returns (bool) {
        (bool success,) = address(test).call(abi.encodeWithSignature("nonExistingFuction()"));
        require(success);
        // 结果 test.x 为 1  test.y 为 0.
        (success,) = address(test).call{value: 1}(abi.encodeWithSignature("nonExistingFunction()"));
        require(success);
        // 结果test.x 为 1 而 test.y 为 1.

        // 如果有人向该合约发送以太币，TestPayable 中的 receive 函数将被调用。
        // 由于该函数写入 storage ，它需要比简单的 “send” 或 “transfer” 更多的 gas。 因此，我们必须使用低级调用。
        (success,) = address(test).call{value: 2 ether}("");
        require(success);
        // 结果 test.x 为 2 而 test.y 为 2 ether.

        return true;
    }
}