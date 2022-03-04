// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;
import "./transfer.sol";

contract Auction is RTC {
    struct User {
        uint256 userType;
        address addrs;
    }
    address payable owner;
    mapping(address => uint256)  public Index;
    mapping(uint=>bool ) public ids; 
     mapping(address => mapping(uint256 => bool)) public SponsorAPPROVALID;
    mapping(address => mapping(uint256 => uint256)) public SponsorIndex;
    User[] public users;
    bool exist = true;
     uint256[] public BIDdetails;
     mapping(uint256 => uint256)public startTime;
    mapping(uint256 => mapping(uint256 => address))  public hbidder;
    mapping(uint256 => address) public highestbidder;
    mapping(uint256 => uint256) public minimumbid;
    mapping(uint256 => uint256) public endTime;
    mapping(uint =>  uint256) public registerDetail;
    mapping(uint256 => mapping(address => uint256)) public  bidDetail;
    mapping(uint256 => mapping(address => uint256))  public bidDetailss;
uint public totalauctioncharge;

    
    constructor() {
        owner == msg.sender;
    }

// mintid address != sponser address ---------------------
    function MintID(uint256 id) public {
        _mint(msg.sender, id);
        _owners[id] = msg.sender;
        emit ItemDetail(msg.sender, id);
    }

    // total balance of given address -----------------------
    function balance(address addr) public view virtual returns (uint256) {
        return addr.balance;
    }

    //totalsuppy of the contract address
    function totalsupply() public view returns (uint256) {
        return address(this).balance;
    }

    // register for auction -----------------------------
    //sponsor = 1 && registration charge 100000 wei
    // bidder  = 2 && registration charge 50000 wei
    function register(uint256 Usertype) public payable {
        uint256 AuctionCharge;
        AuctionCharge = msg.value;
        require(
            (Usertype == 1 && AuctionCharge == 100000) ||
                (Usertype == 2 && AuctionCharge == 50000),
            " sponsor = 1 || bidder  = 2"
        );
        require(Index[msg.sender] == 0, "User is registered");
        Index[msg.sender] = Usertype;
        User memory user = User(Usertype, msg.sender);
        users.push(user);
        registerDetail[Usertype] = AuctionCharge;
         totalauctioncharge += registerDetail[Usertype] ;
        emit registration(msg.sender, Index[msg.sender], _balances[msg.sender]);
    }

    // transfer id tosponser ----------------------------
    // only owner can approve of token id access transfer
    function ApproveID(address sponsor, uint256 id) public {
        require(msg.sender == _owners[id], " only owner can approve  ");
        require(Index[sponsor] == 1, " only to sponsor");
        // SponsorAPPROVALID[msg.sender][id] = exist;
        _approve(sponsor, id);
        _isApprovedOrOwner(sponsor, id);
        _setApprovalForAll(msg.sender, sponsor, exist);
    }

    // auction start by sponsor---------------------------------
    //auction charge 1 eth
    function AuctionStart(uint256 id, uint256 minimumBid ,  uint endT) public payable {
      
        require(_tokenApprovals[id] == msg.sender,"you are not the sponsor of the id");
        require(msg.value == 1 ether, " charge for auction start");
        require(Index[msg.sender] == 1, " only sponsor can start auction");
          require(ids[id]  !=exist,
            " auction already start on this id"
        );
      //id access to sponsor
        SponsorIndex[msg.sender][Index[msg.sender]] = id;
        ids[id]= exist;
        // auction charge will send to recier=ver address 
        owner.transfer(msg.value);
        uint256 charge;
        charge = msg.value;
        startTime[id] = block.timestamp;
        minimumbid[id] = minimumBid;
        _transferID(_owners[id], address(this), id);
        // after id transfer to contract approval is need for sponsor
        _approve(msg.sender, id);
        _setApprovalForAll(address(this), msg.sender, exist);
       
        endTime[id] = startTime[id] + endT;
        
        emit AUCTIONSTART(
            startTime[id],
            _owners[id],
            minimumBid,
            endTime[id]
        );
    }

    // biddding start on item------------------------------
    // enter more than minimum bid
    // bid before time over
     function Bidding(uint256 id ) public payable {
        uint bid;
        bid = msg.value;
        require(block.timestamp <= endTime[id], "timeover");
        require(Index[msg.sender] == 2, " register as bidder");
        require(
            bidDetailss[id][msg.sender] +bid >
                bidDetailss[id][highestbidder[id]],
            " bid more than last price"
        );
        require(
            minimumbid[id] < bid + bidDetailss[id][msg.sender],
            "bid more than minimum price");
        bidDetail[id][msg.sender] = bid + bidDetailss[id][msg.sender];
        bidDetailss[id][msg.sender] += bid;
        BIDdetails.push( bidDetail[id][msg.sender]);
        hbidder[id][bid] = msg.sender;
        highestbidder[id] = hbidder[id][bid];
        emit BIDdetail(id, bidDetailss[id][msg.sender], _balances[msg.sender]);
    }

    // winnner details of highest bidder
    function higghestbid(uint256 id) public view returns (address, uint256) {
        return (highestbidder[id],  bidDetail[id][highestbidder[id]]);
    }

    // transfer id to bidder and money to id owner--------------
    // transfer sponsorcharge to sponsor address
    //transfer highestbid amount to idowner subtracting the sponsorcharge 
    function WinnerDeclare(uint256 id, address payable _to) public payable {
        require(
            SponsorIndex[msg.sender][Index[msg.sender]] == id  , " not the specific id sponsor"
        );
         require(block.timestamp > endTime[id],
            "  time not over"
        );
        uint256 detail = bidDetailss[id][highestbidder[id]];
        require(detail != 0, "");
        //sponsercharge 5% of highest bid
        uint sponserCharge = (detail * 5 )/100;
         payable(msg.sender).transfer(sponserCharge);
         //left money send to (_to) address
        uint ownerTransfer = detail- sponserCharge;
        _to.transfer(ownerTransfer);
        //id transfer to highest bidder 
        _transferID(_owners[id], highestbidder[id], id);
        detail = 0;
         //after winner declare ,sponsorship  will cancel for the specific id
        SponsorIndex[msg.sender][Index[msg.sender]] = 0;
        ids[id]=false;
        emit TransferDetail(
            id,
            highestbidder[id],
            bidDetailss[id][highestbidder[id]],
            _to
        );
    }

    // if auction cancalled
    // transfer id
    function AuctionCancel(uint256 id, address to) public {
        require(
            SponsorIndex[msg.sender][Index[msg.sender]] == id,
            " only specific IDsponsor can "
        );
        // id will transfer to (to) address
        _transferID(_owners[id], to, id);
        //sponsorship  will cancel for the specific id
        SponsorIndex[msg.sender][Index[msg.sender]] = 0;
        ids[id]=false;
    }

    // transfering money to the given (reciver)address in constructor 
    function withdraw() public {
        require(msg.sender == owner,"");
        owner.transfer(totalauctioncharge);
        totalauctioncharge = 0;
    }
//winner declare || auction cancel-----------------------
    // only bid value will transfer not registration fees
    function claimBid(uint256 id) public payable returns (bool) {
         require(
            SponsorIndex[msg.sender][Index[msg.sender]] != id  , " not the specific id sponsor"
        );
         require(block.timestamp > endTime[id],
            "  time not over"
        );
        payable(msg.sender).transfer(bidDetail[id][msg.sender]);
        return true;
    }
// if you registerd as wrong user registration fee will not transfer
//user id will delete
    function wrongUser() public {
        require(Index[msg.sender] == 1 || Index[msg.sender] == 2, "   ");
        Index[msg.sender] = 0;
    }

    event registration(
        address redisteredAddress,
        uint256 UserType,
        uint256 balance
    );
    event ItemDetail(address owner, uint256 itemId);
    event TRANSFERID(address Sponsor, uint256 id);
    event AUCTIONSTART(
        uint256 startTime,
        address owners,
        uint256 minimumBID,
        uint256 endTime
    );
    event BIDdetail(uint256 onIndex, uint256 Amount, uint256 remainingbids);
    event _Winner(uint256 id, address highestBidder, uint256 amout);

    event TransferDetail(
        uint256 TransferID,
        address newOwner,
        uint256 transferedAmount,
        address amountTransferedTo
    );
}
