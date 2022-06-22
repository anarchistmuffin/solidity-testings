// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;


import "./routesRegistry.sol";
import "./RouterOpcodes.sol";

/// @notice
/// trying to implement a  router pattern with anti-forgery and replay protection



contract  Router is RouterOpcodes, RouteRegistry {

    event RouteControllerChanged(address indexed _controllerRouter, address indexed _routeController, opCodeRouteTypes);

    bytes32 private constant routeIdentifier = keccak256("akx.router.v1");
    bytes4 private constant routerMagic = bytes4(routeIdentifier);
    bytes32 public DOMAIN_SEPARATOR;

    string constant NAME = "ROUTER";
    string constant REVISION = "1";

    mapping(opCodeRouteTypes => address) private _mapopcodeToRoute;

  

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

    constructor(address[] memory allowedContractsAddresses)  {
        DOMAIN_SEPARATOR = keccak256(abi.encode(routeIdentifier, routerMagic));
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
    bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash));
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
    bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash));
    address signatory = ecrecover(digest, v, r, s);
    require(signatory != address(0), "INVALID_SIGNATURE");
    require(nonce == _nonces[signatory]++, "INVALID_NONCE");
    require(block.timestamp <= expiry, "INVALID_EXPIRATION");
    // _ROUTE_CONTROLLERByType(signatory, routeController, routeType.VOTING_POWER);
    // _ROUTE_CONTROLLERByType(signatory, routeController, routeType.PROPOSITION_POWER);
  }



}

