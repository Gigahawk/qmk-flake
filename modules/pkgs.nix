{ inputs, ... }:
{
  perSystem =
    {
      pkgs,
      ...
    }:
    let
      build-kb =
        {
          kb,
          km ? "default",
          qmk-fw ? inputs.qmk-fw,
          qmk-userspace ? inputs.qmk-userspace,
        }:
        pkgs.callPackage ../pkgs/fw.nix {
          inherit
            kb
            km
            qmk-fw
            qmk-userspace
            ;
        };
    in
    {
      packages = {
        gmmk-pro = build-kb {
          kb = "gmmk/pro/rev1/ansi";
          km = "gigahawk";
        };
        keychron-k3-pro = build-kb {
          qmk-fw = inputs.qmk-fw-keychron;
          kb = "keychron/k3_pro/ansi/rgb";
        };
      };
    };
}
