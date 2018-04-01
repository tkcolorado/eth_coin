pragma solidity ^0.4.16;

import "./SafeMath.sol";

contract WZC {
    
     using SafeMath for uint256;  //uint256変数にはSafeMathを適用する。
     
    //ネットワーク上にリリースするトークン名とティッカー
     string public constant symbol = "WZC";
     string public constant name = "Woz Coin";
     
     //総供給量と対ethレートの定義
     uint256 _totalSupply = 1000000; //1000 x 1000 (小数点以下分を含む)
     uint256 _currentSupply = 0;
     uint256 public constant RATE = 20; //20wzc = 1eth
     uint256 public constant decimals = 3;
     address public owner;
  
     // オーナーとユーザーの関係を定義してマッピング
     mapping(address => uint256) balances;
     mapping(address => mapping (address => uint256)) allowed;  //流通のため、オーナーから払い出したトークンの取り扱いをユーザーに許可する。
     modifier onlyOwner() {
         require(msg.sender != owner);
         _;
     }
     
     modifier onlyPayloadSize(uint256 size){
         assert(msg.data.length >= size + 4);
         _;
     }
     
     //トークンのフォールバック関数    
     function() public payable{  
         createTokens(msg.sender);
     }
  
     // 以下動作部分となるコンストラクター
     function WZC() public {
         owner = msg.sender;
         balances[owner] = _totalSupply;
     }
  
    //ethとwzcの交換処理
    function createTokens(address addr) public payable{
        require(msg.value > 0); 
        uint256 tokens = msg.value.mul(RATE).mul(1000).div(1 ether);
        require(_currentSupply.add(tokens) <= _totalSupply); 
        balances[owner] = balances[owner].sub(tokens);
        balances[addr] = balances[addr].add(tokens);
        Transfer(owner, addr, tokens);

        owner.transfer(msg.value);
        _currentSupply = _currentSupply.add(tokens);
    }
    //交換処理後にオーナーのトークン総数をリフレッシュ
    function totalSupply() public constant returns (uint256 totalSupply2) {
         return _totalSupply;
     }
  
     //アカウントにあるトークン数の表示
     function balanceOf(address _owner) public constant returns (uint256 balance) {
         return balances[_owner];
     }
  
     // 交換したwzcの送付
     function transfer(address _to, uint256 _value) public returns (bool success) {
         require(
             balances[msg.sender] >= _value 
             && _value > 0
             ); 
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
     }
     // wzc獲得後の流通のための関数
     function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
         require(
             balances[_from] >= _value
             && allowed[_from][msg.sender] >= _value
             && _value > 0
        );
             balances[_from] = balances[_from].sub(_value);
             allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
             balances[_to] = balances[_to].add(_value);
             Transfer(_from, _to, _value);
             return true;
    }
  
     // 発行元から入手した保有者に流通権限を与える（それ以外の流通を許可しない安全策）
     function approve(address _spender, uint256 _value) public returns (bool success) {
         allowed[msg.sender][_spender] = _value;
         Approval(msg.sender, _spender, _value);
      return true;
     }
  
     function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
         return allowed[_owner][_spender];
     }
 
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}
