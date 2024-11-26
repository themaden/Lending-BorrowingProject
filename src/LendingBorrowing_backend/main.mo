import Debug "mo:base/Debug";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Principal "mo:base/Principal";
import Time "mo:base/Time";

actor LeadingBorrowing {
  type User = {
    balance : Nat;
    borrowed : Nat;
    collateral : Nat;
    lastInterestTime : Time.Time
  };

  let users = HashMap.HashMap<Principal, User>(10, Principal.equal, Principal.hash);
  let interestRate : Nat = 5; // 5% annual interest rate
  let collateralRatio : Nat = 150; // 150% collateral required

  public shared (msg) func deposit(amount : Nat) : async () {
    let caller = msg.caller;
    switch (users.get(caller)) {
      case (null) {
        users.put(caller, {balance = amount; borrowed = 0; collateral = 0; lastInterestTime = Time.now()})
      };
      case (?user) {
        let updatedUser = calculateInterest(user);
        users.put(caller, {balance = updatedUser.balance + amount; borrowed = updatedUser.borrowed; collateral = updatedUser.collateral; lastInterestTime = Time.now()})
      }
    };
    Debug.print("Deposit successful")
  };

  public shared (msg) func borrow(amount : Nat) : async Bool {
    let caller = msg.caller;
    switch (users.get(caller)) {
      case (null) {return false};
      case (?user) {
        let updatedUser = calculateInterest(user);
        if (updatedUser.collateral >= (updatedUser.borrowed + amount) * collateralRatio / 100) {
          users.put(caller, {balance = updatedUser.balance + amount; borrowed = updatedUser.borrowed + amount; collateral = updatedUser.collateral; lastInterestTime = Time.now()});
          return true
        } else {
          return false
        }
      }
    }
  };

  public shared (msg) func repay(amount : Nat) : async Bool {
    let caller = msg.caller;
    switch (users.get(caller)) {
      case (null) {return false};
      case (?user) {
        let updatedUser = calculateInterest(user);
        if (updatedUser.balance >= amount and updatedUser.borrowed >= amount) {
          users.put(caller, {balance = updatedUser.balance - amount; borrowed = updatedUser.borrowed - amount; collateral = updatedUser.collateral; lastInterestTime = Time.now()});
          return true
        } else {
          return false
        }
      }
    }
  };

  public shared (msg) func addCollateral(amount : Nat) : async () {
    let caller = msg.caller;
    switch (users.get(caller)) {
      case (null) {
        users.put(caller, {balance = 0; borrowed = 0; collateral = amount; lastInterestTime = Time.now()})
      };
      case (?user) {
        let updatedUser = calculateInterest(user);
        users.put(caller, {balance = updatedUser.balance; borrowed = updatedUser.borrowed; collateral = updatedUser.collateral + amount; lastInterestTime = Time.now()})
      }
    };
    Debug.print("Collateral added successfully")
  };

  public query func getBalance(user : Principal) : async Nat {
    switch (users.get(user)) {
      case (null) {return 0};
      case (?userInfo) {
        let updatedUser = calculateInterest(userInfo);
        return updatedUser.balance
      }
    }
  };

  public query func getBorrowed(user : Principal) : async Nat {
    switch (users.get(user)) {
      case (null) {return 0};
      case (?userInfo) {
        let updatedUser = calculateInterest(userInfo);
        return updatedUser.borrowed
      }
    }
  };

  public query func getCollateral(user : Principal) : async Nat {
    switch (users.get(user)) {
      case (null) {return 0};
      case (?userInfo) {return userInfo.collateral}
    }
  };

  private func calculateInterest(user : User) : User {
    let timeDiff = (Time.now() - user.lastInterestTime) / 1_000_000_000; // Convert nanoseconds to seconds
    let timeElapsed = Nat64.fromIntWrap(timeDiff); // Convert Time.Time to Nat64
    let interestAmount = (user.borrowed * interestRate * Nat64.toNat(timeElapsed)) / (100 * 365 * 24 * 60 * 60); // Simple interest calculation
    {
      balance = user.balance;
      borrowed = user.borrowed + interestAmount;
      collateral = user.collateral;
      lastInterestTime = Time.now()
    }
  }
}