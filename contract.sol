pragma solidity ^0.4.20;
contract PropertyTransfer {

    address public DA;
    uint public totalNoOfProperty;

    constructor() public {
        DA = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender == DA);
        _;
    }

    struct Property{
        uint flour;
        string location;
        string name;
        bool isSold;
        uint price;
        string ownerName;
    }

    // Mapping declare
    mapping(address => mapping(uint256=>Property)) public  propertiesOwner;
    mapping(address => uint256) public individualCountOfPropertyPerOwner;

    // Event declare
    event PropertyAlloted(address indexed _verifiedOwner, uint256 indexed  _totalNoOfPropertyCurrently, string _nameOfProperty, string _msg);
    event PropertyTransferred(address indexed _from, address indexed _to, string _propertyName, string _msg);
    event PropertySetPrice(string _propertyName, string _msg);


    // Get the count property by owner
    function getPropertyCountOfAnyAddress(address _ownerAddress) constant  public returns (uint256){
        uint count=0;
        for(uint i =0; i<individualCountOfPropertyPerOwner[_ownerAddress];i++){
            if(propertiesOwner[_ownerAddress][i].isSold != true)
            count++;
        }

        return count;
    }


    // Set the property to its owner
    function allotProperty(address _verifiedOwner, uint _propertyLocationFlour,
    string _propertyLocation, string _propertyName, uint _propertyPrice, string _ownerName)
    onlyOwner public
    {
        propertiesOwner[_verifiedOwner][individualCountOfPropertyPerOwner[_verifiedOwner]++] = Property(_propertyLocationFlour, _propertyLocation, _propertyName, false, _propertyPrice, _ownerName);
        totalNoOfProperty++;
        emit PropertyAlloted(_verifiedOwner,individualCountOfPropertyPerOwner[_verifiedOwner], _propertyName, "Property allotted successfully");
    }


    // Verif the owner of property
    function isOwner(address _checkOwnerAddress, string _propertyName) constant public returns (uint){
        uint i ;
        bool flag ;
        for(i=0 ; i<individualCountOfPropertyPerOwner[_checkOwnerAddress]; i++){
            if(propertiesOwner[_checkOwnerAddress][i].isSold == true){
                break;
            }
         flag = stringsEqual(propertiesOwner[_checkOwnerAddress][i].name,_propertyName);
            if(flag == true){
                break;
            }
        }
        if(flag == true){
            return i;
        }
        else {
            return 999999999;
        }

    }

    // Verif the equality of two string
    function stringsEqual (string a1, string a2) constant public returns (bool) {
            return keccak256(a1) == keccak256(a2)? true:false;
    }

    // Transfert the property
    function transferProperty (address _to, string _propertyName) public
      returns (bool ,  uint )
    {
        uint256 checkOwner = isOwner(msg.sender, _propertyName);
        bool flag;

        if(checkOwner != 999999999 && propertiesOwner[msg.sender][checkOwner].isSold == false){
            propertiesOwner[msg.sender][checkOwner].isSold = true;
            propertiesOwner[msg.sender][checkOwner].name = "Sold";
            propertiesOwner[_to][individualCountOfPropertyPerOwner[_to]++].name = _propertyName;
            flag = true;
            emit PropertyTransferred(msg.sender , _to, _propertyName, "Owner has been changed." );
        }
        else {
            flag = false;
            emit PropertyTransferred(msg.sender , _to, _propertyName, "Owner doesn't own the property." );
        }
        return (flag, checkOwner);
    }

    // Update the property price
    function setPropertyCost(uint _price, string _propertyName) public{

        require(msg.sender != DA);
        uint256 checkOwner = isOwner(msg.sender, _propertyName);

        if(checkOwner != 999999999 && propertiesOwner[msg.sender][checkOwner].isSold == false){
        propertiesOwner[msg.sender][checkOwner].price = _price;
        emit PropertySetPrice(_propertyName, "Price update successfully" );
        }else{
            emit PropertySetPrice(_propertyName, "You can't update the price, you are not the owner" );
        }
    }



    // Function to kill the contract
   function kill() onlyOwner public  {
      selfdestruct(DA);
   }



}