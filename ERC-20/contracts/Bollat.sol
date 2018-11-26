pragma solidity ^0.4.25;

contract Bollat{
    //投票者
    struct Voter{
        uint256 weight;
        bool voted;
        address delegate;
        uint256 vote;
    }
    //提案
    struct Proposal{
        byte32 name;
        uint256 voteCount;
    }
    //投票者集合
    mapping(address => voter) public voters;
    //合约所有者
    address Owner;
    //提案集合
    Proposal[] public proposals;

    contructor(bytes[] proposalName) public{
        Owner=msg.sender;
        voters[Owner].weight=1;
        for (uint256 i=0;i<proposalName.length;i++) {
            proposals.push(Proposal({name:proposalName[i],voteCount:0}));
        }
    }
    modifier OnlyOwner(address _from){
        require(_from==Owner);
        _;
    } 

    modifier isVoted(address _voter){
        require(!voters[_voter].voted);
        _;
    }

    //授予‘voter’投票者的投票权利 ,只有部署者有这个权力
    function giveRightToVote(address voter) OnlyOwner(msg.sender) public{
        voters[voter].weight=1;
    }
    //把你的票授权给其他投票者
    function delegate(address _to) public {
        //不能给自己授权
        require(_to!=msg.sender);
        //授权委托发起者将票委托给_to
        voter storage sender=voters[msg.sender];
        //检查被委托人地址不能为空
        while(voters[_to].delegate!=address(0)){
            _to=voters[_to].delegate;
            //防止循环授权
            require(_to!=msg.sender);
        }
        sender.voted=true;
        sender.delegate=_to;
        voters storage delegate_=voters[_to];
        if(delegate_.voted){
            proposals[delegate_.vote]+=sender.weight;
        }else{
            delegate_.weight+=sender.weight;
        }
    }
    //把你的票投给提案
    function vote(uint256 Proposal){
        voter storage sender=voters[msg.sender];
        require(!sender.voted);
        proposals[Proposal]voteCount+=sender.weight;
        sender.voted=false;
        //将已近投票的索引赋值到售票者
        sender.vote=Proposal;
    }
    function winingProposal() public return(uint256 winingProposal_){
        uint256 winingVoteCount=0;
        for(uint256 p=o;p<proposals.length;p++){
            if(proposals[p].voteCount>winingVoteCount){
                winingVoteCount==proposals[p].voteCount;
                winingProposal_=p;
            }
        }
    }
    function winnerName() public view returns(bytes32 winnerName_){
        winnerName_=proposals[winingProposal()].name;
    }
}