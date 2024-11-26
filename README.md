# LeadingBorrowing

LeadingBorrowing is a decentralized lending and borrowing platform implemented as an Internet Computer canister (smart contract). It allows users to deposit funds, borrow against collateral, repay loans, and manage their collateral.

## Features

- Deposit funds
- Borrow against collateral
- Repay loans
- Add collateral
- View balance, borrowed amount, and collateral
- Automatic interest calculation

## Key Components

- User Management: Stores user information including balance, borrowed amount, collateral, and last interest calculation time.
- Interest Calculation: Automatically calculates and applies interest on borrowed amounts.
- Collateral Ratio: Ensures loans are over-collateralized for platform security.

## Functions

### Public Functions

1. `deposit(amount: Nat)`: Deposit funds into the user's account.
2. `borrow(amount: Nat)`: Borrow funds if sufficient collateral is available.
3. `repay(amount: Nat)`: Repay borrowed funds.
4. `addCollateral(amount: Nat)`: Add collateral to the user's account.
5. `getBalance(user: Principal)`: Get the current balance of a user.
6. `getBorrowed(user: Principal)`: Get the amount borrowed by a user.
7. `getCollateral(user: Principal)`: Get the collateral amount of a user.

### Private Functions

1. `calculateInterest(user: User)`: Calculate and apply interest on borrowed amounts.

## Configuration

- Interest Rate: 5% annual interest rate
- Collateral Ratio: 150% (users must provide 1.5x collateral for the borrowed amount)

## Usage

To interact with the LeadingBorrowing canister, you can use the Candid interface or call the functions directly from another canister or application.

Example usage:

1. Deposit funds:
   ```motoko
   await LeadingBorrowing.deposit(100);


