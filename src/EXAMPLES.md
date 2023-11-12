# EXAMPLES

IntentTarget01 allows for the execution of signed declarations of intents composed from low-level segments. Users can build and sign custom
intents with these segments. Intent execution is offloaded to MEV bots who earn arbitrage profits by crossing signed
intent liquidity with on-chain market liquidity. This allows users to automate execution of simple limit and stop-loss swap intents, or to
automate complex market making intents involving multi-intent execution.


## Limit Intent

  A simple limit swap of TokenA to TokenB. This is one intent composed of 3 segments

  Intent_0:
    requireBlockNotMined(<blockNumber>)
    useBit(1)
    swap(<tokenA_data>, <tokenB_data>)


## Stop-loss Intent

  A simple stop-loss intent for a TokenA -> TokenB swap when a price lower bound is met. This is one intent composed of 4 segments

  Intent_0:
    requireBlockNotMined(<blockNumber>)
    requirePriceLowerBound(<priceOracle>, TokenA, TokenB, <value>)
    useBit(1)
    swap(<tokenA_data>, <tokenB_data>)


## Stop-loss for NFT w/ Dutch Auction

  A stop-loss intent for an NFT -> ERC20 auction that can be initialized when a price lower bound is met. dutchAuction fn can create the auction
  as a separate contract.

  Intent_0:
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

  A stop-loss intent for an NFT that creates a Seaport listing and a dutch auction.

  beforeCalls:
    requireBitNotUsed(1)
  Intent_0:
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
  Intent_1:
    requireBlockNotMined(<blockNumber>)
    requireDutchAuctionOpen(hash_0)
    createSeaportListing(
      <id: hash_1>
      TokenAmount{ ERC721, <addressOfA>}, <nftID>, 1 },
      TokenData{ ETH, <priceLowerBound - 0.05> },
      [...unsignedDataForInitializerReward]
    )
  Intent_2:
    requireDutchAuctionOpen(hash_0)
    requireSeaportListingOpen(hash_1)
    dutchAuctionBuy(
      hash_0,
      [...unsignedDataForDutchAuctionBuy]
    )


## Trailing Stop

  Market swap TokenA -> TokenB when price decreases by a min amount.

  This sells 1 A -> B at market price, if the price of A/B drops 10% or more in 1 hour (3600s)

  Intent_0:
    requireBlockNotMined(<blockNumber>)
    requirePriceDecrease(<priceDeltaOracleForAB>, TokenA, TokenB, <startTime: timestampWhenSigned>, <duration: 3600>, <value: 10.00>)
    useBit(1)
    marketSwap(
      <priceOracleForAB>,
      TokenAmount{ ERC20, <addressOfA>, 1.00 },
      TokenData{ ERC20, <addressOfB> },
      <mevReward: 50.00 B>
    )


## Flip Intent

  A intent composed of two limit intents. It allows an A->B swap at a lower bound. When this swap fills, it enables a B->A swap at an upper
  bound. In other words, this intent attempts to buy B at a low price and sell B at a high price, to capture profit in A.

  beforeCalls:
    requireBlockNotMined(<blockNumber>)
    requireBitNotUsed(1)
  Intent_0:
    limitSwap(
      hash_0,
      TokenAmount{ ERC20, <addressOfA>, 120.00 }
      TokenAmount{ ERC721, <addressOfB>}, 1 }
    )
  Intent_1:
    requireLimitSwapFilled(hash_0)
    limitSwap(
      hash_1,
      TokenAmount{ ERC721, <addressOfB>}, 1 }
      TokenAmount{ ERC20, <addressOfA>, 125.00 }
    )


## Classic Bracket Intent

  Similar to the "Flip Intent" above, but adds a stop-loss.
  - Intent_0 is a limit swap for 1,200 A -> 1 B. Once filled, it enabled Intent_1 and Intent_2.
  - Intent_1 attempts to capture 100 A in profit by swapping for 1 B -> 1,300 A.
  - Intent_2 is a stop-loss for B. It attempts to cap losses at 150 A. It will swap 1 B -> 1,050 A when price is 1,100 or less, which provides an
    MEV arb reward of 50 A max.

  beforeCalls:
    requireBlockNotMined(<blockNumber>)
  Intent_0:
    swap(
      0,
      TokenAmount{ ERC20, <addressOfA>, 1200.00 }
      TokenAmount{ ERC20, <addressOfB>, 1.00 }
    )
  Intent_1:
    requireLimitSwapFilled(0)
    requireLimitSwapOpen(2)
    swap(
      1,
      TokenAmount{ ERC20, <addressOfB>, 1.00 }
      TokenAmount{ ERC20, <addressOfA>, 1300.00 }
    )
  Intent_2:
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

  This swaps 1 A -> B at market price, if the price of A/B increases 10% or more in 1 hour (3600s), triggering a limit intent for the
  amount of B obtained -> 1.05 A. This would lock in a profit of 0.05 A (+5%).

  beforeCalls:
    requireBlockNotMined(<blockNumber>)
  Intent_0:
    requirePriceIncrease(<priceDeltaOracleForAB>, TokenA, TokenB, <startTime: timestampWhenSigned>, <duration: 3600>, <value: 10.00>)
    useBit(1)
    marketSwap(
      <priceOracleForAB>,
      TokenAmount{ ERC20, <addressOfA>, 1.00 },
      TokenData{ ERC20, <addressOfB> },
      <mevReward: 50.00 B>,
      <outputAmountPtr: hash_0>
    )
  Intent_1:
    requireBitUsed(1)
    useBit(2)
    dynamicInputSwap(
      TokenAmount{ ERC20, <addressOfB>}, <amountPtr: hash_0> }
      TokenAmount{ ERC20, <addressOfA>, 1.05 }
    )
  


## Market Making Range

  Similar to the "Flip Intent", but continuously executes in either direction (A->B and B->A). We called this a "ping-pong intent". It's a
  market making position that attempts to capture spread between A and B bid/ask as profit.

  The intent can be canceled by setting bit 1 USED

  Each time Intent_1 executes, it captures 5.00 A in profit.

  beforeCalls:
    requireBlockNotMined(<blockNumber>)
    requireBitNotUsed(1)
  Intent_0:
    limitSwap(
      0,
      TokenAmount{ ERC20, <addressOfA>, 1200.00 }
      TokenAmount{ ERC20, <addressOfB>, 1.00 }
    )
    requireLimitSwapFilled(0)
  Intent_1:
    requireLimitSwapFilled(0)
    limitSwap(
      1,
      TokenAmount{ ERC20, <addressOfB>, 1.00 }
      TokenAmount{ ERC20, <addressOfA>, 1205.00 }
    )
    requireLimitSwapFilled(1)
    resetLimitSwap(0)


## Market Making Range + Stop-Loss bounds

  Same as "Market Making Range" above, but adds two stop-loss intents for A and B, to cap losses when price moves away from the spread range
  in either direction. If either stop-loss executes, the intent is canceled.

  Intent_2 is a stop-loss for B->A @ 1 A = 1,100 B, valid when the A->B swap (Intent_0) has filled last, so user is holding B
  Intent_3 is a stop-loss for A->B @ 1 A = 1,300 B, valid when the B->A swap (Intent_1) has filled last, so user is holding A

  beforeCalls:
    requireBlockNotMined(<blockNumber>)
    requireBitNotUsed(1)
  Intent_0:
    useBit(2)
    swap(
      TokenAmount{ ERC20, <addressOfA>, 1200.00 }
      TokenAmount{ ERC20, <addressOfB>, 1.00 }
    )
  Intent_1:
    setBitNotUsed(2)
    swap(
      TokenAmount{ ERC20, <addressOfB>, 1.00 }
      TokenAmount{ ERC20, <addressOfA>, 1205.00 }
    )
  Intent_2:
    requireBitUsed(2)
    requirePriceLowerBound(<priceOracleForBA>, TokenB, TokenA, <value: 1100.00>)
    useBit(1)
    swap(
      TokenAmount{ ERC20, <addressOfB>, 1.00 }
      TokenAmount{ ERC20, <addressOfA>, 1045.00 } // max 55.00 MEV reward in A, or 5%
    )
  Intent_3:
    requireBitNotUsed(2)
    requirePriceLowerBound(<priceOracleForAB>, TokenA, TokenB, <value: 0.00076923>) // = 1 / 1300
    useBit(1)
    swap(
      TokenAmount{ ERC20, <addressOfA>}, 1300.00 }
      TokenAmount{ ERC20, <addressOfB>, 0.95 } // max 0.05 MEV reward in B, or 5%
    )


## Market Making Range w/ partial fill

  the `invertLimitSwaps()` function inverts the % filled on Intent_1 based on Intent_0's % filled, and vice-versa. For example, if Intent_1 is 25% filled,
  this will set Intent_2 to 75% filled. When no state has been set, it defaults Intent_0 to be 0% filled and Intent_1 to be 100% filled.

  beforeCalls:
    requireBlockNotMined(<blockNumber>)
    requireBitNotUsed(1)
    invertLimitSwaps(hash_0, hash_1)
  Intent_0:
    limitSwap(
      <hash_0>,
      TokenAmount{ ERC20, <addressOfA>, 100.00 },
      TokenAmount{ ERC721, <addressOfB> },
      <price: 0.10> // 100 A = 10 B
    )
  Intent_1:
    limitSwap(
      <hash_1>,
      TokenAmount{ ERC721, <addressOfB>, 10 }
      TokenAmount{ ERC20, <addressOfA> },
      <price: 11.00> // 10 B = 110 A
    )


## Token Cost Averaging

  Sell A for B at market price, every n blocks. It's a DCA (dollar cost averaging) intent.

  the intent below:
    - can be canceled by setting bit 1 USED
    - reverts if it has been run 100 times ( max of 100.00 A sold )
    - can be run approximately once a week (~20,160 blocks)
    - has an MEV incentive reward of maximum 50.00 B per sale

  Intent_0
    requireBitNotUsed(1)
    maxRuns(100)
    minBlocksElapsed(20160)
    marketSwap(
      <priceOracleForAB>,
      TokenAmount{ ERC20, <addressOfA>, 1.00 },
      TokenData{ ERC20, <addressOfB> },
      <mevReward: 50.00 B>
    )
