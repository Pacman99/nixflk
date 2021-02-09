#!/usr/bin/env bash
cd .config/nixpkgs/zshPlugins
printf "pkgs:\n{\n" > generated.nix
while read line; do
  printf "$(echo $line | awk '{print $2}') = " >> generated.nix
  nix-prefetch-github --nix $line | sed 1,3d >> generated.nix
  printf ";\n" >> generated.nix
done < zshPluginNames
printf "}" >> generated.nix
