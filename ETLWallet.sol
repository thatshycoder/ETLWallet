// SPDX-License-Identifier: MIT

// Basic wallet for eductional purposes

pragma solidity >=0.7.0 <0.9.0;

contract ETLWallet {

    // address of contract creator
    address minter;

    // address of active wallet
    address activeWallet;

    // a struct fpr saving wallets information
    struct Wallet {
        uint id;
        address walletAddress;
    }

    // an array for storing registered wallets 
    Wallet[] wallets;


    // a struct for saving accounts information
    struct Account {
        address user;
        bytes32 accountAddress;
        uint balance;
    }

    // an array for storing accounts
    Account[] public accounts;

    mapping(bytes32 => Account) userAccounts;

    // store a new wallet
    function createWallet() internal {

        uint id = 0;
        id++;
        wallets.push(Wallet(id, msg.sender));
        activateWallet();
    }

    function activateWallet() internal {
        activeWallet = msg.sender;
    }

    // generate a random fake account
    function registerAccount() public {
        
        // register a new wallet if non is active
        if(activeWallet == address(0) ) {
            createWallet();
        }

        if(walletExists(activeWallet)) {

            bytes32 newAccount = keccak256(abi.encodePacked(msg.sender, block.timestamp));
            accounts.push(Account(activeWallet, newAccount, 0));
            userAccounts[newAccount] = Account(activeWallet, newAccount, 0);
        }
    }

    // verify if wallet is registered
    function walletExists(address _wallet) internal view returns(bool success) {
        success = false;

        if(wallets.length != 0) {

            for(uint i = 0; i < wallets.length; i++) {

                if(wallets[i].walletAddress == _wallet) {
                    success = true;
                }
            }
        }
    }

    // get account balance
    function getBalance(bytes32 _account) public view returns(uint) {
        return userAccounts[_account].balance;
    }

    // send token between accounts
    function send(bytes32 _from, bytes32 _to, uint _amount) public returns(bool success) {
        success = false;

        // ensure accounts are valid, and account sending funds is authorized
        // and ensure you're not sending to the same account
        if(accountExists(_from) && accountExists(_to) && _from != _to && accountOwner(_from) == activeWallet ) {

            if(hasSufficientBalance(_from, _amount)) {

                deductFromAccount(_from, _amount);
                creditAccount(_to, _amount);

                success = true;
            }
        }
    }
 
    // increment account balance
    function creditAccount(bytes32 _account, uint _amount) internal {

        if(accountExists(_account)) {
            userAccounts[_account].balance += _amount;
        }
    }

    // deduct from account balance
    function deductFromAccount(bytes32 _account, uint _amount) internal {
        
        if(accountExists(_account)) {
            userAccounts[_account].balance -= _amount;
        }
    }

    // ensure an account has sufficient funds to send
    function hasSufficientBalance(bytes32 _account, uint _amount) internal view returns(bool success) {
        success = true;

       if(accountExists(_account)) {

           if(userAccounts[_account].balance < _amount) {
               success = false;
           }
        }  
    }

    // get wallet owner of an account
    function accountOwner(bytes32 _account) internal view returns(address owner) {
        
        for(uint i = 0; i < accounts.length; i++) {

            if(accounts[i].accountAddress == _account) {
                return accounts[i].user;
            }
        }
    }

    // check if wallet account exists
    function accountExists(bytes32 _account) internal view returns(bool success) {
        success = false;

        for(uint i = 0; i < accounts.length; i++) {

            if(accounts[i].accountAddress == _account) {
                success = true;
            }
        }
    }

    // credit any wallet account with some funds
    // restrict priviledge to contract creator
    function fundAccount(bytes32 _account, uint _amount) public payable {
        require(msg.sender == minter);
        
         if(accountExists(_account)) {
             creditAccount(_account, _amount);
        }  
    }

    constructor() {
        minter = msg.sender;
    }
}