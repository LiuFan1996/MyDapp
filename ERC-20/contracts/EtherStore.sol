// 以太坊智能合约安全问题：重入攻击
// 重入问题（Re-Entrancy)

contract EtherSotre {
	uint256 public withdrawalLimit = 1 ether;
	mapping(address => uint256) public lastWinthdrawTime;
	mapping(address => uint256) public balances;

	function depositFunds() public payable {
		balances[msg.sender] += msg.value;
	}

	function withdrawFunds(uint256 _weiToWithdraw) public {
		require(balances[msg.sender] >= _weiToWithdraw);
		// 检查withdrawal限制
		require(_weiToWithdraw <= withdrawalLimit);
		// 检查时间条件限制
		require(now >= lastWinthdrawTime[msg.sender] + 1 weeks);
		// 发送ether检查
		require(msg.sender.call.value(_weiToWithdraw)());
		balances[msg.sender] -= _weiToWithdraw;
		lastWinthdrawTime[msg.sender] = now;
	}
}

