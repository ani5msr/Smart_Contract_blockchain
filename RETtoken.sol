// SPDX-License-Identifier: GPL-3.0
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

abstract contract RETStandard {
function name() virtual public view returns (string memory);
function symbol() virtual public view returns (string memory);
function decimals() virtual public view returns (uint);
function balanceOf(address _owner) virtual public view returns (uint balance);
function balanceOfCoin(address _owner) virtual public view returns (uint balance);
event Transfer(address indexed _from, address indexed _to, uint _value);
event Approval(address indexed _owner, address indexed _spender, uint _value);

}

// this contract allows one to accept the transfer of adminship for a token.
contract Owned {
    address public admin;
    address public newAdmin;
    event adminTransferred(address indexed _from, address indexed _to);
    
    constructor() {
        admin = msg.sender;
    }
    
    function adminTransfer(address _to) public {
        require(admin == msg.sender);
        newAdmin = _to;
    }
    
    function acceptAdminship() public {
        require(msg.sender == newAdmin);
        emit adminTransferred(admin, newAdmin);
        admin = newAdmin;
        newAdmin = address(0);
    }
}

// inhereting
contract RoyalToken is RETStandard {
    string public _symbol;
    string public _name;
    uint public _gasprice;
    uint public _entrytokenfee;
    uint public _decimals;
    mapping(address => uint) balances;
    mapping(address => uint) coinbalances;
    constructor() {
        _symbol = 'RET';
        _name = "Royal Entry Token";
        _decimals = 18;
        _gasprice = 30000;
        _entrytokenfee = 70;
    }
    
    function name() public override view returns (string memory) {
        return _name;
    }
    function symbol() public override view returns (string memory) {
        return _symbol;
    }
    function decimals() public override view returns (uint) {
        return _decimals;
    }
    
    function balanceOf(address _owner) public override view returns (uint256 balance) {
        return balances[_owner];
    }
    function balanceOfCoin( address _owner) public override view returns (uint256 balance){
        return coinbalances[_owner];
    }
    // this function is used to buy the coins using balance money
    function buytokens(address _from, uint _number) virtual public  returns (bool success){
        require(balances[_from] >= _entrytokenfee*_number);
        balances[_from] -= _number * _entrytokenfee;
        coinbalances[_from] += _number;
        return true;
    }
    // this function is used to sell the coins and recover the money used to buy them initially
    function selltokens( address _from, address _to, uint _number) virtual public returns (bool success){
        require(coinbalances[_from] >= _number);
        coinbalances[_from] -= _number;
        coinbalances[_to] += _number;
        balances[_from] += _number * _entrytokenfee;
        balances[_to] -= _number * _entrytokenfee;
        return true;
    }
    // this function allows the customer to buy coffee using the coins he has purchased stored in his coinbalances
    function buycoffee( address _from, address _to, uint _value) virtual public returns (bool success){
        require(coinbalances[_from] >= _gasprice*_value); // checks if the gasprice ( prices per computation of one step) is multiplied by the number to be purchased is less than the coin balance
        coinbalances[_from] -= _gasprice*_value;
        coinbalances[_to] += _gasprice*_value;
        emit Transfer(_from, _to, _value);
        return true;
    }
    
}