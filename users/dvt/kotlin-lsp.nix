{
  stdenvNoCC,
  fetchzip,
  makeWrapper,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "kotlin-lsp";
  version = "0.253.10629";
  src = fetchzip {
    url = "https://download-cdn.jetbrains.com/kotlin-lsp/261.13587.0/kotlin-lsp-261.13587.0-linux-aarch64.zip";
    sha256 = "sha256-MhHEYHBctaDH9JVkN/guDCG1if9Bip1aP3n+JkvHCvA=";
    stripRoot = false;
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp -r $src $out/share
    chmod +wx $out/share/kotlin-lsp.sh
    sed "s|\$JAVA_BIN|java|" $src/kotlin-lsp.sh | \
    sed "s|chmod.*||" > $out/share/kotlin-lsp.sh
    makeWrapper $out/share/kotlin-lsp.sh $out/bin/kotlin-lsp
  '';
})
