pragma solidity ^0.4.24;
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
        uint256 index;
    }
    //奖池上限 
    uint256  MAX_CAP;
    //单个投注上线 
    uint256  One_Max;
    //构建每期信息映射
    mapping(uint256 => OnePayWinInfo) InfoMapping_ ;
    //构建玩家映射
    mapping(uint256 => mapping(uint256 => address)) PlayEd_;
    mapping(uint256 => mapping(address => uint256[])) AllKey_;

    //保持全部获奖地址
    mapping(uint256 =>  address[]) AllwinAddrInfo;
    //保持所有期数的奖池
    mapping(uint256 =>  uint256[]) AllcashpotInfo;
    //构建开奖映射
    mapping(uint256 => uint256[]) roundIds_;
    //限定单次投入大小  
    //上限结构
    struct One_MaxAndMAX_CAP{
        uint256 MAX_CAPs;
        uint256 One_Maxs;
    }

    //上限映射
    mapping (uint256=>One_MaxAndMAX_CAP)  One_MaxAndMAX_CAPMap;
    modifier ethLimit(uint256 _value){
        require(_value==One_Max,"");
        _;
    }
    modifier OnlyOwner(address Addr){
        require(Addr==Owner_);
        _;
    }
    
    //开奖事件
    event Winthdraw(address indexed winAddr,uint256 indexed wincash,uint256 indexed round);
    //修改奖池上限   
    function UpdataMaxCapSize(uint256 _max) OnlyOwner(msg.sender) public{
        require(_max!=0);
        uint256 roudn=round_;
        roudn++;
        One_MaxAndMAX_CAPMap[roudn].MAX_CAPs=_max;
        
    }
    //修改单次投入上限 
     function UpdataOneMaxSize(uint256 _max) OnlyOwner(msg.sender) public{
            require(_max!=0);
            uint256 roudn=round_;
            roudn++;
          One_MaxAndMAX_CAPMap[roudn].One_Maxs=_max;
    }
    //构造函数：规定合约部署者为合约管理者
    constructor() public{
         MAX_CAP=1;
         One_Max=0.01 ether;
         Owner_=msg.sender;
    }
     //种子变化
    function mint() internal returns(uint256 ){
        seed_ += 1; 
        return uint8(keccak256(abi.encodePacked(msg.sender,now,seed_)));
    }
    //投注
    function payIn()  public payable ethLimit(msg.value) returns(uint256 ){
        address player=msg.sender;
        uint256 value=msg.value;
        uint256 round=round_;
        InfoMapping_[round_].cashpotInfo+=value;
        uint256 luckyId=mint();
        roundIds_[round].push(luckyId);
        PlayEd_[round][luckyId]=player; 
        AllKey_[round][player].push(luckyId);
        //奖池上限
        if(roundIds_[round].length ==MAX_CAP){
             withdraw();
             
            }
            return luckyId;
        
        }
    //开奖
    function withdraw() internal {
        uint256 round=round_;
        uint256 poolSize=roundIds_[round].length;
        uint256 index=uint256(keccak256(abi.encodePacked(msg.sender,now,round_)))%poolSize;
        uint256 winId=roundIds_[round][index];
        address winAddr=PlayEd_[round][winId];
        uint256 cashpot=InfoMapping_[round_].cashpotInfo;
        uint256 wincash= cashpot * 85 /100;
        winAddr.transfer(wincash);
        
        Owner_.transfer(cashpot-wincash);
        InfoMapping_[round_].winAddrInfo =winAddr;
        InfoMapping_[round].index=index;
        AllwinAddrInfo[1].push(winAddr);
        AllcashpotInfo[1].push(cashpot);
        round_++;
        round=round+1;
        if( One_MaxAndMAX_CAPMap[round].MAX_CAPs!=0){
            MAX_CAP=One_MaxAndMAX_CAPMap[round].MAX_CAPs;
        }else{
           One_MaxAndMAX_CAPMap[round].MAX_CAPs=MAX_CAP;
        }
        if( One_MaxAndMAX_CAPMap[round]. One_Maxs!=0){
             One_Max=One_MaxAndMAX_CAPMap[round]. One_Maxs;
        }else{
             One_MaxAndMAX_CAPMap[round]. One_Maxs=One_Max;
        }
        round=round-1;
        emit Winthdraw(winAddr,wincash,round);
       
    }
    //获取开奖信息，通过期数
    function selectOnePayWinInfo(uint256 _round) public view returns(address winaddr,uint256 cash,uint256 index_){
        winaddr=InfoMapping_[_round].winAddrInfo;
        cash=InfoMapping_[_round].cashpotInfo;
        index_=InfoMapping_[_round].index;
    }
    //玩家获取当期个人所有彩票
    function getKeyByAddressAndRound(uint256 round) public view returns(uint256[] key){
        key=AllKey_[round][msg.sender];
    }

    //获取所有的开奖信息
    function getAllWinInfo()public view returns(address[] winaddr ,uint256[]cashpot){
         winaddr= AllwinAddrInfo[1];
         cashpot=AllcashpotInfo[1];
        
    }

    //销毁合约
    function kill() OnlyOwner(msg.sender) external{
        selfdestruct(Owner_);
    }
   
}