const { StandardMerkleTree } = require('@openzeppelin/merkle-tree')

const values = [
  ["9878"], ["9785"], ["9592"], ["9107"], ["8064"], ["8038"], ["7754"]
];

const tree = StandardMerkleTree.of(values, ["uint256"]);

console.log('Merkle Root: ', tree.root);

for (const [i, v] of tree.entries()) {
  const proof = tree.getProof(i);
  console.log('Value: ', v);
  console.log('Proof: ', proof);
}

const multiProof = tree.getMultiProof([2, 3, 6])
console.log('multi proof for 9592, 9107, and 7754: ', multiProof)
