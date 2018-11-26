pragma solidity ^0.4.25;
contract OnePay{
    //每期奖池上限为：50ether 达到上限自动开奖 玩家单次投入为0.01个ether，每次只能投入一次
    //测试时将合约奖池上限设定为0.1 ether
    //开奖种子
    uint256 seed_=1;
    //开奖期数
    uint256 public round_=1;
    //合约维护者：可以暂时是合约发布者
    address public Owner_;
    //每期信息
    struct OnePayWinInfo{
        address  winAddrInfo;
        uint256  cashpotInfo;
    }
    //构建每期信息映射
    mapping(uint256 => OnePayWinInfo) InfoMapping_ ;
    //构建玩家映射
    mapping(uint256 => mapping(uint256 => address)) PlayEd_;
    //构建开奖映射
    mapping(uint256 => uint256[]) roundIds_;
    //限定每次投注=0.01个ether
    modifier ethLimit(uint256 _value){
        require(_value==0.01 ether);
        _;
    }

    //构造函数：规定合约部署者为合约管理者
    constructor() public{
        Owner_=msg.sender;
    }
     //种子变化
    function mint() internal returns(uint256 ){
        seed_ += 1; 
    }
    //投注
    function payIn()  public payable ethLimit(msg.value){
        address player=msg.sender;
        uint256 value=msg.value;
        uint256 round=round_;
        InfoMapping_[round_].cashpotInfo+=value;
        uint256 luckyId=mint();
        roundIds_[round].push(luckyId);
        PlayEd_[round][luckyId]=player; 
        if(roundIds_[round].length ==5000){
             withdraw();
            }
        }
    //开奖
    function withdraw() internal view {
        uint256 round=round_;
        uint256 poolSize=roundIds_[round].length;
        uint256 index=uint256(keccak256(abi.encodePacked(msg.sender,now)))%poolSize;
        uint256 winId=roundIds_[round][index];
        address winAddr=PlayEd_[round][winId];
        uint256 cashpot=InfoMapping_[round_].cashpotInfo;
        uint256 wincash= cashpot * 85 /100;
        winAddr.transfer(wincash);
        Owner_.transfer(cashpot-wincash);
        InfoMapping_[round_].winAddrInfo =winAddr;
        round_++;
    }
   
}