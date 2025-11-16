{ lib
, stdenv
, fetchFromGitHub
, rustPlatform
, libcosmicAppHook
, pkg-config
, pulseaudio
, pipewire
, udev
, nix-update-script
, libclang
, clang
, libinput
}:

rustPlatform.buildRustPackage {
  pname = "cosmic-osd";
  version = "1.0.0-beta.6-unstable-2025-11-11";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-osd";
    rev = "6bc9763f75b0c54727ecc52d0a5dac55f9f002ec";
    hash = "sha256-5GrYWrg/trnzk5gtelVUPmtm3MWiTyqaq6QIGadr3t8=";
  };


  cargoHash = "sha256-cpNp/by8TU2lbb2d3smxUr48mTSLnoPXseiRZScwSXI=";

  nativeBuildInputs = [
    libcosmicAppHook
    pkg-config
    clang
    rustPlatform.bindgenHook
  ];
  buildInputs = [
    libinput
    pulseaudio
    pipewire
    udev
    clang
    libclang
  ];

  preBuild = ''
    # From: https://github.com/NixOS/nixpkgs/blob/1fab95f5190d087e66a3502481e34e15d62090aa/pkgs/applications/networking/browsers/firefox/common.nix#L247-L253
    # Set C flags for Rust's bindgen program. Unlike ordinary C
    # compilation, bindgen does not invoke $CC directly. Instead it
    # uses LLVM's libclang. To make sure all necessary flags are
    # included we need to look in a few places.
    export BINDGEN_EXTRA_CLANG_ARGS="$(< ${stdenv.cc}/nix-support/libc-crt1-cflags) \
      $(< ${stdenv.cc}/nix-support/libc-cflags) \
      $(< ${stdenv.cc}/nix-support/cc-cflags) \
      $(< ${stdenv.cc}/nix-support/libcxx-cxxflags) \
      ${lib.optionalString stdenv.cc.isClang "-idirafter ${stdenv.cc.cc}/lib/clang/${lib.getVersion stdenv.cc.cc}/include"} \
      ${lib.optionalString stdenv.cc.isGNU "-isystem ${stdenv.cc.cc}/include/c++/${lib.getVersion stdenv.cc.cc} -isystem ${stdenv.cc.cc}/include/c++/${lib.getVersion stdenv.cc.cc}/${stdenv.hostPlatform.config} -idirafter ${stdenv.cc.cc}/lib/gcc/${stdenv.hostPlatform.config}/${lib.getVersion stdenv.cc.cc}/include"} \
    "
  '';

  LIBCLANG_PATH = "${libclang.lib}/lib";

  env.POLKIT_AGENT_HELPER_1 = "/run/wrappers/bin/polkit-agent-helper-1";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "epoch-(.*)"
    ];
  };

  meta = {
    homepage = "https://github.com/pop-os/cosmic-osd";
    description = "OSD for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      # lilyinstarlight
    ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-osd";
  };
}
