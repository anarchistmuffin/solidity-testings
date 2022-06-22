// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "@openzeppelin/contracts/utils/Address.sol";

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "./routesRegistry.sol";

/// @notice
/// trying to implement a  router pattern with anti-forgery and replay protection

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


contract  Router is RouterOpcodes, RouteRegistry, ERC20Permit {

    event RouteControllerChanged(address indexed _controllerRouter, address indexed _routeController, opCodeRouteTypes);

    bytes32 private constant routeIdentifier = keccak256("akx.libRouter.router");
    bytes4 private constant routerMagic = bytes4(routeIdentifier);

    string constant NAME = "ROUTER";
    string constant REVISION = "1";

    mapping(opCodeRouteTypes => address) private _mapopcodeToRoute;

    address private _routesRegistry;

    enum opCodeRouteTypes  {
        PUBLIC,
        PROXY,
        PAYMENT,
        ERC20,
        ERC721,
        ERC1155,
        NEED_AUTH,
        ADMIN_ONLY,
        SUPERADMIN_ONLY,
        HOLDER_ONLY,
        SYSTEM,
        BRIDGE,
        POOL,
        EXTERNAL
    }

    mapping(address => bool) private _allowed;
    mapping(bytes1 => bool) private _allowedOpcodes;
    mapping(address => uint) private _nonces;

    constructor(address[] memory allowedContractsAddresses) ERC20(NAME, "AKXROUTER") ERC20Permit(NAME)  {
       _setup(allowedContractsAddresses);
    }

    function _setup(address[] memory allowedContractsAddresses) internal {

        
        for(uint j = 0; j < allowedContractsAddresses.length; j++) {
            _allowed[allowedContractsAddresses[j]] = true;
        }

          for(uint j = 0; j < _routerOpCodes.length; j++) {
            _allowedOpcodes[_routerOpCodes[j]] = true;
        }

    }

    function getRouteFromRegistry() public onlyAllowed {

    }

    function dispatch() internal {

    }

    modifier onlyAllowed() {
        require(_allowed[msg.sender] == true, "ACCESS DENIED");
        _;
    }

 /**
   * @dev delegate route controller one specific power to a routeController
   * @param routeController the contract controller which ROUTE_CONTROLLERd power has changed
   * @param routeType the type of route controller
   **/
  function delegateRouteControllerByType(address routeController, opCodeRouteTypes routeType) external  {
    _delegateRouteControllerByType(msg.sender, routeController, routeType);
  }

   function _delegateRouteControllerByType(
    address controllerRouter,
    address routeController,
    opCodeRouteTypes routeType
  ) internal {
    require(routeController != address(0), "INVALID_ROUTE_CONTROLLER");

   
    mapping(opCodeRouteTypes => address) storage ROUTE_CONTROLLERS = _mapopcodeToRoute;


    ROUTE_CONTROLLERS[routeType] = routeController;

    /// @todo registerController(routeController, routeType);
    emit RouteControllerChanged(controllerRouter, routeController, routeType);
  }



 function _getRouteControllerDispatchByType(opCodeRouteTypes routeType)
    internal
    virtual
    view
    returns (
      address //controllers list
    ) {
        return _mapopcodeToRoute[routeType];
    }
   
 
   /**
   * @dev delegate route controller power from signatory to `routeController`
   * @param routeController The address to ROUTE_CONTROLLER votes to
   * @param routeType the type of delegation (VOTING_POWER, PROPOSITION_POWER)
   * @param nonce The contract state required to match the signature
   * @param expiry The time at which to expire the signature
   * @param v The recovery byte of the signature
   * @param r Half of the ECDSA signature pair
   * @param s Half of the ECDSA signature pair
   */
  function delegateRouteControllerByTypeBySig(
    address routeController,
    opCodeRouteTypes routeType,
    uint256 nonce,
    uint256 expiry,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public {
    bytes32 structHash = keccak256(
      abi.encode(routerMagic, routeController, uint256(routeType), nonce, expiry)
    );
    bytes32 digest = keccak256(abi.encodePacked("\x19\x01", this.DOMAIN_SEPARATOR(), structHash));
    address signatory = ecrecover(digest, v, r, s);
    require(signatory != address(0), "INVALID_SIGNATURE");
    require(nonce == _nonces[signatory]++, "INVALID_NONCE");
    require(block.timestamp <= expiry, "INVALID_EXPIRATION");
    _delegateRouteControllerByType(signatory, routeController, routeType);
  }

  /**
   * @dev delegate route controller power from signatory to `routeController`
   * @param routeController The address to delegate route controller  to
   * @param nonce The contract state required to match the signature
   * @param expiry The time at which to expire the signature
   * @param v The recovery byte of the signature
   * @param r Half of the ECDSA signature pair
   * @param s Half of the ECDSA signature pair
   */
  function delegateRouteControllerBySig(
    address routeController,
    uint256 nonce,
    uint256 expiry,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public {
    bytes32 structHash = keccak256(abi.encode(routeIdentifier, routeController, nonce, expiry));
    bytes32 digest = keccak256(abi.encodePacked("\x19\x01", this.DOMAIN_SEPARATOR(), structHash));
    address signatory = ecrecover(digest, v, r, s);
    require(signatory != address(0), "INVALID_SIGNATURE");
    require(nonce == _nonces[signatory]++, "INVALID_NONCE");
    require(block.timestamp <= expiry, "INVALID_EXPIRATION");
    // _ROUTE_CONTROLLERByType(signatory, routeController, routeType.VOTING_POWER);
    // _ROUTE_CONTROLLERByType(signatory, routeController, routeType.PROPOSITION_POWER);
  }



}

