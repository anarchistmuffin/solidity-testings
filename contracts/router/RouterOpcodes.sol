// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

abstract contract RouterOpcodes {

    bytes1 public constant ROUTE_TYPE_PROXY = 0x70;
    bytes1 public constant ROUTE_TYPE_PAYMENT = 0x24;
    bytes1 public constant ROUTE_TYPE_TOKEN = 0x11;
    bytes1 public constant ROUTE_TYPE_TOKEN_ERC20 = 0x12;
    bytes1 public constant ROUTE_TYPE_TOKEN_ERC721 = 0x13;
    bytes1 public constant ROUTE_TYPE_TOKEN_ERC1155 = 0x14;
    bytes1 public constant ROUTE_TYPE_EXT_CONTRACT = 0x21;

    bytes1 public constant ROUTE_TYPE_NEED_AUTH = 0x31;
    bytes1 public constant ROUTE_TYPE_PUBLIC = 0x32;
    bytes1 public constant ROUTE_TYPE_POOL = 0x33;
    bytes1 public constant ROUTE_TYPE_ADDRESS = 0x34;
    bytes1 public constant ROUTE_TYPE_ADDRESS_WALLET = 0x35;
    bytes1 public constant ROUTE_TYPE_SYSTEM = 0x99;

    bytes1 public constant ROUTE_TYPE_SUPERADMIN = 0x98;
    bytes1 public constant ROUTE_TYPE_ADMIN = 0x97;
    bytes1 public constant ROUTE_TYPE_BRIDGE = 0x88;

    bytes1[] _routerOpCodes = [ROUTE_TYPE_PROXY, ROUTE_TYPE_ADMIN, ROUTE_TYPE_BRIDGE, ROUTE_TYPE_PAYMENT, ROUTE_TYPE_TOKEN,
    ROUTE_TYPE_TOKEN_ERC20, ROUTE_TYPE_TOKEN_ERC721, ROUTE_TYPE_TOKEN_ERC1155, ROUTE_TYPE_EXT_CONTRACT, ROUTE_TYPE_NEED_AUTH,
    ROUTE_TYPE_PUBLIC, ROUTE_TYPE_POOL,ROUTE_TYPE_ADDRESS, ROUTE_TYPE_ADDRESS_WALLET, ROUTE_TYPE_SYSTEM, ROUTE_TYPE_SUPERADMIN, ROUTE_TYPE_BRIDGE];




    }
