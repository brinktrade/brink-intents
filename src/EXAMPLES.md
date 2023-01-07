# EXAMPLES

OrderExecutionTarget01 allows for the execution of signed orders composed from low-level primatives. Users can build and sign custom
strategies with these primatives. Strategy execution is offloaded to MEV bots who earn arbitrage profits by crossing signed
order liquidity with on-chain market liquidity. This allows users to automate execution of simple limit and stop-loss swap orders, or to
automate complex market making strategies involving multi-order execution.


## Limit Order

  A simple limit swap of TokenA to TokenB. This is one order composed of 3 primatives

  Order_0:
    requireBlockNotMined(<blockNumber>)
    useBit(1)
    swap(<tokenA_data>, <tokenB_data>)


## Stop-loss Order

  A simple stop-loss order for a TokenA -> TokenB swap when a price lower bound is met. This is one order composed of 4 primatives

  Order_0:
    requireBlockNotMined(<blockNumber>)
    requirePriceLowerBound(<priceOracle>, TokenA, TokenB, <value>)
    useBit(1)
    swap(<tokenA_data>, <tokenB_data>)


## Stop-loss for NFT w/ Dutch Auction

  A stop-loss order for an NFT -> ERC20 auction that can be initialized when a price lower bound is met. dutchAuction fn can create the auction
  as a separate contract.

  Order_0:
    requireBlockNotMined(<blockNumber>)
    requirePriceLowerBound(<priceOracle>, TokenA, TokenB, <value>)
    useBit(1)
    dutchAuction(
      <id: hash_0>,
      TokenAmount{ ERC721, <addressOfA>}, <nftID>, 1 },
      TokenData{ ETH },
      <startPrice: 1.00>,
      <endPrice: 0.00>,
      <duration: 10000>
    )

## Stop-loss for NFT w/ Listing + Auction

  A stop-loss order for an NFT that creates a Seaport listing and a dutch auction.

  beforeCalls:
    requireBitNotUsed(1)
  Order_0:
    requireBlockNotMined(<blockNumber>)
    requirePriceLowerBound(<priceOracle>, TokenA, TokenB, <value>)
    dutchAuction(
      <id: hash_0>,
      TokenAmount{ ERC721, <addressOfA>}, <nftID>, 1 },
      TokenData{ ETH },
      <startPrice: 1.00>,
      <endPrice: 0.00>,
      <duration: 10000>,
      [...unsignedDataForInitializerReward]
    )
  Order_1:
    requireBlockNotMined(<blockNumber>)
    requireDutchAuctionOpen(hash_0)
    createSeaportListing(
      <id: hash_1>
      TokenAmount{ ERC721, <addressOfA>}, <nftID>, 1 },
      TokenData{ ETH, <priceLowerBound - 0.05> },
      [...unsignedDataForInitializerReward]
    )
  Order_2:
    requireDutchAuctionOpen(hash_0)
    requireSeaportListingOpen(hash_1)
    dutchAuctionBuy(
      hash_0,
      [...unsignedDataForDutchAuctionBuy]
    )


## Trailing Stop

  Market swap TokenA -> TokenB when price decreases by a min amount.

  This sells 1 A -> B at market price, if the price of A/B drops 10% or more in 1 hour (3600s)

  Order_0:
    requireBlockNotMined(<blockNumber>)
    requirePriceDecrease(<priceDeltaOracleForAB>, TokenA, TokenB, <startTime: timestampWhenSigned>, <duration: 3600>, <value: 10.00>)
    useBit(1)
    marketSwap(
      <priceOracleForAB>,
      TokenAmount{ ERC20, <addressOfA>, 1.00 },
      TokenData{ ERC20, <addressOfB> },
      <mevReward: 50.00 B>
    )


## Flip Strategy

  A strategy composed of two limit orders. It allows an A->B swap at a lower bound. When this swap fills, it enables a B->A swap at an upper
  bound. In other words, this strategy attempts to buy B at a low price and sell B at a high price, to capture profit in A.

  beforeCalls:
    requireBlockNotMined(<blockNumber>)
    requireBitNotUsed(1)
  Order_0:
    limitSwap(
      hash_0,
      TokenAmount{ ERC20, <addressOfA>, 120.00 }
      TokenAmount{ ERC721, <addressOfB>}, 1 }
    )
  Order_1:
    requireLimitSwapFilled(hash_0)
    limitSwap(
      hash_1,
      TokenAmount{ ERC721, <addressOfB>}, 1 }
      TokenAmount{ ERC20, <addressOfA>, 125.00 }
    )


## Classic Bracket Order

  Similar to the "Flip Strategy" above, but adds a stop-loss.
  - Order_0 is a limit swap for 1,200 A -> 1 B. Once filled, it enabled Order_1 and Order_2.
  - Order_1 attempts to capture 100 A in profit by swapping for 1 B -> 1,300 A.
  - Order_2 is a stop-loss for B. It attempts to cap losses at 150 A. It will swap 1 B -> 1,050 A when price is 1,100 or less, which provides an
    MEV arb reward of 50 A max.

  beforeCalls:
    requireBlockNotMined(<blockNumber>)
  Order_0:
    swap(
      0,
      TokenAmount{ ERC20, <addressOfA>, 1200.00 }
      TokenAmount{ ERC20, <addressOfB>, 1.00 }
    )
  Order_1:
    requireLimitSwapFilled(0)
    requireLimitSwapOpen(2)
    swap(
      1,
      TokenAmount{ ERC20, <addressOfB>, 1.00 }
      TokenAmount{ ERC20, <addressOfA>, 1300.00 }
    )
  Order_2:
    requireLimitSwapFilled(0)
    requireLimitSwapOpen(1)
    requirePriceLowerBound(<priceOracleForBA>, TokenB, TokenA, <value: 1100.00>)
    swap(
      2,
      TokenAmount{ ERC20, <addressOfB>, 1.00 }
      TokenAmount{ ERC20, <addressOfA>, 1050.00 }
    )


## Trailing Stop Limit + Upper Bound Bracket

  Market swap TokenA -> TokenB when price increases by a min amount. That triggers a limit for TokenB -> TokenA to capture profit in Token A

  This swaps 1 A -> B at market price, if the price of A/B increases 10% or more in 1 hour (3600s), triggering a limit order for the
  amount of B obtained -> 1.05 A. This would lock in a profit of 0.05 A (+5%).

  beforeCalls:
    requireBlockNotMined(<blockNumber>)
  Order_0:
    requirePriceIncrease(<priceDeltaOracleForAB>, TokenA, TokenB, <startTime: timestampWhenSigned>, <duration: 3600>, <value: 10.00>)
    useBit(1)
    marketSwap(
      <priceOracleForAB>,
      TokenAmount{ ERC20, <addressOfA>, 1.00 },
      TokenData{ ERC20, <addressOfB> },
      <mevReward: 50.00 B>,
      <outputAmountPtr: hash_0>
    )
  Order_1:
    requireBitUsed(1)
    useBit(2)
    dynamicInputSwap(
      TokenAmount{ ERC20, <addressOfB>}, <amountPtr: hash_0> }
      TokenAmount{ ERC20, <addressOfA>, 1.05 }
    )
  


## Market Making Range

  Similar to the "Flip Strategy", but continuously executes in either direction (A->B and B->A). We called this a "ping-pong order". It's a
  market making position that attempts to capture spread between A and B bid/ask as profit.

  The strategy can be canceled by setting bit 1 USED

  Each time Order_1 executes, it captures 5.00 A in profit.

  beforeCalls:
    requireBlockNotMined(<blockNumber>)
    requireBitNotUsed(1)
  Order_0:
    limitSwap(
      0,
      TokenAmount{ ERC20, <addressOfA>, 1200.00 }
      TokenAmount{ ERC20, <addressOfB>, 1.00 }
    )
    requireLimitSwapFilled(0)
  Order_1:
    requireLimitSwapFilled(0)
    limitSwap(
      1,
      TokenAmount{ ERC20, <addressOfB>, 1.00 }
      TokenAmount{ ERC20, <addressOfA>, 1205.00 }
    )
    requireLimitSwapFilled(1)
    resetLimitSwap(0)


## Market Making Range + Stop-Loss bounds

  Same as "Market Making Range" above, but adds two stop-loss orders for A and B, to cap losses when price moves away from the spread range
  in either direction. If either stop-loss executes, the strategy is canceled.

  Order_2 is a stop-loss for B->A @ 1 A = 1,100 B, valid when the A->B swap (Order_0) has filled last, so user is holding B
  Order_3 is a stop-loss for A->B @ 1 A = 1,300 B, valid when the B->A swap (Order_1) has filled last, so user is holding A

  beforeCalls:
    requireBlockNotMined(<blockNumber>)
    requireBitNotUsed(1)
  Order_0:
    useBit(2)
    swap(
      TokenAmount{ ERC20, <addressOfA>, 1200.00 }
      TokenAmount{ ERC20, <addressOfB>, 1.00 }
    )
  Order_1:
    setBitNotUsed(2)
    swap(
      TokenAmount{ ERC20, <addressOfB>, 1.00 }
      TokenAmount{ ERC20, <addressOfA>, 1205.00 }
    )
  Order_2:
    requireBitUsed(2)
    requirePriceLowerBound(<priceOracleForBA>, TokenB, TokenA, <value: 1100.00>)
    useBit(1)
    swap(
      TokenAmount{ ERC20, <addressOfB>, 1.00 }
      TokenAmount{ ERC20, <addressOfA>, 1045.00 } // max 55.00 MEV reward in A, or 5%
    )
  Order_3:
    requireBitNotUsed(2)
    requirePriceLowerBound(<priceOracleForAB>, TokenA, TokenB, <value: 0.00076923>) // = 1 / 1300
    useBit(1)
    swap(
      TokenAmount{ ERC20, <addressOfA>}, 1300.00 }
      TokenAmount{ ERC20, <addressOfB>, 0.95 } // max 0.05 MEV reward in B, or 5%
    )


## Market Making Range w/ partial fill

  the `invertLimitSwaps()` function inverts the % filled on Order_1 based on Order_0's % filled, and vice-versa. For example, if Order_1 is 25% filled,
  this will set Order_2 to 75% filled. When no state has been set, it defaults Order_0 to be 0% filled and Order_1 to be 100% filled.

  beforeCalls:
    requireBlockNotMined(<blockNumber>)
    requireBitNotUsed(1)
    invertLimitSwaps(hash_0, hash_1)
  Order_0:
    limitSwap(
      <hash_0>,
      TokenAmount{ ERC20, <addressOfA>, 100.00 },
      TokenAmount{ ERC721, <addressOfB> },
      <price: 0.10> // 100 A = 10 B
    )
  Order_1:
    limitSwap(
      <hash_1>,
      TokenAmount{ ERC721, <addressOfB>, 10 }
      TokenAmount{ ERC20, <addressOfA> },
      <price: 11.00> // 10 B = 110 A
    )


## Token Cost Averaging

  Sell A for B at market price, every n blocks. It's a DCA (dollar cost averaging) strategy.

  the order below:
    - can be canceled by setting bit 1 USED
    - reverts if it has been run 100 times ( max of 100.00 A sold )
    - can be run approximately once a week (~20,160 blocks)
    - has an MEV incentive reward of maximum 50.00 B per sale

  Order_0
    requireBitNotUsed(1)
    maxRuns(100)
    minBlocksElapsed(20160)
    marketSwap(
      <priceOracleForAB>,
      TokenAmount{ ERC20, <addressOfA>, 1.00 },
      TokenData{ ERC20, <addressOfB> },
      <mevReward: 50.00 B>
    )
