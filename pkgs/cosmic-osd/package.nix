{ lib
, fetchFromGitHub
, rustPlatform
, libcosmicAppHook
, pkg-config
, pulseaudio
, pipewire
, udev
, nix-update-script
, libclang
}:

rustPlatform.buildRustPackage {
  pname = "cosmic-osd";
  version = "1.0.0-beta.1-unstable-2025-09-19";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-osd";
    rev = "c88988f7af0cf6524fdc80131446562226a3494e";
    hash = "sha256-+NwsMCOZeZlPcVVQv3WzRj8vAM8P8qPGsOMaTACVEFQ=";
  };


  cargoHash = "sha256-YcNvvK+Zf8nSS5YjS5iaoipogstiyBdNY7LhWPsz9xQ=";

  nativeBuildInputs = [
    libcosmicAppHook
    pkg-config
  ];
  buildInputs = [
    pulseaudio
    pipewire
    udev
    libclang
  ];

  env.LIBCLANG_PATH = "${libclang.lib}/lib";

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
