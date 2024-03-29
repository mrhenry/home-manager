{ self, pkgs, stdenv, system, home-manager, ... }:
assert stdenv.isLinux;
let
  cmd = "${home-manager.packages.${system}.default}/bin/home-manager";
in
pkgs.writeShellScriptBin "home-installer"
  ''
    set -e

    nix flake check github:mrhenry/home-manager${if self ? rev then "/${self.rev}" else ""} \
      --extra-substituters https://alpha.pigeon-blues.ts.net/attic/release-public \
      --extra-trusted-public-keys release-public:RLOvxX/CMLa6ffQ5oUDXA5zt/qjMN3u4z6GW+xZ1gWw=

    hmConfigDir="$HOME/.config/home-manager"

    mkdir -p "$hmConfigDir"

    cat <<EOF > "$hmConfigDir/settings.nix"
    {
      username = "$USER";
      system = "${system}";
    }
    EOF

    cat ${./flake-template.nix} > "$hmConfigDir/flake.nix"

    exec ${cmd} switch -b backup
  ''
