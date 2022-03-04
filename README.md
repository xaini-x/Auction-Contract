# Auction-Contract


constructor
owner(msg.sender ) charges deducted by contract will  sent to the owner's address.


//anyone can mint unique id from (0) address and transfer it to their address
Function mint  (id) 
Id: id minted by any user 
Every minted id is unique
Id mint from (0)address to caller address.


//for entering in the auction you have to register first
// for selling the item registered as a sponsor
// for bidding on item registered as a bidder 
Function register (Usertype)
Usertype:  1 (sponsor) 
For Usertype = 1 registration charge is 100000 wei.
Usertype: 2 (bidder)
For Usertype = 2 registration charge is 50000 wei.
Users can’t register twice
sponsor can’t register as a bidder 
Registered charge(non-refundable) deduct from user balance and send to contract address.


//wrong registration occur
Function wrongUser
Usertype set = 0


//for selling your id you have to assign a sponsor 
//sponsor will maintain the auction
Function approveid(sponsor , id)
Approval only to sponsor
Sponsor: address must be registered as 1
Id: id minted by any user id must exist.
An approved sponsor can sell, transfer, etc anything to the ID.


//for selling the id sponsor will start an auction by entering the id and set the minimum bid amount he wants 
// sponsor can only start one auction at a time
Function auctionStart(id ,minimumbid)
Only A sponsor who has the approval of a unique id  can  start the Auction
Minimum bid The price at which an item can be sold.
Id existing and have approval from the owner to sponsor
Auction Charge is 1 eth or 1e18 wei send to the owner of the contract.
Id transfer from owner to contract address.
Contract assign a (msg.sender|| caller)sponsor to maintain the auction and no one can interfere until time over.
The auction will start for a fixed time period.


//user registered as the bidder will bid on any id’s auction  
Function bidding(id)
User must register as user type 2 for bidding
Id existing 
The bid amount will be greater than the minimum amount set by the sponsor
bid amounts deduct from bidder balance and sent to the contract.

//current highest bid show here dring the auction time
Function highestBid(id) 
After auction start 
Id: id must exist.
The highest bidder amount and address will return


//after auction over sponsor declare a winner and exchange money and id 
Function winnerDeclare(id , _to)
Only sponsor of the id  can access  
Auction start 
Id: exists
_to: the previous owner of id
After auction time is over or auction is cancel
The bidder who has bid the highest value will get the id
Highest bid amount sent to _to(address) 


//for any reason if the auction is canceled by the sponsor id will transfer to the given address and the sponsor has no access to the auction
Function auctioncancel(id)
Only sponsor of the id  can access  
Id: existing
_to: the owner of the id
The id will transfer to _to address
Sponsor has no longer access to the id

//owner can transfer charges from smart contract to his address 
Function withdraw
Only the receiver can call this function
Transfer the charges from the contract address  to the receiver address 

//after auction is over or cancel bidders can collect their bid amount 
Function claimbid(id)
Id: existing
After auction’s time is over or auction is canceled by the sponsor of the id
Amount bid by the bidder on id return to their wallet 
Function wrong user


Function totalSupply
The total balance of the contract


Function balance(address)
Balance of the address
