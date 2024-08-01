// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.6.12;

import { FiatTokenV2_2 } from "./../v2/FiatTokenV2_2.sol";

contract FiatTokenV3 is FiatTokenV2_2 {
    address private _trustedForwarder;
    address public erc2771ContextAddress;

    constructor() public {
        // Deploy ERC2771Context from bytecode


            bytes memory bytecode
         = hex"60a060405234801561000f575f80fd5b50604051610312380380610312833981810160405281019061003191906100cb565b808073ffffffffffffffffffffffffffffffffffffffff1660808173ffffffffffffffffffffffffffffffffffffffff168152505050506100f6565b5f80fd5b5f73ffffffffffffffffffffffffffffffffffffffff82169050919050565b5f61009a82610071565b9050919050565b6100aa81610090565b81146100b4575f80fd5b50565b5f815190506100c5816100a1565b92915050565b5f602082840312156100e0576100df61006d565b5b5f6100ed848285016100b7565b91505092915050565b60805161020561010d5f395f60c701526102055ff3fe608060405234801561000f575f80fd5b5060043610610034575f3560e01c8063572b6c05146100385780637da0a87714610068575b5f80fd5b610052600480360381019061004d9190610149565b610086565b60405161005f919061018e565b60405180910390f35b6100706100c4565b60405161007d91906101b6565b60405180910390f35b5f61008f6100c4565b73ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff16149050919050565b5f7f0000000000000000000000000000000000000000000000000000000000000000905090565b5f80fd5b5f73ffffffffffffffffffffffffffffffffffffffff82169050919050565b5f610118826100ef565b9050919050565b6101288161010e565b8114610132575f80fd5b50565b5f813590506101438161011f565b92915050565b5f6020828403121561015e5761015d6100eb565b5b5f61016b84828501610135565b91505092915050565b5f8115159050919050565b61018881610174565b82525050565b5f6020820190506101a15f83018461017f565b92915050565b6101b08161010e565b82525050565b5f6020820190506101c95f8301846101a7565b9291505056fea2646970667358221220917dd927ce880a25ab75b4c35a669bde072daa60203613039556668f21e2aa3864736f6c634300081a0033";
        address forwarder = address(0xA4eD26EE4e441a41a5246d35a7f6DDA379fAFd04);

        address addr;
        assembly {
            addr := create(0, add(bytecode, 0x20), mload(bytecode))
            if iszero(extcodesize(addr)) {
                revert(0, 0)
            }
        }

        _trustedForwarder = forwarder;
        erc2771ContextAddress = addr;
    }

    function isTrustedForwarder(address forwarder) public view returns (bool) {
        return forwarder == _trustedForwarder;
    }

    function _msgSender() internal view returns (address sender) {
        if (isTrustedForwarder(msg.sender)) {
            assembly {
                sender := shr(96, calldataload(sub(calldatasize(), 20)))
            }
        } else {
            return msg.sender;
        }
    }

    function _msgData() internal view returns (bytes calldata) {
        if (isTrustedForwarder(msg.sender)) {
            return msg.data[:msg.data.length - 20];
        } else {
            return msg.data;
        }
    }
}
