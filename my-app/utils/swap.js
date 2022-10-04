import { Contract } from "ethers";
import {
  EXCHANGE_CONTRACT_ABI,
  EXCHANGE_CONTRACT_ADDRESS,
  TOKEN_CONTRACT_ABI,
  TOKEN_CONTRACT_ADDRESS,
} from "../constants";

/*
    getAmountOfTokensReceivedFromSwap:  Returns the number of Eth/Crypto Dev tokens that can be received 
    when the user swaps `_swapAmountWei` amount of Eth/Crypto Dev tokens.
*/

export const getAmountOfTokensReceivedFromSwap = async (
   _swapAmountWei,
   provider,
   ethSelected,
   ethBalance,
   reserveCD 
) => {

   const exchangeContract = new Contract (
      EXCHANGE_CONTRACT_ADDRESS, 
      EXCHANGE_CONTRACT_ABI, 
      provider 
   );

   let amountOfTokens;

   if(ethSelected) {

      amountOfTokens = await exchangeContract.getAmountOfTokens(
         _swapAmountWei, 
         ethBalance, 
         reserveCD
      );
   } else {
      amountOfTokens = await exchangeContract.getAmountOfTokens(
         _swapAmountWei, 
         reserveCD, 
         ethBalance
      );
   }

   return amountOfTokens;
};

export const swapTokens = async (
   signer, 
   _swapAmountWei,
   tokenToBeReceivedAfterSwap, 
   ethSelected
) => {

   const exchangeContract = new Contract (
      EXCHANGE_CONTRACT_ADDRESS,
      EXCHANGE_CONTRACT_ABI,
      signer 
   );

   const tokenContract = new Contract (
      TOKEN_CONTRACT_ADDRESS,
      TOKEN_CONTRACT_ABI,
      signer
   );

   let tx;

   if(ethSelected) {
      tx = await exchangeContract.ethToCryptoDevToken(
         tokenToBeReceivedAfterSwap, 
         {value: _swapAmountWei, }
      );
   } else  {

      // approve the transaction as it's ERC20
      tx = await tokenContract.approve(
         EXCHANGE_CONTRACT_ADDRESS, 
         _swapAmountWei.toString()
      );

      await tx.wait();

      tx = await exchangeContract.cryptoDevTokenToEth(
         _swapAmountWei, 
         tokenToBeReceivedAfterSwap
      );
   }

   await tx.wait();

}

