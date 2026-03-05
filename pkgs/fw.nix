{
  stdenv,
  qmk,
  dos2unix,
  git,

  kb,
  km,
  qmk-fw,
  qmk-userspace ? null,
  ...
}:
let
  binName = "${builtins.replaceStrings [ "/" ] [ "_" ] kb}_${km}.bin";
in
stdenv.mkDerivation rec {
  pname = "qmk_${kb}_${km}";
  version = "0";

  nativeBuildInputs = [
    qmk
    dos2unix
    git
  ];

  # Env vars
  HOME = "/tmp";
  SKIP_GIT = "true";

  # Passing in a flake input as src seems to cause it to just be a nix store
  # path instead of being unpacked to a writeable build dir.
  # Since we have to copy it anyways just don't bother setting src
  # src = qmk-fw;
  unpackPhase = ''
    cp -r ${qmk-fw} qmk-fw
    chmod -R u+w qmk-fw
  '';

  configurePhase = ''
    cd qmk-fw
    qmk setup -y
    ${
      if qmk-userspace != null then
        ''
          echo "Setting userspace to ${qmk-userspace}"
          qmk config user.overlay_dir="${qmk-userspace}"
        ''
      else
        ""
    }
  '';

  buildPhase = ''
    qmk compile -kb ${kb} -km ${km}
    mkdir -p $out
    cp ${binName} $out
  '';

  dontInstall = true;
}
