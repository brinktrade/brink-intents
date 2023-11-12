// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.17;

import "forge-std/Test.sol";
import "./Helper.sol";

contract IntentTarget01_execute_reverts is Test, Helper  {

  function setUp () public {
    setupAll();
  }

  // when given an intent index that is out of bounds, should revert with BadIntentIndex
  function testExecute_BadIntentIndex () public {
    Segment[] memory segments_intent0 = new Segment[](1);
    segments_intent0[0] = Segment(new bytes(0), false);
    Intent[] memory intents = new Intent[](1);
    intents[0] = Intent(segments_intent0);
    Declaration memory declaration = Declaration(
      address(segments),
      intents,
      new bytes[](0),
      new bytes[](0)
    );

    vm.expectRevert(BadIntentIndex.selector);
    intentTarget.execute(
      declaration,
      UnsignedData(
        1, // intent only has intent0, index 1 is out of bounds
        new bytes[](0)
      )
    );
  }

  // when an unsigned call is required but not provided, should revert with UnsignedCallRequired
  function testExecute_UnsignedCallRequired () public {
    Segment[] memory segments_intent0 = new Segment[](1);
    segments_intent0[0] = Segment(new bytes(0), true); // require unsigned call
    Intent[] memory intents = new Intent[](1);
    intents[0] = Intent(segments_intent0);
    Declaration memory declaration = Declaration(
      address(segments),
      intents,
      new bytes[](0),
      new bytes[](0)
    );

    vm.expectRevert(UnsignedCallRequired.selector);
    intentTarget.execute(
      declaration,
      UnsignedData(
        0,
        new bytes[](0) // no unsigned call provided
      )
    );
  }

}
