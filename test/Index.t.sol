/// SPDX-License-Identifier: The Unlicense

pragma solidity ^0.8.24;

import {Test, console} from 'forge-std/Test.sol';
import '../src/Index.sol';

contract IndexTest is Test {
    Index testContract;
    address constant quoter = 0x61fFE014bA17989E743c5F6cB21bF9697530B21e;

    function setUp () public {
        // Deploy a new instance for every test to clean the storage
        testContract = new Index();
    }

    function test_quoter () public {
        // Prepare the request
        Request memory request = Request({
            method: 'GET',
            uri: '/quoter',
            headers: new Header[](0),
            body: '{\
                "amountIn":"1000000000000000000",\
                "fee": 500,\
                "tokens": [\
                    "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",\
                    "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"\
                ]\
            }'
        });

        // Prepare the encoded call that we want to spy on
        bytes memory call = abi.encodeWithSelector(
            QuoterV2.quoteExactInputSingle.selector,
            (QuoterV2.QuoteExactInputSingleParams({
                tokenIn: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,
                tokenOut: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,
                amountIn: 1 ether,
                fee: 500,
                sqrtPriceLimitX96: 0
            }))
        );

        // Not running on a fork that has Uniswap deployed, so we need to mock it
        vm.mockCall(quoter, call, abi.encode(uint256(0), uint160(0), uint32(0), uint256(0)));

        // Assert the Uniswap quoter was called correctly
        vm.expectCall(quoter, 0, call);
        testContract.quote(request);
    }
}
