// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

import "../interfaces/IUnigem20Factory.sol";
import "../exchange/Unigem20Pair.sol";

contract Unigem20Factory is IUnigem20Factory {
    address public override feeTo;
    address public override feeToSetter;

    mapping(address => mapping(address => address)) public override getPair;
    address[] public override allPairs;

    constructor() {
        feeToSetter = msg.sender;
    }

    function allPairsLength() external override view returns (uint) {
        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB) external override returns (address pair) {
        require(tokenA != tokenB, "Unigem20: IDENTICAL_ADDRESSES");
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "Unigem20: ZERO_ADDRESS");
        require(getPair[token0][token1] == address(0), "Unigem20: PAIR_EXISTS"); // single check is sufficient
        bytes memory bytecode = type(Unigem20Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IUnigem20Pair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) external override {
        require(msg.sender == feeToSetter, "Unigem20: FORBIDDEN");
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external override {
        require(msg.sender == feeToSetter, "Unigem20: FORBIDDEN");
        feeToSetter = _feeToSetter;
    }
}
