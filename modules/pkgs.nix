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
          copy-userspace ? false,
        }:
        pkgs.callPackage ../pkgs/fw.nix {
          inherit
            kb
            km
            qmk-fw
            qmk-userspace
            copy-userspace
            ;
        };
    in
    {
      packages = {
        gmmk-pro = build-kb {
          kb = "gmmk/pro/rev1/ansi";
          km = "gigahawk";
        };
        keychron-k3-pro =
          (build-kb {
            qmk-fw = inputs.qmk-fw-keychron;
            kb = "keychron/k3_pro/ansi/rgb";
            km = "gigahawk";
            copy-userspace = true;
          }).overrideAttrs
            (
              final: prev: {
                # HACK: disable factory test code?
                # They randomly overrode some user keymap funcs???
                patchPhase = ''
                  ${prev.patchPhase}

                  substituteInPlace qmk-fw/keyboards/keychron/bluetooth/factory_test.c \
                    --replace-fail 'bool dip_switch_update_user' \
                      '__attribute__((weak)) bool dip_switch_update_user' \
                    --replace-fail 'bool rgb_matrix_indicators_user' \
                      '__attribute__((weak)) bool rgb_matrix_indicators_user' \
                '';
              }
            );
      };
    };
}
