{ stdenv, fetchFromGitLab, buildGoPackage, ruby, bundlerEnv }:

let
  rubyEnv = bundlerEnv {
    name = "gitaly-env";
    inherit ruby;
    gemdir = ./.;
  };
in buildGoPackage rec {
  version = "1.12.1";
  name = "gitaly-${version}";

  src = fetchFromGitLab {
    owner = "gitlab-org";
    repo = "gitaly";
    rev = "7ca7bcb545ec2a1f688acd75f675bda6f2b221e3";
    sha256 = "1b7vjhaqi6cz9qjkmgnz1mz33k3g2p4g5rj0k97c4zj9lpf5jx53";
  };

  goPackagePath = "gitlab.com/gitlab-org/gitaly";

  passthru = {
    inherit rubyEnv;
  };

  buildInputs = [ rubyEnv.wrappedRuby ];

  postInstall = ''
    mkdir -p $ruby
    cp -rv $src/ruby/{bin,lib} $ruby
  '';

  outputs = [ "bin" "out" "ruby" ];

  meta = with stdenv.lib; {
    homepage = http://www.gitlab.com/;
    platforms = platforms.unix;
    maintainers = with maintainers; [ roblabla ];
    license = licenses.mit;
  };
}
