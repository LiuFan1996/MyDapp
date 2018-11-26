App = {
    web3Provider: null,
    contracts: {},
    accounts:{},
    thisRound:null,
    OnePayInstance:null,
    init: async function() {
      return await App.initWeb3();
    },
  
    initWeb3: async function() {
        if(typeof web3 !=='undefined'){
            App.web3Provider=web3.currentProvider;
        }else{
            App.web3Provider=new Web3.prviders.HttpProvider("http://127.0.0.1:8545");
        }
        web3=new Web3(App.web3Provider);
      return App.initContract();
    },
  
    initContract: function() {
      $.getJSON('OnePay.json', function(data) {
        var OnePayArtifact=data;
        App.contracts.OnePay=TruffleContract(OnePayArtifact);
        App.contracts.OnePay.setProvider(App.web3Provider);
  
        return App.markAdopted();
      });
    },
  
    markAdopted: function(adopters, account) {
      web3.eth.getAccounts(function(error,accounts){
        App.accounts=accounts;
    });
      App.contracts.OnePay.deployed().then(function(instance){
       App.OnePayInstance=instance;
      return App.OnePayInstance.round_.call();
      }).then(function(data){
        App.thisRound=data;
        return App.historyByAll();
      })
    },

    historyByAll:function(){
      console.log(App.OnePayInstance+"ssssssssssssssss");
     App.OnePayInstance.getAllWinInfo({from:App.accounts[0]}).then(function(data){
      var tb = document.getElementById('OnetableId'); 
         console.log(data);
        for(var  i=App.thisRound-1;i>0;i--){
            var tr=document.createElement("tr");
            var td1=document.createElement("td");
            var td2=document.createElement("td");
            var td3=document.createElement("td");
            td1.innerText=i;
            td2.innerText=data[0][i-1];
            td3.innerText=(data[1][i-1]/10**18)*0.85+"ether";
            tr.appendChild(td1);
            tr.appendChild(td2);
            tr.appendChild(td3);
            console.log(tr);
            tb.appendChild(tr);
        }
      });
     
    }
    
  };
  
  $(function() {
    $(window).load(function() {
      App.init();
    });
  });
  