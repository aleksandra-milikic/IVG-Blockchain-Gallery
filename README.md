# IVG Virtual Gallery – Smart Contract for a Virtual Art Gallery

This repository contains the Solidity smart contract `IVGGallery`, which implements the core functionality of a virtual art gallery for managing artwork submissions, curator reviews, publication, and user interactions.

The contract enables:
- Artwork creation and submission.
- Artwork validation and review by a curator.
- Publication of approved artworks.
- Recording and tracking of user interactions.

## Technical Details

- **File:** `IVGGallery.sol`
- **License:** MIT
- **Solidity Compiler Version:** `^0.8.20`
- **Contract:** `IVGGallery`

Contract header:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract IVGGallery {
    ...
}
```

## Functionality Overview

The contract implements an on-chain system for managing artworks in a virtual gallery:

- Artists submit artworks to the system.
- The curator reviews submitted artworks and updates their status.
- Approved artworks can be published in the gallery.
- Users can record interactions with artworks, such as views or likes.
- Artwork records and interaction data are stored on the blockchain.

## State Variables

```solidity
address public curator;                  // Address of the curator (contract deployer)

uint public artworkCounter;             // Total number of submitted artworks
uint public interactionCounter;         // Total number of recorded interactions

mapping(uint => Artwork) public artworks;          // Stores artwork records
mapping(uint => Interaction) public interactions; // Stores interaction records
```

- `curator` stores the address of the account that deployed the contract.
- `artworkCounter` tracks the total number of submitted artworks.
- `interactionCounter` tracks the total number of recorded interactions.
- `artworks` maps artwork IDs to their corresponding artwork records.
- `interactions` maps interaction IDs to their corresponding interaction records.

## Enum – Artwork Status

The `ArtworkStatus` enum defines the possible states of an artwork:

```solidity
enum ArtworkStatus {
    Submitted,
    UnderReview,
    NeedsRevision,
    Rejected,
    Approved,
    Published
}
```

Each status corresponds to a numeric value:

| Value | Status | Description |
|---|---|---|
| `0` | `Submitted` | Artwork has been submitted. |
| `1` | `UnderReview` | Artwork is under review. |
| `2` | `NeedsRevision` | Artwork requires modifications. |
| `3` | `Rejected` | Artwork has been rejected. |
| `4` | `Approved` | Artwork has been approved for publication. |
| `5` | `Published` | Artwork has been published in the gallery. |

These numeric values are particularly useful when interacting with the contract through Remix IDE.

## Structs

### Artwork

The `Artwork` struct stores information about each submitted artwork:

```solidity
struct Artwork {
    uint id;
    address artist;
    string title;
    string description;
    string[] tags;
    ArtworkStatus status;
}
```

It contains:
- `id` – unique artwork identifier.
- `artist` – address of the artist who submitted the artwork.
- `title` – artwork title.
- `description` – artwork description.
- `tags` – array containing artwork tags.
- `status` – current artwork status.

### Interaction

The `Interaction` struct stores information about user interactions:

```solidity
struct Interaction {
    uint artworkId;
    address user;
    string action;
    uint timestamp;
}
```

It contains:
- `artworkId` – ID of the artwork related to the interaction.
- `user` – address of the user who recorded the interaction.
- `action` – interaction type, such as `"view"` or `"like"`.
- `timestamp` – time at which the interaction was recorded.

## Events

Events provide information about important contract operations and can be monitored by external applications.

```solidity
event ArtworkSubmitted(uint id, address artist);
event ArtworkReviewed(uint id, ArtworkStatus status);
event ArtworkPublished(uint id);
event InteractionRecorded(uint artworkId, address user, string action);
```

The contract emits an event when:
- A new artwork is submitted.
- The curator updates an artwork's status.
- An approved artwork is published.
- A user interaction is recorded.

## Custom Errors

The contract uses custom errors to handle invalid operations and access restrictions.

```solidity
error OnlyCurator();
error ArtworkNotFound();
error InvalidState();
error NotApproved();
error AlreadyPublished();
```

These errors provide specific failure reasons instead of using descriptive `require` messages. Custom errors can also reduce gas costs compared with longer revert strings.

- `OnlyCurator()` – the caller is not the curator.
- `ArtworkNotFound()` – the specified artwork does not exist.
- `InvalidState()` – the requested status change is not allowed.
- `NotApproved()` – the artwork has not been approved for publication.
- `AlreadyPublished()` – defined as a custom error for an already published artwork.

## Constructor

The constructor assigns the curator role to the address that deploys the contract.

```solidity
constructor() {
    curator = msg.sender;
}
```

The contract deployer is therefore the only account authorized to review and publish artworks.

## Functions

### 1. `submitArtwork()`

This function allows any user to submit a new artwork.

```solidity
function submitArtwork(
    string memory _title,
    string memory _description,
    string memory _tags
) public
```

**Logic:**
- Increments the artwork counter.
- Creates and stores a new artwork in the `artworks` mapping.
- Assigns the caller's address as the artist.
- Stores the submitted tag string as a single element in the artwork's `tags` array.
- Sets the initial status to `Submitted`.
- Emits the `ArtworkSubmitted` event.

### 2. `reviewArtwork()`

This function allows the curator to review an existing artwork and update its status.

```solidity
function reviewArtwork(
    uint _id,
    ArtworkStatus _newStatus
) public
```

**Logic:**
- Checks whether the caller is the curator.
- Checks whether the specified artwork exists.
- Prevents changes to an artwork that has already been published.
- Prevents setting the status directly to `Published`.
- Updates the artwork's status to the selected value.
- Emits the `ArtworkReviewed` event.

The curator can assign statuses such as `Submitted`, `UnderReview`, `NeedsRevision`, `Rejected`, or `Approved`.

### 3. `publishArtwork()`

This function allows the curator to publish an approved artwork.

```solidity
function publishArtwork(uint _id) public
```

**Logic:**
- Checks whether the caller is the curator.
- Checks whether the specified artwork exists.
- Verifies that the artwork has the `Approved` status.
- Changes its status to `Published`.
- Emits the `ArtworkPublished` event.

An artwork must be approved before it can be published.

### 4. `addInteraction()`

This function allows any user to record an interaction with an existing artwork.

```solidity
function addInteraction(
    uint _artworkId,
    string memory _action
) public
```

**Logic:**
- Checks whether the specified artwork exists.
- Increments the interaction counter.
- Stores the interaction in the `interactions` mapping.
- Records the artwork ID, user's address, action, and timestamp.
- Emits the `InteractionRecorded` event.

Example interaction actions include `"like"` and `"view"`.

## Note on the Recommendation System

The smart contract does not directly implement a recommendation system on the blockchain.

Instead:
- User interactions are stored on-chain.
- External systems can use contract events and interaction records for analysis.
- Recommendations can be generated off-chain based on this data.

The recommendation functionality itself is not implemented in this repository.

# How to Deploy the Contract Using Remix IDE

1. Open [Remix IDE](https://remix.ethereum.org/).
2. Create a new file named `IVGGallery.sol`.
3. Paste the complete Solidity contract code into the file.
4. Open the **Solidity Compiler** tab:
   - Select compiler version `0.8.20` (or another compatible `0.8.x` version).
   - Click **Compile IVGGallery.sol**.
5. Open the **Deploy & Run Transactions** tab:
   - Set **Environment** to `Remix VM`.
   - Click **Deploy**.
6. After deployment, the contract functions will become available for interaction:
   - `submitArtwork`
   - `reviewArtwork`
   - `publishArtwork`
   - `addInteraction`

# Testing the Contract

The following examples demonstrate how to test the main contract functionalities using Remix IDE.

## 1. Submitting an Artwork

1. Select the first account in Remix (artist).
2. Call the `submitArtwork()` function.
3. Enter the following parameters:
   - `_title` → e.g. `"The Kiss"`
   - `_description` → e.g. `"Famous painting by Gustav Klimt, part of the Austrian Symbolist movement"`
   - `_tags` → e.g. `"symbolism,art-nouveau,classic-art"`
4. Click **transact**.

**Verification:**

Check the following public variables:
- `artworkCounter`
- `artworks(1)`

After successful execution, the following event is emitted:

```solidity
ArtworkSubmitted
```

**Note:** The `_tags` parameter is a single string. Although the artwork struct stores tags as a string array, this function currently stores the submitted string as one array element.

## 2. Reviewing an Artwork

1. Select the account that deployed the contract (curator).
2. Call the `reviewArtwork()` function.
3. Enter:
   - `_id` → `1`
   - `_newStatus` → the desired status value:

| Value | Status |
|---|---|
| `0` | Submitted |
| `1` | UnderReview |
| `2` | NeedsRevision |
| `3` | Rejected |
| `4` | Approved |

4. Click **transact**.

**Verification:**

- Check the updated status in `artworks(1)`.

After successful execution, the following event is emitted:

```solidity
ArtworkReviewed
```

**Note:** The curator can select any of the allowed statuses above. The contract does not enforce a strict sequence of review stages.

## 3. Publishing an Artwork

1. Make sure the artwork has previously been assigned the `Approved` status.
2. Call the `publishArtwork()` function.
3. Enter:
   - `_id` → `1`
4. Click **transact**.

**Condition:**

- The artwork must have the `Approved` status before publication.
- Only the curator can publish an artwork.

**Verification:**

- Check that the status of `artworks(1)` has changed to `Published` (`5`).

After successful execution, the following event is emitted:

```solidity
ArtworkPublished
```

## 4. Recording a User Interaction

1. Switch to another account in Remix (regular user).
2. Call the `addInteraction()` function.
3. Enter:
   - `_artworkId` → `1`
   - `_action` → e.g. `"like"` or `"view"`
4. Click **transact**.

**Verification:**

Check the following public variables:
- `interactionCounter`
- `interactions(1)`

After successful execution, the following event is emitted:

```solidity
InteractionRecorded
```

# Testing Error Conditions

## Attempting to Publish an Unapproved Artwork

If `publishArtwork()` is called for an artwork that does not have the `Approved` status, the transaction is reverted with the following custom error:

```solidity
NotApproved()
```

## Attempting to Review an Artwork as a Regular User

If an account other than the curator calls `reviewArtwork()`, the transaction is reverted with:

```solidity
OnlyCurator()
```

## Access Control

Only the curator (the contract deployer's address) can:
- Review and update artwork statuses.
- Publish approved artworks.

All users can:
- Submit artworks.
- Record interactions with existing artworks.

## License

This project is licensed under the **MIT License**, as specified by the SPDX license identifier at the top of the Solidity source file.
