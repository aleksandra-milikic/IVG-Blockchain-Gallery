// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract IVGGallery {


    error OnlyCurator();
    error ArtworkNotFound();
    error InvalidState();
    error NotApproved();
    error AlreadyPublished();

    
    address public curator;

    constructor() {
        curator = msg.sender;
    }

    uint public artworkCounter;
    uint public interactionCounter;

  
    enum ArtworkStatus {
        Submitted,
        UnderReview,
        NeedsRevision,
        Rejected,
        Approved,
        Published
    }


    struct Artwork {
        uint id;
        address artist;
        string title;
        string description;
        string[] tags;
        ArtworkStatus status;
    }

    struct Interaction {
        uint artworkId;
        address user;
        string action;
        uint timestamp;
    }


    mapping(uint => Artwork) public artworks;
    mapping(uint => Interaction) public interactions;


    event ArtworkSubmitted(uint id, address artist);
    event ArtworkReviewed(uint id, ArtworkStatus status);
    event ArtworkPublished(uint id);

    event InteractionRecorded(
        uint artworkId,
        address user,
        string action
    );


    modifier onlyCurator() {
        if (msg.sender != curator) {
            revert OnlyCurator();
        }
        _;
    }

    modifier artworkExists(uint _id) {
        if (_id == 0 || _id > artworkCounter) {
            revert ArtworkNotFound();
        }
        _;
    }


    function submitArtwork(
        string memory _title,
        string memory _description,
        string memory _tags
    ) public {
        artworkCounter++;

        artworks[artworkCounter] = Artwork({
            id: artworkCounter,
            artist: msg.sender,
            title: _title,
            description: _description,
            tags: new string[](1),
            status: ArtworkStatus.Submitted
        });

        artworks[artworkCounter].tags[0] = _tags;

        emit ArtworkSubmitted(artworkCounter, msg.sender);
    }


    function reviewArtwork(
        uint _id,
        ArtworkStatus _newStatus
    )
        public
        onlyCurator
        artworkExists(_id)
    {
        Artwork storage art = artworks[_id];

        if (art.status == ArtworkStatus.Published) {
            revert InvalidState();
        }

        if (_newStatus == ArtworkStatus.Published) {
            revert InvalidState();
        }

        art.status = _newStatus;

        emit ArtworkReviewed(_id, _newStatus);
    }


    function publishArtwork(uint _id)
        public
        onlyCurator
        artworkExists(_id)
    {
        Artwork storage art = artworks[_id];

        if (art.status != ArtworkStatus.Approved) {
            revert NotApproved();
        }

        if (art.status == ArtworkStatus.Published) {
            revert AlreadyPublished();
        }

        art.status = ArtworkStatus.Published;

        emit ArtworkPublished(_id);
    }


    function addInteraction(
        uint _artworkId,
        string memory _action
    ) public artworkExists(_artworkId) {

        interactionCounter++;

        interactions[interactionCounter] = Interaction({
            artworkId: _artworkId,
            user: msg.sender,
            action: _action,
            timestamp: block.timestamp
        });

        emit InteractionRecorded(
            _artworkId,
            msg.sender,
            _action
        );
    }
}