// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.8.0;
pragma experimental ABIEncoderV2;
import "./ERC20.sol";

contract Loteria {
    ERC20Basic private token;
    address public ownerBote;
    address public contrato;
    uint private numTokensCreated = 10000;
    event tokensBuyed (uint, address);

    uint public ticketPrice = 5;
    mapping (address => uint []) ticketsByPerson;
    mapping (uint => address) ticketPerson;
    uint randNonce = 0;
    uint[] tickets;
    event buyedTicket(uint, address);
    event winnerTicket(uint);    
    event returnedTokens(uint, address);

    constructor() public {
        token = new ERC20Basic(numTokensCreated);
        ownerBote = msg.sender;
        contrato = address(this);
    }

    function getTokensPrice(uint _numTokens) internal pure returns(uint) {
        return _numTokens * (0.5 ether);
    }

    function addTokens(uint _numTokens) public isOwner(msg.sender) {
        token.increaseTotalSupply(_numTokens);
    }

    function getBalanceContrato() public view returns(uint) {
        return token.balanceOf(contrato);
    }

    function buyTokens(address _propietario, uint _numTokens) public payable {
       uint cost = getTokensPrice(_numTokens);
       require(msg.value >= cost, "Compra menos tokens o paga con mas ethers");
       uint returnValue = msg.value - cost;
       msg.sender.transfer(returnValue);
       require(_numTokens <= getBalanceContrato(), "Compra un numero de tokens adecuado");
       token.transfer(_propietario, _numTokens);
       emit tokensBuyed(_numTokens, _propietario);
    }

    function getBalanceBote() public view returns(uint) {
        return token.balanceOf(ownerBote);
    }

    function getBalanceMisTokens(address _propietario) public view returns (uint) {
        return token.balanceOf(_propietario);
    }
    
    modifier isOwner(address _direccion) {
        require(ownerBote == _direccion, "Usted no tiene permisos para esta funcion");
        _;
    }

    function buyTicket(uint _numTickets) public {
        uint _totalPrice = _numTickets * ticketPrice;
        require(_totalPrice <= getBalanceMisTokens(msg.sender), "Necesitas comprar mas tokens");
        token.transferLoteria(msg.sender, ownerBote, _totalPrice);
        for (uint i = 0; i < _numTickets; i++) {
            uint random = uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % 10000;
            randNonce++;
            ticketsByPerson[msg.sender].push(random);
            tickets.push(random);
            ticketPerson[random] = msg.sender;
            emit buyedTicket(random, msg.sender);
        }        
    }

    function getMisTickets() public view returns(uint [] memory) {
        return ticketsByPerson[msg.sender];
    }

    function generateWinner() public isOwner(msg.sender) {
        require(tickets.length > 0, "No hay boletos comprados");
        uint numTicketsBuyed = tickets.length;
        uint selectedIndexTicket = uint(uint(keccak256(abi.encodePacked(now))) % numTicketsBuyed);
        uint winnerTicketValue = tickets[selectedIndexTicket];
        emit winnerTicket(winnerTicketValue);
        address winnerAddress = ticketPerson[winnerTicketValue];
        token.transferLoteria(msg.sender, winnerAddress, getBalanceBote());
    }

    function returnTokens(uint _numTokens) public payable {
        require(_numTokens > 0, "Necesitas devolver un numero positivo de tokens");
        require(_numTokens <= getBalanceMisTokens(msg.sender), "No tienes los tokens que deseas devolver.");
        token.transferLoteria(msg.sender, contrato, _numTokens);
        msg.sender.transfer(getTokensPrice(_numTokens));
        emit returnedTokens(_numTokens, msg.sender);
    }
}