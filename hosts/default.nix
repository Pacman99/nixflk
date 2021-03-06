{ extern
, home
, lib
, nixos
, nixos-hardware
, override
, pkgs
, self
, system
, ...
}:
let
  inherit (lib.flk) recImport nixosSystemExtended defaultImports;
  inherit (builtins) attrValues removeAttrs;

  suites = import ../suites { inherit lib; };

  config = hostName:
    nixosSystemExtended {
      inherit system;

      specialArgs = extern.specialArgs // { suites = suites.system; };

      modules =
        let
          core = ../profiles/core;

          modOverrides = { config, overrideModulesPath, ... }:
            let
              overrides = import ../overrides;
              inherit (overrides) modules disabledModules;
            in
            {
              disabledModules = modules ++ disabledModules;
              imports = map
                (path: "${overrideModulesPath}/${path}")
                modules;
            };

          user = {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;

              extraSpecialArgs = extern.userSpecialArgs // { suites = suites.user; };
              sharedModules = extern.userModules ++ (attrValues self.homeModules);
            };
          };

          global = {
            hardware.enableRedistributableFirmware = lib.mkDefault true;

            networking.hostName = hostName;

            nix.nixPath = [
              "nixpkgs=${nixos}"
              "nixos-config=${self}/compat/nixos"
              "home-manager=${home}"
            ];

            nixpkgs = { inherit pkgs; };

            nix.registry = {
              devos.flake = self;
            };

            system.configurationRevision = lib.mkIf (self ? rev) self.rev;
          };

          local = {
            require = [
              "${toString ./.}/${hostName}.nix"
            ];
          };

          # Everything in `./modules/list.nix`.
          flakeModules =
            attrValues self.nixosModules;

        in
        flakeModules ++ [
          core
          global
          local
          user
          modOverrides
        ] ++ extern.modules;

    };

  hosts = recImport {
    dir = ./.;
    _import = config;
  };
in
hosts
