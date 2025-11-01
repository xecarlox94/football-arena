{
  description = "bevy flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      rust-overlay,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let

        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        download-assets-script = pkgs.writeShellApplication {
          name="download-assets-script";
          runtimeInputs= with pkgs; [wget unzip];
          text=''
            rm -rf ./assets/
            mkdir ./assets/
            wget -O ./assets/master.zip https://github.com/UnravelSports/rs-football-3d/archive/cab54d6d2cd6416eb881cf542f93d1af838bcddd.zip

            cd ./assets/
            unzip master.zip
            rm master.zip
            cp -r rs-football-3d-cab54d6d2cd6416eb881cf542f93d1af838bcddd/assets/* .

            rm -r rs-football-3d-cab54d6d2cd6416eb881cf542f93d1af838bcddd/

          '';
        };


      in
      {

        devShells.default =
          with pkgs;
          mkShell {
            buildInputs =
              [
                # Rust dependencies
                (rust-bin.stable.latest.default.override { extensions = [ "rust-src" ]; })
                pkg-config
                download-assets-script
              ]
              ++ lib.optionals (lib.strings.hasInfix "linux" system) [
                # for Linux
                # Audio (Linux only)
                alsa-lib
                # Cross Platform 3D Graphics API
                vulkan-loader
                # For debugging around vulkan
                vulkan-tools
                # Other dependencies
                libudev-zero
                xorg.libX11
                xorg.libXcursor
                xorg.libXi
                xorg.libXrandr
                libxkbcommon

                wayland
                wayland-protocols
              ];
            RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
            LD_LIBRARY_PATH = lib.makeLibraryPath [
              vulkan-loader
              xorg.libX11
              xorg.libXi
              xorg.libXcursor
              libxkbcommon

              wayland
            ];
          };
      }
    );
}
