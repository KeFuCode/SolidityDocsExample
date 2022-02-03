// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.4;

contract Purchase {
    uint public value;
    address payable public seller;
    address payable public buyer;

    enum State { Created, Locked, Release, Inactive}
    // 变量 State 的第一个组成 `State.created` 作为默认值
    State public state;

    modifier condition(bool codition_) {
        require(codition_);
        _;
    }

    /// 只有 buyer 可以调用这个函数
    error OnlyBuyer();
    /// 只有 seller 可以调用这个函数
    error OnlySeller();
    /// 当前状态不可以调用这个函数
    error InvalidState();
    /// 提供的 value 必须是偶数
    error ValueNotEven();

    modifier onlyBuyer() {
        if (msg.sender != buyer)
            revert OnlyBuyer();
        _;
    }

    modifier onlySeller() {
        if (msg.sender != seller)
            revert OnlySeller();
        _;
    }

    modifier inState(State state_) {
        if (state != state_)
            revert InvalidState();
        _;
    }

    event Aborted();
    event PurchaseConfirmed();
    event ItemReceived();
    event SellerRefunded();

    // 确保 `msg.value` 是偶数。
    // 如果是奇数，会被除法截断。
    // 通过乘法检查它不是奇数。
    constructor() payable {
        seller = payable(msg.sender);
        value = msg.value / 2;
        if ((2 * value) != msg.value) {
            revert ValueNotEven();
        }
    }

    // 中止购买并回收以太币,
    // 只能由 seller,
    // 在合约是 Locked 状态之前调用
    function abort() external onlySeller inState(State.Created) {
        emit Aborted();
        state = State.Inactive;
        // 我们这里直接使用transfer。
        // 它是可重入安全的，因为它是这个函数的最后一次调用，我们已经改变了状态。
        seller.transfer(address(this).balance);
    }

    /// 以买家身份确认购买。
    /// 交易必须包含 `2 * value` 以太币。
    /// 在调用 confirmReceived 之后，以太币将被锁定。
    function confirmPurchase() external inState(State.Created) condition(msg.value == (2 * value)) payable {
        emit PurchaseConfirmed();
        buyer = payable(msg.sender);
        state = State.Locked;
    }

    /// 确认您（买家）收到了该物品。
    /// 这将释放锁定的以太。
    function confirmReceived() external onlyBuyer inState(State.Locked) {
        emit ItemReceived();
        // 首先更改状态很重要，否则下面使用`send`调用的合约可以在这里再次调用。
        state = State.Release;

        buyer.transfer(value);
    }

    /// 该函数退款给卖家，
    /// 即返还卖家锁定的资金。
    function refundSeller() external onlySeller inState(State.Release) {
        emit SellerRefunded();
        // 首先更改状态很重要，否则下面使用`send`调用的合约可以在这里再次调用。
        state = State.Inactive;

        seller.transfer(3 * value);
    }
}