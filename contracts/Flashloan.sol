//SPDX-License-Identifier: Unlicense
// pragma solidity ^0.8.0;
pragma solidity <=0.8.10;


import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";

interface IDODO {
    function flashLoan(
        uint256 baseAmount,
        uint256 quoteAmount,
        address assetTo,
        bytes calldata data
    ) external;

    function _BASE_TOKEN_() external view returns (address);
}

contract DODOFlashloan {
    function dodoFlashLoan(
        address flashLoanPool, //You will make a flashloan from this DODOV2 pool: Pools are in the Factory
        uint256 loanAmount,
        address loanToken
    ) external {
        // Note: The data can be structured with any variables required by your logic. The following code is just an example
        bytes memory data = abi.encode(flashLoanPool, loanToken, loanAmount);
        address flashLoanBase = IDODO(flashLoanPool)._BASE_TOKEN_();

        if (flashLoanBase == loanToken) {
            IDODO(flashLoanPool).flashLoan(loanAmount, 0, address(this), data);
        } else {
            IDODO(flashLoanPool).flashLoan(0, loanAmount, address(this), data);
        }
    }

// Need to implement 2 seperate functions for DODO to Call Back loan as not sure which DODO Pool it will use
// DODO will use either Vending Machine Pool or Private Pool    

    // Note: CallBack function executed by DODOV2(DVM) flashLoan pool
    // Dodo Vending Machine Factory --> 0x79887f65f83bdf15Bcc8736b5e5BcDB48fb8fE13

contract Arbitrage is DODOFlashloan {
    IUniswapV2Router02 public immutable sRouter;
    IUniswapV2Router02 public immutable uRouter;

    address public owner;

    contructor (address _sRouter, address _uRouter) {
        sRouter = IUniswapV2Router02(_sRouter); // Sushiswp V2 Router
        uRouter = IUniswapV2Router02(_uRouter); // Uniswap V2 Router
        owner = msg.sender; // NOTE: Can place Ethereum address of Eth wallet
    }
}
    function DVMFlashLoanCall(
        address sender,
        uint256 baseAmount,
        uint256 quoteAmount,
        bytes calldata data
    ) external {
        console.log("Vending Machine Pool Called...");
        _flashLoanCallBack(sender, baseAmount, quoteAmount, data);
    }

    // Note: CallBack function executed by DODOV2(DPP) flashLoan pool
    // Dodo Private Pool Factory --> 0xd24153244066F0afA9415563bFC7Ba248bfB7a51
    function DPPFlashLoanCall(
        address sender,
        uint256 baseAmount,
        uint256 quoteAmount,
        bytes calldata data
    ) external {
        console.log("Private Pool Called...");
        _flashLoanCallBack(sender, baseAmount, quoteAmount, data);
    }

// After Pool is used will place currency here and do something with it
// Calling flashloan function so flashloan can be given from provider -- DODO Flashloan 
    function _flashLoanCallBack(
        address sender,
        uint256, // base amount
        uint256, // quote amount
        bytes calldata data
    ) internal {  // Pulls out interface data and assigns it to variables be used below
        (address flashLoanPool, address loanToken, uint256 loanAmount) = abi
            .decode(data, (address, address, uint256));

        require(
            sender == address(this) && msg.sender == flashLoanPool,
            "HANDLE_FLASH_NENIED"
        );
    }

// Received Loan -- Use the money here!
// Note: logic using the token from flashLoan pool... *** ARBITRAGE *** //
// Swapping on Uni Swap and Sushiwap
 
    function executeTrade(
        bool _startOnUniswap, // Start on Uniswap yes or no
        address _token0,    // Token arbing from -- Pass in different Token addresses to customize
        address _token1,    // Token arbing against -- Pass in different Token addresses to customize
        uint256 _flashAmount // amount of money taking of with Flashloan
    ) external {
        uint256 balanceBefore = IERC20(_token0).balanceOf(address(this)); // balance before trade
 
        bytes memory data = abi.encode(  // encodes the data packaging it up to be sent 
            _startOnUniswap,
            _token0,
            _token1,
            _flashAmount,
            balanceBefore
        );

    }        
     
     flashloan(_token0, _flashAmount, data); // execution goes to `_flashLoanCallBack Function` -- pass in token you want, how much, any data

    function callFunction( // calls function in order to receive flahloan
        address, // sender
        Info calldata, // accountInfo and data from executeTrade encoding
        bytes calldata data
    ) external onlyPool {
        (
        bool startOnUniswap, // Start on Uniswap yes or no
        address token0,    // Token arbing from -- Pass in different Token addresses to customize
        address token1,    // Token arbing against -- Pass in different Token addresses to customize
        uint256 flashAmount, // amount of money taking of with Flashloan
        uint256 balanceBefore // balance before trade
        ) = abi.decode(data, (bool, address, address, uint256, uint256)); // unpacks the data from executeTrade and places them in vars to be used

        uint256 balanceAfter = IERC20(token0).balanceOf(address(this)); // Have received the Flashloan

        require(
            balanceAfter - balanceBefore == flashAmount,
            "contract did not get the loan" 
        );       

    // Use the flashloan funds received to do the Arbitrage
    // Trades on Uniswap V2 using the swapTokensforTokens function
    // Calls Sushiswap or Uniswap Router 
    // Determines whether to start on Uniswap or Sushiswap - which direction to do the exchange to buy and then sell on
    
        address[] memory path = new address[](2);

        path[0] = token0;
        path[1] = token1;

        if (startOnUniswap) {
            _swapOnUniswap(path, flashAmount, 0);

            path[0] = token1;
            path[1] = token0;

            _swapOnSushiswap(
                path,
                IERC20(token1).balanceOf(address(this)),
                (flashAmount + 1)
            );
        } else {
            _swapOnSushiswap(path, flashAmount, 0);

            path[0] = token1;
            path[1] = token0;

            _swapOnUniswap(
                path,
                IERC20(token1).balanceOf(address(this)),
                (_flashAmount + 1)
            );
        }


    function _swapOnUniswap(
        address[] memory _path,
        uint256 _amountIn,
        uint256 _amountOut
    ) internal {
        require(
            IERC20(_path[0]).approve(address(uRouter), _amountIn),
            "Uniswap approval failed."
        );

        uRouter.swapExactTokensForTokens(
            _amountIn,
            _amountOut,
            _path,
            address(this),
            (block.timestamp + 1200)
        );
    }

    function _swapOnSushiswap(
        address[] memory _path,
        uint256 _amountIn,
        uint256 _amountOut
    ) internal {
        require(
            IERC20(_path[0]).approve(address(sRouter), _amountIn),
            "Sushiswap approval failed."
        );

        sRouter.swapExactTokensForTokens(
            _amountIn,
            _amountOut,
            _path,
            address(this),
            (block.timestamp + 1200)
        );
    }
    }
    //Return funds
    IERC20(loanToken).transfer(flashLoanPool, loanAmount);
        

   } //Flash Loan end


