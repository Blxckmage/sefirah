final: prev: {
  spotify = prev.spotify.overrideAttrs (old: {
    version = "1.3.4.258.gc60b10b0946a";
    src = prev.fetchurl {
      name = "spotify-1.3.4.258.gc60b10b0946a-102.snap";
      url = "https://api.snapcraft.io/api/v1/snaps/download/pOBIoZ2LrCB3rDohMxoYGnbN14EHOgD7_102.snap";
      hash = "sha512-JNQbsb4QcEgqZZ1ZJLC2WwBVN/ir8NlfBskEo6E/QCEsWALIeA6mobrZHUCU0WPXmveoK4y9Z5Zn1c0Rin7MpQ==";
    };
  });
}
