{ lib, nixos, dev, ... }:
{
  # pkgImport :: Nixpkgs -> Overlays -> System -> Pkgs
  pkgImport = nixpkgs: overlays: system:
    import nixpkgs {
      inherit system overlays;
      config = { allowUnfree = true; };
    };

  profileMap = map (profile: profile.default);

  mkDevos = dev.callLibs ./mkDevos.nix;

  mkNodes = dev.callLibs ./mkNodes.nix;

  mkHosts = dev.callLibs ./mkHosts.nix;

  mkSuites = dev.callLibs ./mkSuites.nix;

  mkProfileAttrs = dev.callLibs ./mkProfileAttrs.nix;

  mkPkgs = dev.callLibs ./mkPkgs.nix;

  recImport = dev.callLibs ./recImport.nix;

  devosSystem = dev.callLibs ./devosSystem.nix;

  mkHomeActivation = dev.callLibs ./mkHomeActivation.nix;

  mkPackages = dev.callLibs ./mkPackages.nix;
}

