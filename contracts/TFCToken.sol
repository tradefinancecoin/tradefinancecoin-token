pragma solidity ^0.4.11;

// 1 ETH == 1000 Tokens
// Total Supply == 100,000,000 tokens
// 100,000 ETH

/* |---------------------------------------------------------------------------------------------------+------| */
/* | TradeFinanceCoin tokens created                                                                   | 100% | */
/* | TradeFinanceCoin tokens for the Initial Token Sale                                                |  80% | */
/* | Tokens for founders and team members                                                              |  10% | */
/* | Tokens for advisors, early backers, strategic partners and for a long term alignment of interests |  10% | */
/* |---------------------------------------------------------------------------------------------------+------| */
  

/* |------------------+-------------| */
/* | TIME             | TOKEN BONUS | */
/* | Day 1 to Day 14  | + 10 %      | */
/* | Day 15 to Day 30 | + 0%        | */
/* |------------------+-------------| */


// QUESTIONS FOR AUDITORS:
// - Considering we inherit from VestedToken, how much does that hit at our gas price?
// - Ensure max supply is 100,000,000
// - Ensure that even if not totalSupply is sold, tokens would still be transferrable after (we will up to totalSupply by creating TradeFinanceCoin tokens)

// vesting: 365 days, 365 days / 4 vesting

import "../zeppelin-solidity/contracts/math/SafeMath.sol";
import "../zeppelin-solidity/contracts/token/VestedToken.sol";

contract TFCToken is VestedToken {
  //FIELDS
  string public name = "TradeFinanceCoin";
  string public symbol = "TFC";
  uint public decimals = 4;
  
  //CONSTANTS
  //Time limits
  uint public constant STAGE_ONE_TIME_END = 2 weeks;
  uint public constant STAGE_TWO_TIME_END = 4 weeks;
  
  // Multiplier for the decimals
  uint private constant DECIMALS = 10000;

  //Prices of TFC
  uint public constant PRICE_STANDARD    = 1000*DECIMALS;             // TFC received per one ETH; MAX_SUPPLY / (valuation / ethPrice)
  uint public constant PRICE_STAGE_ONE   = PRICE_STANDARD * 110/100;  // 1ETH = 10% more TFC
  uint public constant PRICE_STAGE_TWO   = PRICE_STANDARD;

  //TFC Token Limits
  uint public constant ALLOC_TEAM         = 10000000*DECIMALS;	    //  10% founders and team members
  uint public constant ALLOC_PARTNERS     = 10000000*DECIMALS;      //  10% advisors, backers, partners
  uint public constant ALLOC_CROWDSALE    = 80000000*DECIMALS;	    //  80% sold to the public
  uint public constant PREBUY_PORTION_MAX = 20000000*DECIMALS;      // this is redundantly more than what will be pre-sold
 
  // More erc20
  uint public totalSupply = 100000000*DECIMALS;     // 100 million tokens
  
  //ASSIGNED IN INITIALIZATION
  //Start and end times
  uint public publicStartTime; // Time in seconds public crowd fund starts.
  uint public privateStartTime; // Time in seconds when pre-buy can purchase up to 31250 ETH worth of TFC;
  uint public publicEndTime; // Time in seconds crowdsale ends
  uint public hardcapInEth;  	     		 // Pass in hard cap when creating contract. Should be 40,000 to mimic AdEx

  //Special Addresses
  address public ownerAddress;        // Address of the contract owner. Can halt the crowdsale.
  address public multisigAddress;     // Address to which all ether flows.

  
  address public tfcTeamAddress;      // Address to which ALLOC_TEAM ALLOC_PARTNERS
  //  address public teamAddress;
  //  address public partnersAddress;
    
  
  address public preBuy1; // Address used by pre-buy
  address public preBuy2; // Address used by pre-buy
  address public preBuy3; // Address used by pre-buy
  uint public preBuyPrice1; // price for pre-buy
  uint public preBuyPrice2; // price for pre-buy
  uint public preBuyPrice3; // price for pre-buy

  //Running totals
  uint public etherRaised; // Total Ether raised.
  uint public TFCSold; // Total TFC created
  uint public prebuyPortionTotal; // Total of Tokens purchased by pre-buy. Not to exceed PREBUY_PORTION_MAX.
  
  //booleans
  bool public halted; // halts the crowd sale if true.

  // MODIFIERS
  //Is currently in the period after the private start time and before the public start time.
  modifier is_pre_crowdfund_period() {
    if (now >= publicStartTime || now < privateStartTime) throw;
    _;
  }

  //Is currently the crowdfund period
  modifier is_crowdfund_period() {
    if (now < publicStartTime) throw;
    if (isCrowdfundCompleted()) throw;
    _;
  }

  // Is completed
  modifier is_crowdfund_completed() {
    if (!isCrowdfundCompleted()) throw;
    _;
  }
  function isCrowdfundCompleted() internal returns (bool) {
    if (now > publicEndTime || TFCSold >= ALLOC_CROWDSALE || etherRaised >= hardcapInEth) return true;
    return false;
  }

  //May only be called by the owner address
  modifier only_owner() {
    if (msg.sender != ownerAddress) throw;
    _;
  }

  //May only be called if the crowdfund has not been halted
  modifier is_not_halted() {
    if (halted) throw;
    _;
  }

  // EVENTS
  event PreBuy(uint _amount);
  event Buy(address indexed _recipient, uint _amount);

  // Initialization contract assigns address of crowdfund contract and end time.
  function TFCToken(
    address _multisig,
    address _tfcTeam,
    uint _publicStartTime,
    uint _privateStartTime,
    uint _hardcapInEth,
    address _prebuy1, uint _preBuyPrice1,
    address _prebuy2, uint _preBuyPrice2,
    address _prebuy3, uint _preBuyPrice3
  ) {
    ownerAddress = msg.sender;
    publicStartTime = _publicStartTime;
    privateStartTime = _privateStartTime;
    publicEndTime = _publicStartTime + 4 weeks;
    multisigAddress = _multisig;
    tfcTeamAddress = _tfcTeam;

    hardcapInEth = _hardcapInEth;

    preBuy1 = _prebuy1;
    preBuyPrice1 = _preBuyPrice1;
    preBuy2 = _prebuy2;
    preBuyPrice2 = _preBuyPrice2;
    preBuy3 = _prebuy3;
    preBuyPrice3 = _preBuyPrice3;

    balances[ownerAddress] += ALLOC_TEAM;
    balances[tfcTeamAddress] += ALLOC_PARTNERS;
    balances[ownerAddress] += ALLOC_CROWDSALE;
  }

  // Transfer amount of tokens from sender account to recipient.
  // Only callable after the crowd fund is completed
  function transfer(address _to, uint _value) returns (bool) {
    if (_to == msg.sender) return; // no-op, allow even during crowdsale, in order to work around using grantVestedTokens() while in crowdsale
    if (!isCrowdfundCompleted()) throw;
    super.transfer(_to, _value);
  }

  // Transfer amount of tokens from a specified address to a recipient.
  // Transfer amount of tokens from sender account to recipient.
  function transferFrom(address _from, address _to, uint _value)
    is_crowdfund_completed
    returns (bool)
  {
    super.transferFrom(_from, _to, _value);
  }

  //constant function returns the current TFC price.
  function getPriceRate()
      constant
      returns (uint o_rate)
  {
      uint delta = SafeMath.sub(now, publicStartTime);

      if (delta > STAGE_ONE_TIME_END) return PRICE_STAGE_TWO;

      return (PRICE_STAGE_ONE);
  }

  // calculates wmount of TFC we get, given the wei and the rates we've defined per 1 eth
  function calcAmount(uint _wei, uint _rate) 
    constant
    returns (uint) 
  {
    return SafeMath.div(SafeMath.mul(_wei, _rate), 1 ether);
  } 
  
  // Given the rate of a purchase and the remaining tokens in this tranche, it
  // will throw if the sale would take it past the limit of the tranche.
  // Returns `amount` in scope as the number of TFC tokens that it will purchase.
  function processPurchase(uint _rate, uint _remaining)
    internal
    returns (uint o_amount)
  {
    o_amount = calcAmount(msg.value, _rate);

    if (o_amount > _remaining) throw;
    if (!multisigAddress.send(msg.value)) throw;

    balances[ownerAddress] = balances[ownerAddress].sub(o_amount);
    balances[msg.sender] = balances[msg.sender].add(o_amount);

    TFCSold += o_amount;
    etherRaised += msg.value;
  }

  //Special Function can only be called by pre-buy and only during the pre-crowdsale period.
  function preBuy()
    payable
    is_pre_crowdfund_period
    is_not_halted
  {
    // Pre-buy participants would get the first-day price, as well as a bonus of vested tokens
    uint priceVested = 0;

    if (msg.sender == preBuy1) priceVested = preBuyPrice1;
    if (msg.sender == preBuy2) priceVested = preBuyPrice2;
    if (msg.sender == preBuy3) priceVested = preBuyPrice3;

    if (priceVested == 0) throw;

    uint amount = processPurchase(PRICE_STAGE_ONE + priceVested, SafeMath.sub(PREBUY_PORTION_MAX, prebuyPortionTotal));
    grantVestedTokens(msg.sender, calcAmount(msg.value, priceVested), 
      uint64(now), uint64(now) + 91 days, uint64(now) + 365 days, 
      false, false
    );
    prebuyPortionTotal += amount;
    PreBuy(amount);
  }

  //Default function called by sending Ether to this address with no arguments.
  //Results in creation of new TFC Tokens if transaction would not exceed hard limit of TFC Token.
  function()
    payable
    is_crowdfund_period
    is_not_halted
  {
    uint amount = processPurchase(getPriceRate(), SafeMath.sub(ALLOC_CROWDSALE, TFCSold));
    Buy(msg.sender, amount);
  }

  // To be called at the end of crowdfund period
  // WARNING: transfer(), which is called by grantVestedTokens(), wants a minimum message length
  function grantVested(address _tfcTeamAddress, address _tfcFundAddress)
    is_crowdfund_completed
    only_owner
    is_not_halted
  {
    // Grant tokens pre-allocated for the team
    grantVestedTokens(
      _tfcTeamAddress, ALLOC_TEAM,
      uint64(now), uint64(now) + 91 days , uint64(now) + 365 days, 
      false, false
    );

    // Grant tokens that remain after crowdsale to the TradeFinanceCoin fund, vested for 2 years
    grantVestedTokens(
      _tfmFundAddress, balances[ownerAddress],
      uint64(now), uint64(now) + 182 days , uint64(now) + 730 days, 
      false, false
    );
  }

  //May be used by owner of contract to halt crowdsale and no longer except ether.
  function toggleHalt(bool _halted)
    only_owner
  {
    halted = _halted;
  }

  //failsafe drain
  function drain()
    only_owner
  {
    if (!ownerAddress.send(this.balance)) throw;
  }
}
