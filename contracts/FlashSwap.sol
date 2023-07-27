// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.8;

import "hardhat/console.sol";
import "./libraries/UniswapV2Library.sol";
import "./libraries/SafeERC20.sol";
import "./interfaces/IUniswapV2Router01.sol";
import "./interfaces/IUniswapV2Router02.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IUniswapV2Factory.sol";
import "./interfaces/IERC20.sol";

contract FlashSwap {
    using SafeERC20 for IERC20;

    //Factory and routing AND TOKEN addressES
    address private constant PANCAKE_FACTORY = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    address private constant PANCAKE_ROUTER =  0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address private constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address private constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address private constant CAKE = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82;
    address private constant USDT = 0x55d398326f99059fF775485246999027B3197955;
    address private constant CROX = 0x2c094F5A7D1146BB93850f629501eB749f6Ed491;

    uint256 private deadline = block.timestamp + 1 days;
    uint256 private constant MAX_INT = 115792089237316195423570985008687907853269984665640564039457584007913129639935;

    //FUND SMART CONTRACT-we will not use this function, but you can see how we deposit tokens to our contract.
    //but what about approve? Is this contract to CONTRACT? If so, approve is not needed?
    function fundFlashSwapContract(address _owner, address _token, uint256 _amount) public {
        IERC20(_token).transferFrom(_owner, address(this), _amount);
    }

    //GET CONTRACT BALANCE
    function getBalanceOfToken(address _token) public view returns(uint256) {
        return IERC20(_token).balanceOf(address(this));
    }

    //INITIATE ARBITRAGE
    //Receiving loan and performing arbitrage
    function startArbitrage(address _tokenBorrow, uint256 _amount) external {
        IERC20(BUSD).safeApprove(address(PANCAKE_ROUTER), MAX_INT);
        IERC20(USDT).safeApprove(address(PANCAKE_ROUTER), MAX_INT);
        IERC20(CROX).safeApprove(address(PANCAKE_ROUTER), MAX_INT);
        IERC20(CAKE).safeApprove(address(PANCAKE_ROUTER), MAX_INT);

        //get the factory pair address for combined tokens
        address pair = IUniswapV2Factory(PANCAKE_FACTORY).getPair(_tokenBorrow, WBNB);
        require(pair != address(0), "pool does not exist");

        //figure out which token (0 or 1) has the amount and assign
        address token0 = IUniswapV2Pair(pair).token0();
        address token1 = IUniswapV2Pair(pair).token1();
        uint amount0Out = _tokenBorrow == token0 ? _amount : 0;
        uint amount1Out = _tokenBorrow == token1 ? _amount : 0;

        //passing data as bytes to trigger flash loan, otherwise it will be a normal swap
        bytes memory data = abi.encode(_tokenBorrow, _amount);

        //execute the initial swap to get the loan
        IUniswapV2Pair(pair).swap(amount0Out, amount1Out, address(this), data);
    }

    function pancakeCall(address _sender, uint256 _amount0, uint256 _amount1, bytes calldata _data) external {

    }
}
