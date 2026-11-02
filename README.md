# IVG Virtual Gallery – Solidity Smart Contract

## Overview

IVG Virtual Gallery is a Solidity-based smart contract designed to manage artwork submissions, curator reviews, publication, and user interactions in a virtual art gallery.

The contract provides basic on-chain functionality for managing digital artwork records and tracking interactions with submitted artworks.

## Features

- **Artwork Submission:** Any user can submit an artwork by providing its title, description, and tags.
- **Artwork Review:** The curator can review submitted artworks and update their status.
- **Artwork Publication:** Only artworks marked as approved can be published by the curator.
- **Interaction Tracking:** Users can record interactions with existing artworks, such as views or likes.
- **Event Logging:** Events are emitted to provide information about artwork submissions, reviews, publications, and recorded interactions.
- **Access Control:** Certain operations, such as reviewing and publishing artworks, are restricted to the curator.

## Artwork Workflow

Each artwork has one of the following statuses:

| Status | Description |
|---|---|
| `Submitted` | Artwork has been submitted. |
| `UnderReview` | Artwork is being reviewed. |
| `NeedsRevision` | Artwork requires changes. |
| `Rejected` | Artwork has been rejected. |
| `Approved` | Artwork has been approved for publication. |
| `Published` | Artwork has been published. |

The curator can update an artwork's status through the review function. Only artworks with the `Approved` status can be published.

## Smart Contract Structure

The contract includes the following main components:

- **Artwork struct:** Stores the artwork ID, artist address, title, description, tags, and current status.
- **Interaction struct:** Stores the related artwork ID, user address, interaction action, and timestamp.
- **Mappings:** Store artwork and interaction records.
- **Counters:** Track the total number of submitted artworks and recorded interactions.
- **Events:** Provide information about important contract operations.
- **Custom Errors:** Define specific error conditions for access control, invalid artwork IDs, and invalid operations.

## Main Functions

| Function | Description |
|---|---|
| `submitArtwork()` | Submits a new artwork to the gallery. |
| `reviewArtwork()` | Allows the curator to update an artwork's status. |
| `publishArtwork()` | Publishes an artwork if it has been approved. |
| `addInteraction()` | Records a user interaction with an existing artwork. |

## Access Control

The address that deploys the contract is automatically assigned as the curator.

The curator is the only account authorized to review and publish artworks. Any user can submit artworks and record interactions.

## Events

The contract emits the following events:

- `ArtworkSubmitted`
- `ArtworkReviewed`
- `ArtworkPublished`
- `InteractionRecorded`

These events can be used by external applications to monitor contract activity.

## Technology

- **Solidity:** `^0.8.20`
- **Development Environment:** Remix IDE
- **License:** MIT

## Deployment and Testing

The contract can be compiled and deployed using [Remix IDE](https://remix.ethereum.org/).

After deployment, the following operations can be tested:

1. Submit an artwork using `submitArtwork()`.
2. Review the artwork using `reviewArtwork()` from the curator account.
3. Change its status to `Approved`.
4. Publish the approved artwork using `publishArtwork()`.
5. Record an interaction using `addInteraction()`.

Different accounts can be used to test curator permissions and user interactions.

## Notes

This repository contains the Solidity smart contract responsible for the gallery's on-chain functionality. It does not include a frontend application or a complete visual gallery interface.

The interaction records store action labels submitted by users; they do not automatically detect user behavior.

## License

This project is licensed under the MIT License.
