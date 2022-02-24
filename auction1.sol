// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
import "./transfer.sol";

contract Auction is RTC {
    struct User {
        address addrs;
        bool exist;
    }
    
    struct Owner {
        address owner;
        uint256 id;
        bool exist;
    }

    Owner[] public IDexist;
    User[] public registerd;
    uint256 index;
    uint256 largest = 0;
    bool exist = true;
    address highestbidderr;
    mapping(address => mapping(uint256 => uint256)) startTime;
    mapping(address => mapping(uint256 => uint256)) public bid;
      mapping(address => mapping(uint256 => uint256)) public bids;
      mapping(uint => mapping(uint256 => address)) public hbidder;
  mapping(uint => address) highestbidder;
    mapping(address => bool) Index;
    mapping(uint=> uint) minimumbid;
    mapping(address => uint256) bidtotal;
    mapping(uint => uint256) endTime;
    mapping(uint256 => mapping(address => uint)) public bidDetail;
mapping(uint256 => mapping(address => uint[]))public  bidDetails;
mapping(uint256 => mapping(address => uint))public  bidDetailss;
    function register() public {
        require(Index[msg.sender] != exist, " already registered");
        Index[msg.sender] = exist;
        User memory Register = User(msg.sender, exist);
        registerd.push(Register);
        uint256 balance = 100;
        _balances[msg.sender] = balance;
        emit registration(index, Index[msg.sender], _balances[msg.sender]);
    }

    function Seller(uint256 id  , uint mbid) public {
        require(Index[msg.sender] == exist, " register first");
     uint charge = 1;
        startTime[msg.sender][id] = block.timestamp;
        _mint(msg.sender, id);
        RTC.transfer(msg.sender, address(this), charge);
          _totalSupply += charge;
        _owners[id] = msg.sender;
        minimumbid[id] = mbid;
        endTime[id] = startTime[msg.sender][id] + 100;
        Owner memory IDcheck = Owner(msg.sender, id, exist);
        IDexist.push(IDcheck);
        emit ItemDetail(startTime[msg.sender][id], _owners[id], id);
    }
function Bidding(uint id  ,  uint count) public {
    require (minimumbid[id]<   bidDetailss[id] [msg.sender] + count,"enter more than  minimum bid ");
        require(block.timestamp  <= endTime[id],"timeover");
         require(_owners[id] != msg.sender,"_owners cant bid");
        require ( Index[msg.sender] == exist," register first");
        require( _balances[msg.sender] != 0 ,"not enough balance");
 require (bidDetailss[id][msg.sender] + count > bidDetailss[id] [highestbidder[id]]," bid more than last price");
   RTC.transfer(msg.sender, address(this), count);
    bidDetail[id] [msg.sender] = count +  bidDetailss[id] [msg.sender];
      bidDetailss[id] [msg.sender] += count;
      uint detail =   bidDetailss[id] [msg.sender];
       bidDetails[id] [msg.sender].push(detail);
       hbidder[id][count] = msg.sender;
       highestbidder[id] =  hbidder[id][count];
        _totalSupply += count;
 emit BIDdetail(
        
        id,
        bidDetailss[id] [msg.sender],
       _balances[msg.sender]
    );
}


function winner(uint id ) public view returns(address , uint) {
    return (highestbidder[id] ,  bidDetailss[id] [highestbidder[id]]);
}
  
    function Winner(uint256 id) public {
         uint detail =   bidDetailss[id] [msg.sender] ;
        require (detail !=0,"");
        RTC.transfer(address(this), _owners[id],  bidDetailss[id] [msg.sender]);
        _totalSupply -=  bidDetailss[id] [msg.sender];
        ERC721.transferFrom(_owners[id], highestbidder[id], id);
            detail= 0;
    }

    event registration(
        uint256 onIndex,
        bool redisteredAddress,
        uint256 balance
    );
    event ItemDetail(uint256 StartTime,address owner, uint256 itemId);
    event BIDdetail(
        uint256 onIndex,
        uint256 Amount,
        uint256 remainingCounts
    );
    event _Winner(uint id,address highestBidder, uint256 amout);
}
