// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;
import "./transfer.sol";

contract Auction is RTC {
    struct User {
        uint256 userType;
        address addrs;
    }
    address payable reciever;
    mapping(address => uint256) public Index;
    mapping(address => mapping(uint256 => uint256)) public SponsorIndex;
    User[] public users;
    bool exist = true;
    mapping(address => mapping(uint256 => uint256)) startTime;
    mapping(uint256 => mapping(uint256 => address)) public hbidder;
    mapping(uint256 => address) highestbidder;
    mapping(uint256 => uint256) minimumbid;
    mapping(uint256 => uint256) endTime;
    mapping(uint =>  uint256) registerDetail;
    mapping(uint256 => mapping(address => uint256)) public bidDetail;
    mapping(uint256 => mapping(address => uint256)) public bidDetailss;
uint public totalauctioncharge;

    // mintid ---------------------
    constructor(address payable _reciever) {
        reciever = _reciever;
    }

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
    //sponsor = 1 && registration charge 1000 wei
    // bidder  = 2 && registration charge 500 wei
    function register(uint256 Usertype) public payable {
        uint256 AuctionCharge;
        AuctionCharge = msg.value;
        require(
            (Usertype == 1 && AuctionCharge == 1000) ||
                (Usertype == 2 && AuctionCharge == 500),
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

        _approve(sponsor, id);
        _isApprovedOrOwner(sponsor, id);
        _setApprovalForAll(msg.sender, sponsor, exist);
    }

    // auction start by sponsor---------------------------------
    //auction charge 1 eth

    function AuctionStart(uint256 id, uint256 minimumBid) public payable {
        require(msg.value == 1 ether, " charge for auction start");
        require(Index[msg.sender] == 1, " only sponsor can start auction");
        SponsorIndex[msg.sender][Index[msg.sender]] = id;
        reciever.transfer(msg.value);
        uint256 charge;
        charge = msg.value;
        startTime[msg.sender][id] = block.timestamp;
        minimumbid[id] = minimumBid;
        _transferID(_owners[id], address(this), id);
        // after id transfer to contract approval is need for sponsor
        _approve(msg.sender, id);
        _setApprovalForAll(address(this), msg.sender, exist);
        endTime[id] = startTime[msg.sender][id] + 200;
        emit AUCTIONSTART(
            startTime[msg.sender][id],
            _owners[id],
            minimumBid,
            endTime[id]
        );
    }

    // biddding start on item------------------------------
    // enter more than minimum bid
    // bid before time over
    function Bidding(uint256 id) public payable {
        uint256 bid;
        bid = msg.value;
        require(block.timestamp <= endTime[id], "timeover");
        require(Index[msg.sender] == 2, " register as bidder");

        require(
            bidDetailss[id][msg.sender] + bid >
                bidDetailss[id][highestbidder[id]],
            " bid more than last price"
        );
        require(
            minimumbid[id] < bid + bidDetailss[id][msg.sender],
            "bid more than minimum prize"
        );
        bidDetail[id][msg.sender] = bid + bidDetailss[id][msg.sender];
        bidDetailss[id][msg.sender] += bid;
        hbidder[id][bid] = msg.sender;
        highestbidder[id] = hbidder[id][bid];
        emit BIDdetail(id, bidDetailss[id][msg.sender], _balances[msg.sender]);
    }

    // winnner details of highest bidder
    function winner(uint256 id) public view returns (address, uint256) {
        return (highestbidder[id], totalauctioncharge);
    }

    // transfer id to bidder and money to id owner--------------

    function Winner(uint256 id, address payable _to) public payable {
        require(
            SponsorIndex[msg.sender][Index[msg.sender]] == id &&
                block.timestamp >= endTime[id],
            " after auction over"
        );
        uint256 detail = bidDetailss[id][highestbidder[id]];
        require(detail != 0, "");
        uint sponserCharge = (detail * 5 )/100;
         payable(msg.sender).transfer(sponserCharge);
        uint ownerTransfer = detail- sponserCharge;
        _to.transfer(ownerTransfer);
        _transferID(_owners[id], highestbidder[id], id);
        detail = 0;
        Index[msg.sender] = 0;
        emit TransferDetail(
            id,
            highestbidder[id],
            bidDetailss[id][highestbidder[id]],
            _to
        );
    }

    // if auction cancalled
    // transfer id to address
    //sponsorship for id will cancel
    function AuctionCancel(uint256 id, address to) public {
        require(
            SponsorIndex[msg.sender][Index[msg.sender]] == id,
            " only specific IDsponsor can "
        );
        _transferID(_owners[id], to, id);
        SponsorIndex[msg.sender][Index[msg.sender]] = 0;
    }

    // transfering money to the owner address
    function withdraw() public {
        require(msg.sender == reciever,"");
        reciever.transfer(totalauctioncharge);
        totalauctioncharge = 0;
    }

    // only bid value will transfer not registration fees
    function claimBid(uint256 id) public payable returns (bool) {
        require(
            SponsorIndex[msg.sender][Index[msg.sender]] != id ||
                block.timestamp >= endTime[id],
            "after auction over or cancelled"
        );
        payable(msg.sender).transfer(bidDetail[id][msg.sender]);
        return true;
    }

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
