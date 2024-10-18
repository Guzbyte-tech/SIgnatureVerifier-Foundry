// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract WhitelistedToken is ERC20, Ownable {
    using ECDSA for bytes32;

    mapping(address => bool) public whitelist;
    mapping(address => bool) public hasClaimed;

    constructor() ERC20("GuzToken", "GTK") {
        _mint(address(this), 100000 * 10 ** decimals());
    }

    function addToWhitelist(address[] memory _addresses) external onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) {
            whitelist[_addresses[i]] = true;
        }
    }

    function claimTokens(uint256 _amount, bytes32 _messageHash, bytes memory _signature) external {
        require(whitelist[msg.sender], "Address not whitelisted");
        require(!hasClaimed[msg.sender], "Tokens already claimed");

        address signer = _messageHash.toEthSignedMessageHash().recover(_signature);

        require(signer == msg.sender, "Invalid signature");

        hasClaimed[msg.sender] = true;

        _transfer(address(this), msg.sender, _amount);
    }

    function getMessageHash(address _claimer, uint256 _amount) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_claimer, _amount));
    }
}