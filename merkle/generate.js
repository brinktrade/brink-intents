const { StandardMerkleTree } = require('@openzeppelin/merkle-tree')

let values = [
  ["9878"], ["9785"], ["9592"], ["9107"], ["8064"], ["8038"], ["7754"]
];

let tree = StandardMerkleTree.of(values, ["uint256"]);

console.log('Merkle Root: ', tree.root);

for (let [i, v] of tree.entries()) {
  let proof = tree.getProof(i);
  console.log('Value: ', v);
  console.log('Proof: ', proof);
}

let multiProof = tree.getMultiProof([2, 3, 6])
console.log('multi proof for 9592, 9107, and 7754: ', multiProof)


values = [
  ["8"], ["14"], ["64"]
];

tree = StandardMerkleTree.of(values, ["uint256"]);

console.log('Merkle Root: ', tree.root);

for (let [i, v] of tree.entries()) {
  proof = tree.getProof(i);
  console.log('Value: ', v);
  console.log('Proof: ', proof);
}

multiProof = tree.getMultiProof([0, 1])
console.log('multi proof for 8 and 14: ', multiProof)

values = [
  ["5268"], ["4631"], ["3643"]
];

tree = StandardMerkleTree.of(values, ["uint256"]);

console.log('Merkle Root: ["5268"], ["4631"], ["3643"]', tree.root);

for (let [i, v] of tree.entries()) {
  proof = tree.getProof(i);
  console.log('Value: ', v);
  console.log('Proof: ', proof);
}

multiProof = tree.getMultiProof([0, 1])
console.log('multi proof for 5268 and 4631: ', multiProof)