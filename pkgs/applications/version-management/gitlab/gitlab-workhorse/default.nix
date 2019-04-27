{ stdenv, fetchFromGitLab, git, go }:

stdenv.mkDerivation rec {
  name = "gitlab-workhorse-${version}";

  version = "8.5.1";

  src = fetchFromGitLab {
    owner = "gitlab-org";
    repo = "gitlab-workhorse";
    rev = "v${version}";
    sha256 = "18m54dl7asqv6d7i5xqmy9jkl93sfr7bzizbg7ap6p1xi7rgzzla";
  };

  buildInputs = [ git go ];

  makeFlags = [ "PREFIX=$(out)" "VERSION=${version}" ];

  meta = with stdenv.lib; {
    homepage = http://www.gitlab.com/;
    platforms = platforms.unix;
    maintainers = with maintainers; [ fpletz globin ];
    license = licenses.mit;
  };
}
