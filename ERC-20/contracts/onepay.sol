pragma solidity ^0.4.25;
contract onepay{

uint256 seed_=1;
uint256 round_=1;
uint256 cashpot;
modifier ethLimit(uint256 _value){
    require(_value>=0.01     );
    _;
}

address public Owner;


mapping (uint256=> address) player_;
mapping (uint256 => uint256[]) roundIds_;


constructor() public{
    Owner=msg.sender;
}
function payIn()  public payable ethLimit(msg.value){
    address player=msg.sender;
    uint256 value=msg.value;
    uint256 round=round_;
    uint256 num=value/0.01 ether;
    for(uint256 i=0;i<num;i++){
        uint256 luckyId=mint();
        roundIds_[round].push(luckyId);
        player_[luckyId]=player; 
    }
    

    if(roundIds_[round].length ==10){
        withdraw();
    }
}

function withdraw() internal view {
    uint256 round=round_;
    uint256 poolSize=roundIds_[round].length;
    uint256 index=uint256(keccak256(abi.encodePacked(msg.sender)))%poolSize;
    uint256 winId=roundIds_[round][index];
    address winAddr=player_[winId];
    uint256 wincash= cashpot * 85 /100;
    winAddr.transfer(wincash);
    Owner.transfer(cashpot-wincash);
}

function mint() public returns(uint256){
     seed_ += 1;
    
}

}
