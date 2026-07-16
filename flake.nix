# =========================================================================
# ngeranio — Hugo static-site devShell
# =========================================================================
# Auto-loaded by direnv (./.envrc → `use flake`). Provides the two tools the
# site needs: Hugo itself, and Node for the Tailwind/PostCSS asset pipeline
# (see package.json — @tailwindcss/typography).
#
# Serve:   ./server.sh start        (or:  hugo server -D --bind 0.0.0.0)
# Build:   hugo --gc --minify
# =========================================================================
{
  description = "ngeranio — Hugo site devShell";

  inputs.nixpkgs.url = "nixpkgs/nixos-26.05";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      pkgsFor = system: nixpkgs.legacyPackages.${system};
    in {
      devShells = forAllSystems (system:
        let pkgs = pkgsFor system; in {
          default = pkgs.mkShell {
            packages = with pkgs; [
              hugo        # site generator — nixpkgs ships the EXTENDED edition (SCSS/asset pipeline)
              nodejs_22   # Tailwind / PostCSS asset pipeline (npm install once)
            ];

            shellHook = ''
              echo ""
              echo "  ❯ ngeranio devShell  hugo $(hugo version | awk '{print $2}' | tr -d 'v')  •  node $(node -v)"
              echo "    serve:  ./server.sh start     build:  hugo --gc --minify"
              echo ""
            '';
          };
        });
    };
}
