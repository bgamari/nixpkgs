{ stdenv, fetchFromGitLab, buildGoPackage }:

buildGoPackage rec {
  version = "1.34.0";
  name = "gitaly-${version}";

  src = fetchFromGitLab {
    owner = "gitlab-org";
    repo = "gitaly";
    rev = "v${version}";
    sha256 = "06r3vpz5nkvskj4xjd5hqlxqwdcmnkxrld9pnmg8ijm8nwiz3kk2";
  };

  goPackagePath = "gitlab.com/gitlab-org/gitaly";

  outputs = [ "bin" "out" ];

  meta = with stdenv.lib; {
    homepage = http://www.gitlab.com/;
    platforms = platforms.unix;
    maintainers = with maintainers; [ roblabla ];
    license = licenses.mit;
  };
}
