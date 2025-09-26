{ lib
, fetchFromGitHub
, rustPlatform
, geoclue2-with-demo-agent
, glib
, libinput
, pkg-config
, pulseaudio
, pipewire
, udev
, nix-update-script
, openssl
, clang
, libclang
}:

rustPlatform.buildRustPackage {
  pname = "cosmic-settings-daemon";
  version = "1.0.0-beta.1.1-unstable-2025-09-22";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-settings-daemon";
    rev = "181e8f9c6269253f173f1bbcdd1385f23c78c598";
    hash = "sha256-tHG/VoaP1tcns6AyedkkVUpWFlcOclWijsHYQ3vOIjs=";
  };

  cargoHash = "sha256-1YQ7eQ6L6OHvVihUUnZCDWXXtVOyaI1pFN7YD/OBcfo=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];
  buildInputs = [
    libinput
    pulseaudio
    glib
    pipewire
    udev
    openssl
    clang
    libclang
  ];

  LIBCLANG_PATH = "${libclang.lib}/lib";

  env.GEOCLUE_AGENT = "${lib.getLib geoclue2-with-demo-agent}/libexec/geoclue-2.0/demos/agent";

  postInstall = ''
    mkdir -p $out/share/{polkit-1/rules.d,cosmic/com.system76.CosmicSettings.Shortcuts/v1}
    cp data/polkit-1/rules.d/*.rules $out/share/polkit-1/rules.d/
    cp data/system_actions.ron $out/share/cosmic/com.system76.CosmicSettings.Shortcuts/v1/system_actions
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "epoch-(.*)"
    ];
  };

  meta = {
    homepage = "https://github.com/pop-os/cosmic-settings-daemon";
    description = "Settings daemon for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      # lilyinstarlight
    ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-settings-daemon";
  };
}
