{ version, sha256, patches ? [], patchFlags ? "" }:
{ stdenv, buildPackages, fetchurl, fetchpatch, fixDarwinDylibNames }:

let
  pname = "icu4c";
  # Cross-compiling icu requires that we first compile it once for the build
  # machine, then again for the host passing a reference to the build tree.
  base = stdenv: bootstrapIcu: args: stdenv.mkDerivation ({
    name = pname + "-" + version;

    src = fetchurl {
      url = "http://download.icu-project.org/files/${pname}/${version}/${pname}-"
        + (stdenv.lib.replaceChars ["."] ["_"] version) + "-src.tgz";
      inherit sha256;
    };

    nativeBuildInputs =
      stdenv.lib.optional (stdenv.buildPlatform != stdenv.hostPlatform) bootstrapIcu;

    # FIXME: This fixes dylib references in the dylibs themselves, but
    # not in the programs in $out/bin.
    buildInputs = stdenv.lib.optional stdenv.isDarwin fixDarwinDylibNames;

    postUnpack = ''
      sourceRoot=''${sourceRoot}/source
      echo Source root reset to ''${sourceRoot}
    '';

    # https://sourceware.org/glibc/wiki/Release/2.26#Removal_of_.27xlocale.h.27
    postPatch = if stdenv ? glibc
      then "substituteInPlace i18n/digitlst.cpp --replace '<xlocale.h>' '<locale.h>'"
      else null; # won't find locale_t on darwin

    inherit patchFlags patches;

    preConfigure = ''
      sed -i -e "s|/bin/sh|${stdenv.shell}|" configure
    '' + stdenv.lib.optionalString stdenv.isArm ''
      # From https://archlinuxarm.org/packages/armv7h/icu/files/icudata-stdlibs.patch
      sed -e 's/LDFLAGSICUDT=-nodefaultlibs -nostdlib/LDFLAGSICUDT=/' -i config/mh-linux
    '';

    configureFlags = ["--disable-debug"]
      ++ stdenv.lib.optional (stdenv.isFreeBSD || stdenv.isDarwin) "--enable-rpath"
      ++ stdenv.lib.optional (stdenv.buildPlatform != stdenv.hostPlatform) "--with-cross-build=${bootstrapIcu}";

    enableParallelBuilding = true;

    meta = with stdenv.lib; {
      description = "Unicode and globalization support library";
      homepage = http://site.icu-project.org/;
      maintainers = with maintainers; [ raskin ];
      platforms = platforms.all;
    };
  } // args);

  bootstrap = base buildPackages.stdenv null {
    installPhase = ''
      mkdir $out
      cp -r * $out
    '';
  };

  native = base stdenv (if stdenv.buildPlatform != stdenv.hostPlatform then bootstrap else null) {
    outputs = [ "out" "dev" ];
    outputBin = "dev";

    # remove dependency on bootstrap-tools in early stdenv build
    postInstall = stdenv.lib.optionalString stdenv.isDarwin ''
      sed -i 's/INSTALL_CMD=.*install/INSTALL_CMD=install/' $out/lib/icu/${version}/pkgdata.inc
    '';

    postFixup = ''moveToOutput lib/icu "$dev" '';

  };
in native
