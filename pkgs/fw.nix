{
  stdenv,
  qmk,
  dos2unix,
  git,

  kb,
  km ? "default",
  qmk-fw,
  qmk-userspace ? null,
  copy-userspace ? false,
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

  patchPhase = ''
    # Disable env check
    substituteInPlace qmk-fw/lib/python/qmk/cli/__init__.py \
      --replace-fail "if _broken_module_imports('requirements.txt'):" \
        "if False:"
  '';

  configurePhase = ''
    cd qmk-fw
    qmk setup -y
    ${
      if qmk-userspace != null then
        if copy-userspace then
          ''
            echo "Copying layouts from userspace ${qmk-userspace}"
            cp -r ${qmk-userspace}/keyboards/* ./keyboards
          ''
        else
          ''
            echo "Setting userspace to ${qmk-userspace}"
            qmk config user.overlay_dir="${qmk-userspace}"
          ''
      else
        ""
    }
  '';

  buildPhase = ''
    echo "Building keymap ${km} for keyboard ${kb}"
    qmk compile -kb ${kb} -km ${km}
    mkdir -p $out
    cp ${binName} $out
  '';

  dontInstall = true;

  dontFixup = true;
}
