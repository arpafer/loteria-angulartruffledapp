// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.8.0;
pragma experimental ABIEncoderV2;
import "./SafeMath.sol";

// Juan Gabriel  -->  0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
// Joan Amengual --> 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
// María Santos  --> 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db

// interface de nuestro token ERC20
interface IERC20 {
    // devuelve la cantidad de tokens en existencia
   function totalSupply() external view returns (uint256);
   
   // devuelve la cantidad de tokens para una dirección indicada por parámetro
   function balanceOf(address account) external view returns (uint256);

   // devuelve el número de tokens que el spender podrá gastar en nombre del propietario (owner)
   function allowance(address owner, address spender) external view returns (uint256);

   // devuelve un valor booleano resultado de la operación indicada
   function transfer(address recipient, uint256 amount) external returns(bool);   

   // devuelve un valor booleano resultado de la operación indicada
   function transferLoteria(address emisor, address recipient, uint256 amount) external returns(bool);   

   // Devuelve un valor booleano con el resultado de la operación de gasto
   function approve(address spender, uint256 amount) external returns(bool);

   // Devuelve un valor booleano con el resultado de la operación de paso de una cantidad de tokens usando el método allowance
   function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);

   // evento que se debe emitir cuando una cantidad de tokens pasa de un origen a un destino
   event Transfer(address indexed from, address indexed to, uint256 value);

   // evento que se debe emitir cuando se establece una asignación con el método allowance
   event Approval(address indexed owner, address indexed spender, uint256 value);
}

// Implementación de las funciones del token IERC20
contract ERC20Basic is IERC20 {

   string public constant name = "ERC20BlockchainAZ";
   string public constant symbol = "ERC20A";
   uint8 public constant decimals = 2;   

   //event Transfer(address indexed from, address indexed to, uint256 tokens);   
   // event Approval(address indexed owner, address indexed spender, uint256 tokens);

   using SafeMath for uint256;

   mapping (address => uint) balances;
   mapping (address => mapping(address => uint)) allowed;
   uint256 totalSupply_;

   constructor(uint256 initialSupply) public {
       totalSupply_ = initialSupply;
       balances[msg.sender] = totalSupply_;       
   }
  
   function totalSupply() public override view returns (uint256) {
       return totalSupply_;
   }

   function increaseTotalSupply(uint newTokensAmount) public {      
      totalSupply_ += newTokensAmount;
      balances[msg.sender] += newTokensAmount;
   }

   function balanceOf(address tokenOwner) public override view returns (uint256) {
       return balances[tokenOwner];
   }

   function allowance(address owner, address delegate) public override view returns (uint256) {
       return allowed[owner][delegate];
   }

   function transfer(address recipient, uint256 numTokens) public override returns(bool) {
       require(numTokens <= balances[msg.sender], "No dispone de tokens suficientes");
       balances[msg.sender] = balances[msg.sender].sub(numTokens);
       balances[recipient] = balances[recipient].add(numTokens);
       emit Transfer(msg.sender, recipient, numTokens);
       return true;
   }

   function transferLoteria(address emisor, address recipient, uint256 numTokens) public override returns(bool) {
       require(numTokens <= balances[emisor], "No dispone de tokens suficientes");
       balances[emisor] = balances[emisor].sub(numTokens);
       balances[recipient] = balances[recipient].add(numTokens);
       emit Transfer(emisor, recipient, numTokens);
       return true;
   }

   function approve(address delegate, uint256 numTokens) public override returns(bool) {
       require(numTokens <= balances[msg.sender], "No dispone de suficientes tokens para este traspaso");
       allowed[msg.sender][delegate] = numTokens;
       emit Approval(msg.sender, delegate, numTokens);
       return true;
   }

   function transferFrom(address owner, address buyer, uint256 numTokens) public override returns(bool) {
       require(numTokens <= balances[owner], "El owner no tiene tokens suficientes");
       require(numTokens <= allowed[owner][msg.sender], "No tiene ese numero de tokens delegados");  
       balances[owner] = balances[owner].sub(numTokens);
       allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
       balances[buyer] = balances[buyer].add(numTokens);
       emit Transfer(owner, buyer, numTokens);
       return false;
   }
}