pragma solidity ^0.4.25;
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

contract MyERC721Token{
   address owner;
   string public _name; 
   string public _symbol;
   mapping(uint256 => string) private _tokenURIs; 
   	// 映射用户所有的token
	mapping(address => uint256[] ) private _ownerTokens;

	// tokenId => owner index
	mapping(uint256 => uint256) private _ownedTokensIndex;

	// array of all tokens
	uint256[] private _allTokens;

	// tokenid => allTokens index
	mapping(uint256 => uint256) private _allTokensIndex;


	
		using SafeMath for uint256;
	// 映射 tokenId => owner
	mapping(uint256 => address) private _tokenOwner; 
	// 映射 tokenid授权
	mapping(uint256 => address) private _tokenApprovals;
	// 用户拥有的token数量
	mapping(address => uint256) private _ownerTokenCount;
	// 授权标记，是否被授权
	mapping(address => mapping(address => bool)) private _operatorApprovals;

	// 等于bytes4(keccak256("onERC721Received(address,uint256,bytes)"))
	bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;
    bytes4 private constant _InterfaceId_ERC721Enumberable = 0x780e9b63;
	bytes4 private constant _InterfaceId_ERC721 = 0x80ac58cd;
	bytes4 private constant _InterfaceId_ERC165 = 0x01ffc9a7;

	mapping(bytes4 => bool) private _supportInterfaces;
	event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
	
	function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes4 _data) public returns(bytes4){
		// return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
		return this.onERC721Received.selector;
    }
    modifier OnlyOwner(address Addr){
        require (owner==Addr);
        _;
    }
    constructor(string name, string symbol) public {
         owner=msg.sender;
		_name = name;
		_symbol = symbol;
		_registerInterface(_InterfaceId_ERC165);
		_registerInterface(_InterfaceId_ERC721);
		_registerInterface(_InterfaceId_ERC721Enumberable);
	}

	function tokenURIs(uint256 tokenId) public view returns(string) {
		return _tokenURIs[tokenId];
	}
		function supportsInterface(bytes4 interfaceID) public view returns (bool){
		return _supportInterfaces[interfaceID];
	}


	function _registerInterface(bytes4 interfaceId) internal {
		require(interfaceId != 0xffffffff);
		_supportInterfaces[interfaceId] = true;
	}
    	// 用户账户金额
	function balanceOf(address owner) public view returns(uint256) {
		require(owner != address(0));
		return _ownerTokenCount[owner];
	}

	// tokenid拥有者
	function ownerOf(uint256 tokenId) internal view returns (address){
		address owner = _tokenOwner[tokenId];
		require(owner != address(0));
		return owner;
	}


	// 获取tokenId授权地址
	function getApproved(uint256 tokenId) internal view returns (address){
		require(_exits(tokenId));
		return _tokenApprovals[tokenId];
	}

	// 验证用户是否都被授权
	function isApprovedForAll(address owner, address operator) internal view returns (bool){
		return _operatorApprovals[owner][operator];
	}

	// 授权
	function approve(address to, uint256 tokenId) public {
		address owner = ownerOf(tokenId);
		require(owner != to);
		require(msg.sender == owner || isApprovedForAll(owner, msg.sender));
		_tokenApprovals[tokenId] = to;
		emit  Approval(owner, to, tokenId);
	}


	// 设置所有tokenid的授权
	function setApprovalForAll(address to, bool approved) public {
		require(to != msg.sender);
		_operatorApprovals[msg.sender][to] = approved;
		emit ApprovalForAll(msg.sender, to, approved);
	}

	// 交易，转移一个tokenId
	function transferFrom(address from, address to, uint256 tokenId) public {
		require(_isApprovedOrOwner(msg.sender,tokenId));
		require(to != address(0));

		_clearApproval( ownerOf(tokenId),  tokenId);
		// 从一个账户上删除
		_ownerTokenCount[from] = _ownerTokenCount[from].sub(1);
		_tokenOwner[tokenId] = address(0);

		// 添加到另一个账户上
		_ownerTokenCount[to] = _ownerTokenCount[to].add(1);
		_tokenOwner[tokenId] = to;

		emit Transfer(from, to, tokenId);
	}


	function safeTransferFrom(address from, address to, uint256 tokenId, bytes4 _data) public {
		transferFrom(from, to, tokenId);
		require(_checkOnERC721Received(from, to, tokenId, _data));
	}

	function safeTransferFrom(address from, address to, uint256 tokenId) public {
		safeTransferFrom(from, to, tokenId, "");
	}

	// 验证tokenid是否存在
	function _exits(uint256 tokenId) internal view returns (bool) {
		address owner = _tokenOwner[tokenId];
		return owner != address(0);
	}

	// 检查tokenid是否授权或是否是owner
	function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns(bool) {
		address owner = ownerOf(tokenId);
		return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner,spender));
	}

	// 清除授权
	function _clearApproval(address owner, uint256 tokenid) private {
		require(ownerOf(tokenid) == owner);
		if(_tokenApprovals[tokenid] != address(0)){
			_tokenApprovals[tokenid] = address(0);
		}
	}


	function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes4 _data) internal returns(bool) {
		if(!isContract(to)){
			return true;
		} 

		bytes4 retval =onERC721Received(from,to,tokenId,_data);
		return (retval == _ERC721_RECEIVED);
	}

	// 检查是否为合约地址
	function isContract(address account) internal view returns(bool) {
		uint256 size;
		assembly{size := extcodesize(account)}
		return size>0;
	}


	function _addTokenTo(address to, uint256 tokenId) internal {
		require(_tokenOwner[tokenId] == address(0));
		_tokenOwner[tokenId] = to;
		_ownerTokenCount[to] = _ownerTokenCount[to].add(1);
		
		uint256 length = _ownerTokens[to].length;
		_ownerTokens[to].push(tokenId);
		_ownedTokensIndex[tokenId] = length;
	}


	function _removeTokenFrom(address from, uint256 tokenId) internal {
		require(ownerOf(tokenId) == from);
		_ownerTokenCount[from] =  _ownerTokenCount[from].sub(1);
		_tokenOwner[tokenId] = address(0);
		
		uint256 tokenIndex = _ownedTokensIndex[tokenId];
		uint256 lastTokenIdex = _ownerTokens[from].length.sub(1);
		uint256 lastToken = _ownerTokens[from][lastTokenIdex];

		_ownerTokens[from][tokenIndex] = lastToken;
		_ownerTokens[from].length--;

		_ownedTokensIndex[tokenId] = 0;
		_ownedTokensIndex[lastToken] = tokenIndex;
	}

	// 新增token
	function _mint(address to, uint256 tokenId) public OnlyOwner(msg.sender) {
		require(to != address(0));
		_tokenURIs[tokenId]=_name;
		_addTokenTo(to, tokenId);
	
		_allTokensIndex[tokenId] = _allTokens.length;
		_allTokens.push(tokenId);
	
		emit Transfer(address(0), to, tokenId);
	}
	// 销毁token
	function _burn(address owner, uint256 tokenId) public OnlyOwner(msg.sender) {
		_clearApproval(owner, tokenId);
		_removeTokenFrom(owner, tokenId);
	
		uint256 tokenIndex = _allTokensIndex[tokenId];
		uint256 lastTokenIdex = _allTokens.length;
		uint256 lastToken = _allTokens[lastTokenIdex];


		_allTokens[tokenIndex] = lastToken;
		_allTokens[lastTokenIdex] = 0;


		_allTokens.length--;
		_allTokensIndex[tokenId] = 0;
		_allTokensIndex[lastToken] = tokenIndex;
		emit Transfer(owner, address(0), tokenId);
	}
	
	// 返回alltoken在index位置上的tokenId
	function tokenByIndex(uint256 _index) public view returns (uint256){
		require(_index < totalSupply());
		return _allTokens[_index];
	}


	// token的总量
	function totalSupply() public view returns (uint256){
		return _allTokens.length;
	}

	function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256){
		require(_index < _ownerTokens[_owner].length);
		return _ownerTokens[_owner][_index];
	}


}