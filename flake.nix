{
  description = "A generic flake-parts based flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    qmk-fw = {
      url = "https://github.com/qmk/qmk_firmware.git";
      ref = "refs/tags/0.31.12";
      flake = false;
      type = "git";
      submodules = true;
    };
    qmk-userspace = {
      url = "https://github.com/Gigahawk/qmk_userspace.git";
      ref = "personal";
      flake = false;
      type = "git";
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
