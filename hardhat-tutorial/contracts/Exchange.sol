// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// FUnctionality --
// 1. Users should have options to sawp CD and ETH tokens
// 2. the liquity pool cotnributore should be rewared with CDLP 
// 3. 1% transaction fees

// Step 1: create crypto dev LP token -- this is the token that's give to the liquidity pool contributors
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Exchange is ERC20 {

   // Create an address for the CryptoDevs token
   address public cryptoDevTokenAddress;

   // 1. created CDLP ERC20 token and cxrated the address for older CD token
   constructor(address _cryptoDevToken) ERC20("CryptoDev LP Token", "CDLP")  {
      require(_cryptoDevToken != address(0), "This is an invalid addres, Null address");
      cryptoDevTokenAddress = _cryptoDevToken;
   }

   // 2. Get the reserves of the ETH and CD token?
   // -- ETH reserves can be directly fetched using address(this).balance 
   // -- lets creta fucntion only for CD token -- since this is also ERC20 - we can use the abalcenOf function

   /**
      * @dev Returns the amount of `Crypto Dev Tokens` held by the contract
   */
   function getReserve() public view returns (uint) {
      return ERC20(cryptoDevTokenAddress).balanceOf(address(this));
   }

   // 3. WE can now have facility to addLiquidity -- in the form of ETH and CD token 
   /**
      * @dev Adds liquidity to the exchange.
   */
   function addLiquidity(uint _amount) public payable returns(uint) {

      uint liquidity;
      uint ethBalance = address(this).balance;
      uint cryptoDevTokenReserve = getReserve();
      ERC20 cryptoDevToken = ERC20(cryptoDevTokenAddress);

      /*
        If the reserve is empty, intake any user supplied value for
        `Ether` and `Crypto Dev` tokens because there is no ratio currently
      */

      if(cryptoDevTokenReserve == 0) {
         // transfer CD tokens from uders account to the cotnract 
         cryptoDevToken.transferFrom(msg.sender, address(this), _amount);
         // mint LP tokesn for eth supplied

         liquidity = ethBalance;
         _mint(msg.sender, liquidity);
      } else  {

         // find the ethReserve
         uint ethReserve = ethBalance - msg.value;
         // crete the pool ratio
         uint cryptoDevTokenAmount = (msg.value * cryptoDevTokenReserve) / (ethReserve);
         // transfer CD token to the cpntract
         cryptoDevToken.transferFrom(msg.sender, address(this), cryptoDevTokenAmount);

         // mint the LP token for the user 
         liquidity = (msg.value * totalSupply()) / ethReserve;
         _mint(msg.sender, liquidity);
      }

      return liquidity;
   }

   /**
    * @dev Returns the amount Eth/Crypto Dev tokens that would be returned to the user
    * in the swap
    */

    // in excahnge for the LP token user have, he can have the ETH and CD tokens 

   function removeLiquidity(uint _amount) public returns(uint, uint) {
      require(_amount > 0, "_amount should be greater than zero");

      // total eth balance
      uint ethReserve = address(this).balance;

      // total LP token
      uint _totalSupply = totalSupply();

      // ethtokenamount?
      uint ethAmount = (_amount * ethReserve) / _totalSupply;

      // cryptoDevToken amount?
      uint cryptoDevTokenAmount = (_amount * getReserve()) / _totalSupply;

      // burn the LP token in users account
      _burn(msg.sender, _amount); 
         
      // trnsfer eth and CD token to user 
      payable(msg.sender).transfer(ethAmount);
      ERC20(cryptoDevTokenAddress).transfer(msg.sender, cryptoDevTokenAmount);
      return (ethAmount, cryptoDevTokenAmount);
   }

   /// ONLY SWAPPING REMAINING
   /**
   * @dev Returns the amount Eth/Crypto Dev tokens that would be returned to the user
   * in the swap
   */
   function getAmountOfTokens(
      uint256 inputAmount, uint256 inputReserve, uint256 outputReserve
   ) public pure returns (uint256) {

      // check if the reserve exist for the trading pair
      require(inputReserve > 0 && outputReserve > 0, "Invalid reserves");

      // extract the free 
      uint256 inputAmountWithFee = inputAmount * 99;

      // calculate
      uint256 numerator = inputAmountWithFee * outputReserve;
      uint256 denominator = (inputReserve * 100) + inputAmountWithFee;

      return numerator/denominator;

      /*
      1000 ETH    500 - CD 

      20 ETH -> 2 ETH fee 

      (20 * 99) * 500 
      ----------------   = 9,90,000 / 1,01,980 = 9.707 CD Tokens
      100000+(20 * 99) 
      */
   }

   /**
      * @dev Swaps Eth for CryptoDev Tokens
   */
   function ethToCryptoDevToken(uint _minTokens) public payable {
      uint tokenReserve = getReserve();

      uint256 tokensBought = getAmountOfTokens(msg.value, address(this).balance - msg.value, tokenReserve);

      require(tokensBought >= _minTokens, "Insufficient output amount");
      ERC20(cryptoDevTokenAddress).transfer(msg.sender, tokensBought);
   }

   function cryptoDevTokenToEth(uint _tokensSold, uint _minEth) public {
      uint256 tokenReserve = getReserve();
      // call the `getAmountOfTokens` to get the amount of Eth
      // that would be returned to the user after the swap
      uint256 ethBought = getAmountOfTokens(
         _tokensSold,
         tokenReserve,
         address(this).balance
      );
      require(ethBought >= _minEth, "insufficient output amount");
      // Transfer `Crypto Dev` tokens from the user's address to the contract
      ERC20(cryptoDevTokenAddress).transferFrom(
         msg.sender,
         address(this),
         _tokensSold
      );
      // send the `ethBought` to the user from the contract
      payable(msg.sender).transfer(ethBought);
   }
}