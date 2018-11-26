pragma solidity ^0.4.7;

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


contract MyTonkenERC20{
 using SafeMath for uint256;

    //合约发布者
         address public Owner;
    //代币名称
         string public name;
    //代币简称
         string public symbol;
    //代币小数点
         uint256 public decimals=18;
    //代币发行总量
         uint256 public totalsupply;
    //账户对应余额
         mapping(address => uint256) public balanceOf;
    //
        mapping(address => mapping(address=>uint256)) public allowance;
    //构造函数初始化
     constructor() public {
        name="MyToken";
        symbol="MT";
        totalsupply=1000*10**decimals;
        balanceOf[msg.sender]=totalsupply;
        Owner=msg.sender;
    }

    //转账事件
    event Transfer(address indexed _from,address indexed _to,uint256 indexed _value);  
    //授权事件
    event Approval( address indexed _owner, address indexed _spender, uint256 _value);  
    //转账根据 from 与to _value
    function _transfer(address _from ,address _to,uint256 _value) internal {
        require(_to!=address(0));
        require(balanceOf[_from]>_value);
        balanceOf[_from] -=_value;
        balanceOf[_to]+=_value;
        emit Transfer(_from,_to,_value);
    }
    //转账根据当前用户转账给to,_value
    function transfer(address _to,uint256 _value) public {
        _transfer(msg.sender,_to,_value);
    }

     //当前用户作为被授权用户使用授权公钥给to转_value wei的钱
    function transferFrom(address _from ,address _to,uint256 _value) public returns(bool success){
         //判断当前授权的金额是否大于要转账的金额
         require(allowance[_from][msg.sender]>= _value);
         //将转账金额从授权账户映射中减去
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        //调用转账方法转账
        _transfer(_from, _to, _value);
        return true;
    }
    //将当前用户授权_value wei 的钱给_spender
    function approve(address _spender,uint256 _value) public returns(bool success){
         //将当前用户授权额度存到合约mapping映射中
        allowance[msg.sender][_spender]=_value;
        //授权事件
        emit Approval(msg.sender,_spender,_value);
        return true;
    }
     
}