// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

import {PermitUSDCCollector} from "../src/gasless.sol";
import {IUSDC} from "../src/Interface/IUSDC.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract GaslessTest is Test {
    using ECDSA for bytes32;
    PermitUSDCCollector public permitUSDCCollector;
    IUSDC public usdc;

    // USDC permit typehash
    bytes32 public constant PERMIT_TYPEHASH =
        0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

    bytes32 public constant DOMAIN_SEPARATOR =
        0x02fa7265e7c5d81118673727957699e4d68f74cd74b7db77da710fe8a2c7834f;

    // USDC contract address on Base
    address constant USDC_ADDRESS = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;
    address owner = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 ownerPvtKey =
        0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    // (address owner, uint256 pvtKey) = makeAddrAndKey("owner");

    function setUp() public {
        permitUSDCCollector = new PermitUSDCCollector();
        deal(USDC_ADDRESS, owner, 1000000000);
        usdc = IUSDC(0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913);

        console.log("owner's balance", usdc.balanceOf(owner));
    }

    function test_permitAndCollect() public {
        uint256 amount = 100000000; // 100 USDC (6 decimals)
        uint256 deadline = block.timestamp + 1000;
        address receiver = address(this);

        vm.startPrank(owner);

        uint256 nonce = usdc.nonces(owner);

        // Create the permit struct hash
        bytes32 structHash = keccak256(
            abi.encode(
                PERMIT_TYPEHASH,
                owner,
                address(permitUSDCCollector),
                amount,
                nonce++,
                deadline
            )
        );

        // Create the digest to sign
        // bytes32 digest = keccak256(
        //     abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash)
        // );

        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash)
        );

        // Sign the digest

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPvtKey, digest);

        // Return the signature
        bytes memory signature = abi.encodePacked(r, s, v);

        permitUSDCCollector.permitAndCollect(
            amount,
            deadline,
            receiver,
            signature
        );
        vm.stopPrank();

        // Verify the USDC was transferred to the receiver
        assertEq(
            usdc.balanceOf(receiver),
            amount,
            "USDC should be transferred to receiver"
        );
        assertEq(
            usdc.balanceOf(owner),
            1000000000 - amount,
            "Owner balance should be reduced"
        );
    }

    function _generatePermitSignature(
        address spender,
        uint256 value,
        uint256 deadline
    ) internal view returns (bytes memory) {
        // Get the current nonce for the owner
        uint256 nonce = usdc.nonces(owner);

        // Create the permit struct hash
        bytes32 structHash = keccak256(
            abi.encode(
                PERMIT_TYPEHASH,
                owner,
                spender,
                value,
                nonce++,
                deadline
            )
        );

        // Create the digest to sign
        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash)
        );

        // Sign the digest

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPvtKey, digest);

        // Return the signature
        return abi.encodePacked(r, s, v);
    }

    // function testFail_permitAndCollectWithExpiredDeadline() public {
    //     uint256 amount = 100000000; // 100 USDC
    //     uint256 deadline = block.timestamp - 1; // Expired deadline
    //     address receiver = address(this);

    //     bytes memory signature = _generatePermitSignature(
    //         owner,
    //         address(permitUSDCCollector),
    //         amount,
    //         deadline
    //     );

    //     vm.prank(owner);
    //     permitUSDCCollector.permitAndCollect(
    //         amount,
    //         deadline,
    //         receiver,
    //         signature
    //     );
    // }

    // function testFail_permitAndCollectWithWrongSigner() public {
    //     uint256 amount = 100000000; // 100 USDC
    //     uint256 deadline = block.timestamp + 1000;
    //     address receiver = address(this);

    //     // Use a different private key to generate signature
    //     uint256 wrongPrivateKey = 0x9876543210987654321098765432109876543210987654321098765432109876;
    //     address wrongOwner = vm.addr(wrongPrivateKey);

    //     // Generate signature with wrong owner
    //     uint256 nonce = usdc.nonces(wrongOwner);
    //     bytes32 structHash = keccak256(
    //         abi.encode(
    //             PERMIT_TYPEHASH,
    //             wrongOwner,
    //             address(permitUSDCCollector),
    //             amount,
    //             nonce,
    //             deadline
    //         )
    //     );

    //     bytes32 domainSeparator = usdc._domainSeparator();
    //     bytes32 digest = keccak256(
    //         abi.encodePacked("\x19\x01", domainSeparator, structHash)
    //     );

    //     (uint8 v, bytes32 r, bytes32 s) = vm.sign(wrongPrivateKey, digest);
    //     bytes memory signature = abi.encodePacked(r, s, v);

    //     // Try to call with wrong signer
    //     vm.prank(owner);
    //     permitUSDCCollector.permitAndCollect(
    //         amount,
    //         deadline,
    //         receiver,
    //         signature
    //     );
    // }
}
