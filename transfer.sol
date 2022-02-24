// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;
import "./openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

 contract RTC is ERC721 {

function transfer(address sender , address reciver , uint amount) public virtual  returns (bool){
        _Transfer(sender ,  reciver , amount);
        return true;
    }
    }