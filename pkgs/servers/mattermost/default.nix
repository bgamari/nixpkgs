{ lib, stdenv, fetchurl, fetchFromGitHub, buildGoPackage, buildEnv }:

let
  version = "5.37.2";

  mattermost-server = buildGoPackage rec {
    pname = "mattermost-server";
    inherit version;

    src = fetchFromGitHub {
      owner = "mattermost";
      repo = "mattermost-server";
      rev = "v${version}";
      sha256 = "sha256:1v8r3llwbh7bk62yhrfdmkjkj2fxs9cganjgv99gi9607x571vlh";
    };

    goPackagePath = "github.com/mattermost/mattermost-server";

    ldflags = [
      "-X ${goPackagePath}/model.BuildNumber=nixpkgs-${version}"
    ];

  };

  mattermost-webapp = stdenv.mkDerivation {
    pname = "mattermost-webapp";
    inherit version;

    src = fetchurl {
      url = "https://releases.mattermost.com/${version}/mattermost-${version}-linux-amd64.tar.gz";
      sha256 = "sha256:0cw19jx65kf70nrkzy4baf169inxjbbd443pva7gxzg8wf81ad07";
    };

    installPhase = ''
      mkdir -p $out
      tar --strip 1 --directory $out -xf $src \
        mattermost/client \
        mattermost/i18n \
        mattermost/fonts \
        mattermost/templates \
        mattermost/config
    '';
  };

in
  buildEnv {
    name = "mattermost-${version}";
    paths = [ mattermost-server mattermost-webapp ];

    meta = with lib; {
      description = "Open-source, self-hosted Slack-alternative";
      homepage = "https://www.mattermost.org";
      license = with licenses; [ agpl3 asl20 ];
      maintainers = with maintainers; [ fpletz ryantm ];
      platforms = platforms.unix;
    };
  }
