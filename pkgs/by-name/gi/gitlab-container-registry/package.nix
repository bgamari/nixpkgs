{
  lib,
  buildGoModule,
  fetchFromGitLab,
  fetchurl
}:

buildGoModule rec {
  pname = "gitlab-container-registry";
  version = "4.15.2";
  rev = "v${version}-gitlab";

  # nixpkgs-update: no auto update
  src = fetchFromGitLab {
    owner = "gitlab-org";
    repo = "container-registry";
    inherit rev;
    hash = "sha256-nsWOCKHoryRcVT79/nbWXa0wnIflEeDLro3l21D6bzc=";
  };

  patches = [
    # Fix azure driver test
    (fetchurl {
      url = "https://gitlab.com/gitlab-org/container-registry/-/commit/d44923eb4f4c8a00451811da5d1c1cef8d2b7b31.patch";
      hash = "sha256-GR3SHbjK50RR4qNDpqt1trheprpNsW1xzMIiuwRA4T8=";
    })
    # Fix TestRegulatorEnterExit test
    (fetchurl {
      url = "https://gitlab.com/gitlab-org/container-registry/-/commit/2b34ea628d80718b214763d9c95451dbc4a09465.patch";
      hash = "sha256-gRA5hcbs8KnVahRNr7ZMk6qJqxtAYFMcdofkkS7aV3E=";
    })
    # TestListUnprefixed is broken with the filesystem driver
    (fetchurl {
      url = "https://gitlab.com/gitlab-org/container-registry/-/commit/268689a2f30880b7d122469a4260ca46cbc55ccd.patch";
      hash = "sha256-CoYDcaTGnpasAdg9b31euW3Stlt9zwCU1kUbVhRVdLE=";
    })
  ];

  vendorHash = "sha256-aKE/yr2Sh+4yw4TmpaVF84rJOI6cjs0DKY326+aXO1o=";

  postPatch = ''
    # Disable flaky inmemory storage driver test
    rm registry/storage/driver/inmemory/driver_test.go

    substituteInPlace health/checks/checks_test.go \
      --replace \
        'func TestHTTPChecker(t *testing.T) {' \
        'func TestHTTPChecker(t *testing.T) { t.Skip("Test requires network connection")'
  '';

  meta = with lib; {
    description = "GitLab Docker toolset to pack, ship, store, and deliver content";
    license = licenses.asl20;
    maintainers = with maintainers; [ yayayayaka ] ++ teams.cyberus.members;
    platforms = platforms.unix;
  };
}
