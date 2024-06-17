# Knock

Convert ACSM files to PDF/EPUBs with one command on Linux ([and MacOS very soon](https://github.com/BentonEdmondson/knock/issues/58)).

![Demonstration of CLI usage](./assets/demo.png)

*This software does not utilize Adobe Digital Editions nor Wine. It is completely free and open-source software written natively for Linux.*

## Installation

1. Run `uname -ms` and, based on the output, download the latest corresponding [release](https://github.com/BentonEdmondson/knock/releases).
1. `cd` into the directory that knock is in (e.g. `cd ~/Downloads`).
1. Run `mv knock-version-arch-os knock` to rename the binary to `knock`.
1. Run `chmod +x knock` to make it executable.
1. Run `./knock ./path/to/book.acsm` to perform the conversion.
1. Run `mv knock ~/.local/bin` to allow it to be run from anywhere (might not work on some distributions).

### Nix and NixOS (with [flakes](https://nixos.wiki/wiki/Flakes) enabled)

If you are on a system with [Nix](https://github.com/NixOS/nix), you can use the following.

```
nix profile install github:BentonEdmondson/knock
```

If you are on [NixOS](https://github.com/NixOS/nixpkgs), you can add the flake to your system config.

## Dependencies

There are no userspace runtime dependencies.

## Verified Book Sources

Knock should work on any ACSM file, but it has been specifically verified to work on ACSM files purchased [eBooks.com](https://www.ebooks.com/en-us/) and [Kobo](https://www.kobo.com/us/en), among others.

Before buying your ebook, check if it is available for free on [Project Gutenberg](https://gutenberg.org/).

## Contributing

Install [Nix](https://github.com/NixOS/nix) if you don't have it. Enable [flakes](https://nixos.wiki/wiki/Flakes) if you haven't.

### Building

```
nix build
```

### Updating

```
nix flake update
```

### Testing

```
nix run .#tests -- ./tests/workspace
```

Test books can be found [here](https://www.adobe.com/solutions/ebook/digital-editions/sample-ebook-library.html).

### Formatting

```
nix run .#formatter
```

## The Name

The name comes from the [D&D 5e spell](https://roll20.net/compendium/dnd5e/Knock#content) for freeing locked items:

> ### Knock
> *2nd level transmutation*\
> **Casting Time**: 1 action\
> **Range**: 60 feet\
> **Components**: V\
> **Duration**: Instantaneous\
> **Classes**: Bard, Sorcerer, Wizard\
> Choose an object that you can see within range. The object can be a door, a box, a chest, a set of manacles, a padlock, or another object that contains a mundane or magical means that prevents access. A target that is held shut by a mundane lock or that is stuck or barred becomes unlocked, unstuck, or unbarred. If the object has multiple locks, only one of them is unlocked. If you choose a target that is held shut with arcane lock, that spell is suppressed for 10 minutes, during which time the target can be opened and shut normally. When you cast the spell, a loud knock, audible from as far away as 300 feet, emanates from the target object.

## License

This software is licensed under GPLv3. The linked libraries have various licenses.
