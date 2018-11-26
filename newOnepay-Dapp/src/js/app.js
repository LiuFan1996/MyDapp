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
  
      return App.bindEvents();
    },
  
    bindEvents: function() {
      $(document).on('click', '#PayInBtn', App.handlePayIn);
      $(document).on('click', '#CallBtn', App.handleCall);
      
    },
  
    markAdopted: function(adopters, account) {
      web3.eth.getAccounts(function(error,accounts){
        App.accounts=accounts;});
        
      App.contracts.OnePay.deployed().then(function(instance){
        console.log(instance);
       App.OnePayInstance=instance;


      //  //获取所有事件
      //  var events = OnePayInstance.allEvents({fromBlock: 0, toBlock: 'latest'});

      //  // 监听捕获事件
      //  events.watch(function(error, event){
      //    if (!error)
      //      if(event.args.winAddr==App.accounts[0]&& !App.thisRounds[event.args.round-1]){
      //        App.thisRounds[event.args.round-1]=true;
      //        console.log(App.thisRounds);
      //        alert("恭喜获奖："+event.args.wincash/10**18+"ether");
      //        return;
      //      }
           
      //  })
      return App.OnePayInstance.round_.call();
      }).then(function (value){
        $("#palyAccountNamePId").text(App.accounts[0]);
        $("#roundPId").text(value); 
        App.thisRound=value;
        App.OnePayInstance.Winthdraw({filter:{winAddr:App.accounts[0]}},function (err,data) {
          if (err){
              console.error(err);
          }
          console.log(data);
          //alert(data.args.round);
          if(data.args.round==(App.thisRound-1)){
            alert("恭喜中奖了");
          }
          
         });
        return App.historyByAddrFun();
      }).catch(function(err){
        console.log(err.message);
    });
    },
    
    historyByAddrFun: function() {
     var panelbody=$(".panel-body");
     for(var  i=App.thisRound;i>0;i--){
                    console.log(i);
                    var div1=document.createElement("div");
                    var div2=document.createElement("div");
                    var div3=document.createElement("div");
                    var div4=document.createElement("div");
                    var div5=document.createElement("div");
                    var form=document.createElement("form");
                    var label= document.createElement("label");
                    var p= document.createElement("p");
                    div1.className="panel panel-default";
                    div2.className="panel-heading";
                    div3.className="panel-body";
                    div4.className="form-group";
                    div5.className="col-sm-10";
                    form.className="form-horizontal";
                    label.className="col-sm-2";
                    p.className="form-control-static";
                    div1.appendChild(div2);
                    div1.appendChild(div3);
                    div3.appendChild(form);
                    form.appendChild(div4);
                    div4.appendChild(label);
                    div4.appendChild(div5);
                    div5.appendChild(p);
                    div2.innerHTML="期数"+"<strong>"+(i)+""+"</strong>";
                    // App.OnePayInstance.getKeyByAddressAndRound(i,{from:App.accounts[0]}).then(function(data){
                    //   console.log(data[0]);
                    //   return data[0];
                    //  }).then(function(value){
                    //   label.innerText="LuckyKey:    "+value;
                    //  });     
                   
                    console.log(div1);
                    panelbody[2].appendChild(div1);
                     
      }
    },

    handlePayIn: function(event) {
      event.preventDefault();
      
      App.contracts.OnePay.deployed().then(function(instance){
        OnePayInstance=instance;
        return OnePayInstance.payIn({from:App.accounts[0],value:10000000000000000,gasPrice:2*10**9});
      }).then(function (value){
       
    });
    },
    //查询开奖信息
    handleCall: function(event) {
      event.preventDefault();
      App.contracts.OnePay.deployed().then(function(instance){
        OnePayInstance=instance;
        var round_=parseInt($("#callRoudnInput").val());
        console.log(round_);
        return OnePayInstance.selectOnePayWinInfo(round_);
      }).then(function (value){
        console.log(value);
      
         $("#resultCallAdrr").text(value[0]);
         $("#resultCallValAll").text(value[1]/(10**18)+"ether");
         $("#resultCallVal").text((value[1]/(10**18))*0.85+"ether");
      
       });
    }
    
  };
  
  $(function() {
    $(window).load(function() {
      App.init();
    });
  });
  