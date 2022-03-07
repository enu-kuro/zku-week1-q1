# Compiling our circuit
circom MerkleTree.circom --r1cs --wasm --sym

# Computing the witness with WebAssembly
node ./MerkleTree_js/generate_witness.js ./MerkleTree_js/MerkleTree.wasm input.json ./MerkleTree_js/witness.wtns

# # Powers of Tau
snarkjs powersoftau new bn128 16 pot12_0000.ptau -v
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -e="random"


# # Phase 2
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v
snarkjs groth16 setup MerkleTree.r1cs pot12_final.ptau MerkleTree_0000.zkey
snarkjs zkey contribute MerkleTree_0000.zkey MerkleTree_0001.zkey --name="1st Contributor Name" -e="random"

# Export the verification key:
snarkjs zkey export verificationkey MerkleTree_0001.zkey verification_key.json


# Generating a Proof
snarkjs groth16 prove MerkleTree_0001.zkey ./MerkleTree_js/witness.wtns proof.json public.json


# Verifying a Proof
snarkjs groth16 verify verification_key.json public.json proof.json

# Verifying from a Smart Contract
# snarkjs zkey export solidityverifier MerkleTree_0001.zkey verifier.sol
# snarkjs generatecall | tee parameters.txt