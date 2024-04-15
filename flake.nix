{
  description = "Holidefs: Definition-based national holidays in Elixir";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        elixirOverlay = final: prev: {
          elixir-ls = (prev.elixir-ls.override {
            elixir = prev.beam.packages.erlangR24.elixir_1_12;
          });
        };

        pkgs = import nixpkgs { inherit system; overlays = [ elixirOverlay ]; };
      in {
        devShells = {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              nil
              beam.packages.erlangR24.elixir_1_12
              elixir_ls
            ];
          };

          ci = pkgs.mkShell {
            buildInputs = with pkgs; [ beam.packages.erlangR24.elixir_1_12 ];
          };
        };
      }
    );
}
