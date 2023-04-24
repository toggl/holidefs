{
  description = "Holidefs: Definition-based national holidays in Elixir";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  outputs = { self, nixpkgs }:
    let
      elixirOverlay = final: prev: {
        elixir-ls = (prev.elixir-ls.override {
          elixir = prev.beam.packages.erlangR24.elixir_1_12;
        });
      };

      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; overlays = [ elixirOverlay ]; };
    in {
      devShells.${system} = {
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
    };
}
