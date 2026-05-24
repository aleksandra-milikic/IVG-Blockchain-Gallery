# IVG Virtual Gallery – Pametni ugovor za virtuelnu galeriju

Ovaj repozitorijum sadrži Solidity pametni ugovor `IVGGallery` koji implementira sistem virtuelne galerije umjetničkih djela.

Ugovor omogućava:

- kreiranje umjetničkih djela,
- validaciju i reviziju od strane kustosa,
- objavljivanje u galeriji,
- i evidenciju korisničkih interakcija.

## Tehnički detalji

- **Fajl:** `IVGGallery.sol`
- **Licenca:** `MIT`
- **Verzija Solidity kompajlera:** `^0.8.20`
- **Kontrakt:** `IVGGallery`

Header ugovora:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract IVGGallery {
    ...
}
```

## Pregled funkcionalnosti

Ugovor implementira sistem upravljanja umjetničkim djelima u virtuelnoj galeriji:

- umjetnik kreira umjetničko djelo i šalje ga u sistem;
- kustos vrši validaciju i donosi odluku o statusu djela;
- odobrena djela se objavljuju u galeriji;
- korisnici mogu da interaguju sa djelima (pregled, akcije);
- sve interakcije se trajno čuvaju na blockchain-u.

## State promjenljive

```solidity
address public curator;                 // adresa kustosa (kreira ugovor)

uint public artworkCounter;            // broj umjetničkih djela
uint public interactionCounter;        // broj interakcija

mapping(uint => Artwork) public artworks;        // skladištenje umjetničkih djela
mapping(uint => Interaction) public interactions; // skladištenje interakcija
```

## Enum (status umjetničkog djela)

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

## Structs

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

```solidity
struct Interaction {
    uint artworkId;
    address user;
    string action;
    uint timestamp;
}
```

## Events

```solidity
event ArtworkSubmitted(uint id, address artist);
event ArtworkApproved(uint id);
event ArtworkRejected(uint id);
event ArtworkNeedsRevision(uint id);
event ArtworkPublished(uint id);

event InteractionRecorded(uint artworkId, address user, string action);
```

## Errors (custom errors)

```solidity
error OnlyCurator();
error ArtworkNotFound();
error InvalidState();
error NotApproved();
error AlreadyPublished();
```

Ove greške se koriste umjesto `require` poruka, radi uštede gasa i ljepše signalizacije razloga greške.

## Konstruktor

```solidity
constructor() {
    curator = msg.sender;
}
```

## Funkcije

### 1. `submitArtwork()`

Funkcija za kreiranje umjetničkog djela.

```solidity
function submitArtwork(
    string memory _title,
    string memory _description,
    string[] memory _tags
) public
```

Logika:

- povećava se brojač umjetničkih djela;
- čuva se novo djelo u mapping-u;
- status se postavlja na `Submitted`;
- emituje se event `ArtworkSubmitted`.

### 2. `reviewArtwork()`

Funkcija za validaciju umjetničkog djela (kustos).

```solidity
function reviewArtwork(uint _id, bool approve, bool needsRevision) public
```

Logika:

- provjerava se da li je poziv kustos;
- ako je `approve` → status `Approved`;
- ako je `needsRevision` → status `NeedsRevision`;
- u suprotnom → `Rejected`;
- emituje se odgovarajući event.

### 3. `publishArtwork()`

Funkcija za objavljivanje umjetničkog djela.

```solidity
function publishArtwork(uint _id) public
```

Logika:

- provjerava se da li je pozvao kustos;
- provjerava se da li je djelo `Approved`;
- status se postavlja na `Published`;
- emituje se event `ArtworkPublished`.

### 4. `addInteraction()`

Funkcija za bilježenje korisničkih interakcija.

```solidity
function addInteraction(uint _artworkId, string memory _action) public
```

Logika:

- povećava se brojač interakcija;
- čuva se interakcija u mapping-u;
- emituje se event `InteractionRecorded`.

## Napomena o sistemu preporuka

Pametni ugovor ne implementira sistem preporuka direktno na blockchain-u.

Umjesto toga:

- interakcije se čuvaju on-chain,
- eksterni sistemi koriste event logove za analizu,
- na osnovu toga se generišu preporuke van lanca.

# Kako pokrenuti ugovor u Remix IDE-u

1. Otvoriti [Remix](https://remix.ethereum.org/).
2. Kreirati fajl `IVGGallery.sol` i nalijepiti cio kod ugovora.
3. U tabu **Solidity Compiler**:
   - izaberiti verziju `0.8.20` (ili kompatibilnu 0.8.x verziju),
   - kliknuti **Compile IVGGallery.sol**.

4. U tabu **Deploy & Run Transactions**:
   - **Environment** postaviti na `Remix VM`,
   - kliknuti na **Deploy**.

5. Nakon deploy-a pojavljuju se funkcije ugovora:
   - `submitArtwork`
   - `reviewArtwork`
   - `publishArtwork`
   - `addInteraction`

# Testiranje ponašanja

## Kreiranje umjetničkog djela

1. Izabrati prvi nalog u Remix-u (umjetnik).
2. Pozvati funkciju `submitArtwork()`.
3. Unijeti:
   - `_title` → npr. `"The Kiss"`
   - `_description` → npr. `"Famous painting by Gustav Klimt, part of the Austrian Symbolist movement"`
   - `_tags` → npr. `"symbolism,art-nouveau,classic-art"`

4. Kliknuti na **transact**.

Može se provjeriti:

- `artworkCounter`
- `artworks(1)`

Nakon izvršavanja emituje se event:

```solidity id="j6t3x5"
ArtworkSubmitted
```

## Validacija umjetničkog djela

1. Ostati na nalogu koji je deploy-ovao ugovor (kustos).
2. Pozvati funkciju `reviewArtwork()`.
3. Unijeti:
   - `_id` → `1`
   - `_newStatus`:
     - `4` → Approved
     - `2` → NeedsRevision
     - `3` → Rejected

4. Kliknuti na **transact**.

Može se provjeriti:

- promjena statusa u `artworks(1)`

Nakon izvršavanja emituje se event:

```solidity id="e1th7v"
ArtworkReviewed
```

## Objavljivanje umjetničkog djela

1. Pozvati funkciju `publishArtwork()`.
2. Unijeti:
   - `_id` → `1`

3. Kliknuti na **transact**.

Uslov:

- umjetničko djelo mora prethodno imati status `Approved`.

Može se provjeriti:

- status `Published` u `artworks(1)`

Nakon izvršavanja emituje se event:

```solidity id="7m4gks"
ArtworkPublished
```

## Dodavanje korisničke interakcije

1. Promjeniti nalog u Remix-u (korisnik).
2. Pozvati funkciju `addInteraction()`.
3. Unijeti:
   - `_artworkId` → `1`
   - `_action` → npr. `"like"` ili `"view"`

4. Kliknuti na **transact**.

Može se provjeriti:

- `interactionCounter`
- `interactions(1)`

Nakon izvršavanja emituje se event:

```solidity id="8h5m0t"
InteractionRecorded
```

# Testiranje grešaka

## Pokušaj objavljivanja bez odobrenja

Ako se pozove `publishArtwork()` nad djelom koje nije `Approved`, transakcija će biti poništena (`revert`) preko custom error-a:

```solidity id="bbdln3"
NotApproved()
```

## Pokušaj validacije od strane korisnika

Ako funkciju `reviewArtwork()` pozove nalog koji nije kustos, transakcija će biti poništena:

```solidity id="b1a0wy"
OnlyCurator()
```

## Napomena o pristupu

- Samo kustos (creator address) može:
  - vršiti validaciju umjetničkih djela
  - objavljivati u galeriji

## Licenca

Ovaj projekat je licenciran pod **MIT** licencom, u skladu sa SPDX oznakom na vrhu fajla.
