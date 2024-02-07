/// SPDX-License-Identifier: The Unlicense

pragma solidity ^0.8.24;

import 'forgery-sdk/Server.sol';
import 'forgery-sdk/JSONBodyParser.sol';
import 'forgery-sdk/JSONBodyWriter.sol';
import './interfaces/QuoterV2.sol';

contract Index is Server {
    using JSONBodyParser for Request;
    using JSONBodyWriter for Response;

    QuoterV2 constant quoter = QuoterV2(0x61fFE014bA17989E743c5F6cB21bF9697530B21e);

    function start () external override {
        router.post('/quote', quote);
    }

    function quote (
        Request calldata request
    ) public {
        address[] memory tokens = request.json().at('tokens').asAddressArray();
        uint amountIn = request.json().at('amountIn').asUint();
        uint fee = request.json().at('fee').asUint();

        (uint amountOut,,,) = quoter.quoteExactInputSingle(
            QuoterV2.QuoteExactInputSingleParams({
                tokenIn: tokens[0],
                tokenOut: tokens[1],
                amountIn: amountIn,
                fee: uint24(fee),
                sqrtPriceLimitX96: 0
            })
        );

        response.status = 200;
        response.header('content-type', 'application/json');
        response.write('amountOut', amountOut);
    }
}
