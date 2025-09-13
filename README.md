# 👶 Child Sponsorship NFT Smart Contract 🌟

## 🌍 Overview

A transparent blockchain-based child sponsorship platform that uses NFTs to represent sponsored children and provide accountability for donations. Each child is represented as an NFT with verifiable progress updates from authorized NGOs.

## ✨ Features

- 🎭 **NFT-Based Child Representation**: Each child is minted as a unique NFT
- 💰 **Recurring Sponsorship Payments**: Automated monthly contribution tracking
- 📊 **Progress Updates**: On-chain verified updates from NGOs
- 🔒 **Authorization System**: Only verified NGOs can create child profiles
- 👥 **Multi-Child Sponsorship**: Sponsors can support multiple children
- 📈 **Transparency**: All transactions and updates are publicly verifiable

## 🏗️ Contract Structure

### Core Components

- **NFT Token**: `child-sponsorship` - Represents each sponsored child
- **Child Profiles**: Store child information and NGO associations
- **Sponsorships**: Track sponsor commitments and payment history
- **Progress Updates**: Verifiable milestone tracking with hashes
- **NGO Authorization**: Whitelist system for trusted organizations

### Key Functions

#### 🔧 Admin Functions
- `register-ngo`: Authorize NGOs to create child profiles
- `set-monthly-amount`: Update the standard monthly sponsorship amount

#### 👶 Child Management
- `create-child-profile`: NGOs create profiles for children needing sponsorship
- `sponsor-child`: Sponsors commit to supporting a specific child
- `end-sponsorship`: Sponsors can terminate their commitment

#### 💳 Payment Functions
- `make-monthly-payment`: Process recurring monthly contributions
- `calculate-payment-due`: Check if payments are due

#### 📋 Progress Tracking
- `add-progress-update`: NGOs add verified updates about child progress
- `get-progress-update`: Retrieve specific updates
- `get-update-count`: Get total number of updates for a child

#### 📖 Read-Only Functions
- `get-child-profile`: View child information
- `get-sponsorship-info`: Check sponsorship details
- `get-sponsor-children`: List all children sponsored by an address
- `is-ngo-authorized`: Verify NGO authorization status
- `get-nft-owner`: Check NFT ownership
- `get-total-children`: Get total number of children in the system

## 🚀 Usage Instructions

### 1. Deploy the Contract
```bash
clarinet deploy
```

### 2. Register an NGO (Contract Owner Only)
```clarity
(contract-call? .Child-Sponsorship-NFT--- register-ngo 'SP1ABC...)
```

### 3. Create a Child Profile (NGO)
```clarity
(contract-call? .Child-Sponsorship-NFT--- create-child-profile 
  "Maria Santos" 
  u8 
  "São Paulo, Brazil" 
  "Education, healthcare, nutrition")
```

### 4. Sponsor a Child
```clarity
(contract-call? .Child-Sponsorship-NFT--- sponsor-child u1)
```

### 5. Make Monthly Payments
```clarity
(contract-call? .Child-Sponsorship-NFT--- make-monthly-payment u1)
```

### 6. Add Progress Updates (NGO)
```clarity
(contract-call? .Child-Sponsorship-NFT--- add-progress-update 
  u1 
  "School Grade Update" 
  "Maria has successfully completed grade 2 with excellent marks" 
  "education" 
  0x1234567890abcdef...)
```

## 💰 Financial Flow

1. **Initial Sponsorship**: Sponsor pays first month (default: 1 STX)
2. **Monthly Payments**: Recurring payments directly to NGO
3. **Transparency**: All payments tracked on-chain
4. **Verification**: NGO provides regular updates with cryptographic hashes

## 🔐 Security Features

- **Authorization Checks**: Only authorized NGOs can create profiles and updates
- **Ownership Validation**: NFT ownership determines sponsorship rights
- **Payment Verification**: Automated payment tracking and validation
- **Update Integrity**: Cryptographic hashes ensure update authenticity

## 📊 Data Structures

### Child Profile
```clarity
{
  name: (string-ascii 50),
  age: uint,
  location: (string-ascii 100),
  needs: (string-ascii 200),
  ngo-address: principal,
  is-active: bool,
  created-at: uint
}
```

### Sponsorship Info
```clarity
{
  sponsor: principal,
  start-block: uint,
  last-payment-block: uint,
  total-contributed: uint,
  is-active: bool
}
```

### Progress Update
```clarity
{
  title: (string-ascii 100),
  description: (string-ascii 500),
  category: (string-ascii 20),
  updated-by: principal,
  timestamp: uint,
  verification-hash: (buff 32)
}
```

## 🧪 Testing

Run the test suite:
```bash
npm install
npm test
```

## 🌟 Impact

- **Transparency**: Donors can track exactly how their contributions are used
- **Accountability**: NGOs must provide regular, verifiable updates
- **Trust**: Blockchain-based verification builds long-term donor confidence
- **Sustainability**: Recurring payment model ensures sustained support

## 📝 Error Codes

- `u100`: Not contract owner
- `u101`: Not authorized (NGO)
- `u102`: NFT not found
- `u103`: Child already sponsored
- `u104`: Insufficient payment
- `u105`: Invalid child ID
- `u106`: Update not found
- `u107`: Sponsorship ended

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📜 License

MIT License - see LICENSE file for details

## 🙏 Acknowledgments

- Built on Stacks blockchain for transparency and security
- Designed to support global child welfare organizations
- Inspired by the need for accountable charitable giving

---

💝 **Together, we can make a transparent difference in children's lives worldwide!** 🌍

# Child Sponsorship NFT   

