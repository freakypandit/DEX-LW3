import { Contract, providers, utils, BigNumber } from "ethers";
import {
  EXCHANGE_CONTRACT_ABI,
  EXCHANGE_CONTRACT_ADDRESS,
} from "../constants";

/**
 * removeLiquidity: Removes the `removeLPTokensWei` amount of LP tokens from
 * liquidity and also the calculated amount of `ether` and `CD` tokens
*/
export const removeLiquidity = async (signer, removeLPTokensWei) => {

   //create anew instance of the contract 
   const exchangeContract = new Contract (
      EXCHANGE_CONTRACT_ADDRESS,
      EXCHANGE_CONTRACT_ABI,
      signer
   );

   const tx = await exchangeContract.removeLiquidity(removeLPTokensWei);
   await tx.wait();
};

/**
 * getTokensAfterRemove: Calculates the amount of `Eth` and `CD` tokens
 * that would be returned back to user after he removes `removeLPTokenWei` amount
 * of LP tokens from the contract
 */

export const getTokensAfterRemove = async (
   provider,
   removeLPTokensWei, 
   _ethBalance, 
   cryptoDevTokenReserve
) => {
   try {

      //create instance 
      const exchangeContract = new Contract (
         EXCHANGE_CONTRACT_ADDRESS, 
         EXCHANGE_CONTRACT_ABI, 
         provider
      );

      const _totalSupply = await exchangeContract.totalSupply();

      // how much amount to remove 
      const _removeEther = _ethBalance.mul(removeLPTokensWei).div(_totalSupply);
      const _removeCD = cryptoDevTokenReserve.mul(removeLPTokensWei).div(_totalSupply);

      return {_removeEther, _removeCD};
   } catch(err) {
      console.error(err);
   }
};