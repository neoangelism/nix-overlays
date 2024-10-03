{ nixpkgs
, autoconf
, autoreconfHook
, bzip2
, automake
, bash
, buildPackages
, cmake
, fetchpatch
, fetchFromBitbucket
, fetchFromGitHub
, fetchFromGitLab
, fzf
, git
, libgsl
, kerberos
, lib
, libargon2
, libcxx
, libvirt
, libpq
, libev-oc
, libffi-oc
, linuxHeaders
, llvmPackages
, lz4-oc
, net-snmp
, nodejs_latest
, pcre-oc
, sqlite-oc
, makeWrapper
, darwin
, stdenv
, super-opaline
, gmp-oc
, openssl-oc
, oniguruma-lib
, overrideSDK
, pam
, pkg-config
, python3
, python3Packages
, lmdb
, curl
, libsodium
, cairo
, gtk2
, rdkafka-oc
, zlib-oc
, unzip
, freetype
, fontconfig
, libxkbcommon
, libxcb
, xorg
, zstd-oc
, mercurial
, gnutar
, coreutils
}:

oself: osuper:

let
  nativeCairo = cairo;
  nativeGit = git;
  lmdb-pkg = lmdb;
  disableTests = d: d.overrideAttrs (_: { doCheck = false; });
  addBase = p: p.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ oself.base ];
  });
  addStdio = p: p.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ oself.stdio ];
  });

  # Jane Street
  janePackage_0_16 =
    oself.callPackage "${nixpkgs}/pkgs/development/ocaml-modules/janestreet/janePackage_0_15.nix" {
      defaultVersion = "0.16.0";
    };
  janePackage_0_17 =
    oself.callPackage "${nixpkgs}/pkgs/development/ocaml-modules/janestreet/janePackage_0_15.nix" {
      defaultVersion = "0.17.0";
    };

  janeStreet_0_16 = import ./janestreet-0.16.nix {
    self = oself;
    openssl = openssl-oc;
    postgresql = libpq;
    inherit
      bash
      fetchpatch
      fetchFromGitHub
      fzf
      lib
      kerberos
      linuxHeaders
      nixpkgs
      pam
      net-snmp;
    zstd = zstd-oc;
  };
  janeStreet_0_17 = import ./janestreet-0.17.nix {
    self = oself;
    openssl = openssl-oc;
    postgresql = libpq;
    inherit
      bash
      fetchpatch
      fetchFromGitHub
      fzf
      lib
      kerberos
      linuxHeaders
      nixpkgs
      pam
      net-snmp;
    zstd = zstd-oc;
  };

  isFlambda2 = lib.hasSuffix "flambda2" osuper.ocaml.version;

in

with oself;

{
  janePackage =
    if lib.versionAtLeast ocaml.version "5.1" then
      janePackage_0_17
    else janePackage_0_16;
  janeStreet =
    if lib.versionAtLeast ocaml.version "5.1" then
      janeStreet_0_17
    else janeStreet_0_16;

  angstrom = osuper.angstrom.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "anmonteiro";
      repo = "angstrom";
      rev = "3173a5eb564f0f087db94b206460df02ac394281";
      hash = "sha256-l0HdDOZL8p72u6KzMkIVrZxUSVlo2GIcpgb6nQU6eTk=";
    };
    propagatedBuildInputs = [ bigstringaf ];
  });

  ansi = buildDunePackage {
    pname = "ansi";
    version = "0.7.0";
    src = builtins.fetchurl {
      url = "https://github.com/ocurrent/ansi/releases/download/0.7.0/ansi-0.7.0.tbz";
      sha256 = "1958wiwba3699qxyhrqy30g2b7m82i2avnaa38lx3izb3q9nlav7";
    };
    propagatedBuildInputs = [ fmt astring tyxml ];
  };

  argon2 = buildDunePackage {
    pname = "argon2";
    version = "1.0.2";
    src = builtins.fetchurl {
      url = "https://github.com/Khady/ocaml-argon2/releases/download/1.0.2/argon2-1.0.2.tbz";
      sha256 = "01gjs2b0nzyjfjz1aay8f209jlpr1880qizk96kn8kqgi5bhwfrl";
    };
    propagatedBuildInputs = [ ctypes dune-configurator ctypes-foreign result libargon2 ];
  };

  archi = callPackage ./archi { };
  archi-lwt = callPackage ./archi/lwt.nix { };
  archi-async = callPackage ./archi/async.nix { };
  async-uri = buildDunePackage {
    pname = "async-uri";
    version = "0.4.0";
    src = builtins.fetchurl {
      url = "https://github.com/vbmithr/async-uri/releases/download/0.4.0/async-uri-0.4.0.tbz";
      sha256 = "16hz01g42aj0zvjqjadg3x4j1jvd279c4vbc2f6zcjvm0dzmlbs0";
    };
    propagatedBuildInputs = [ async_ssl uri uri-sexp ];
  };

  asn1-combinators = osuper.asn1-combinators.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = "https://github.com/mirleft/ocaml-asn1-combinators/releases/download/v0.3.2/asn1-combinators-0.3.2.tbz";
      sha256 = "0zwa1pxprzq77h5y6j2s7dj14zkmsrdkb14zrlyhf8i7drgrh9ib";
    };
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ ohex ];
  });

  atdts = buildDunePackage {
    pname = "atdts";
    inherit (atdgen-codec-runtime) version src;
    propagatedBuildInputs = [ atd cmdliner ];
  };

  awa = osuper.awa.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = "https://github.com/mirage/awa-ssh/releases/download/v0.4.0/awa-0.4.0.tbz";
      sha256 = "1d69d64im477z982vkny3q4q3ps3fwgsri4vqz0wimw9pwdcl15q";
    };
  });

  multiformats = buildDunePackage {
    pname = "multiformats";
    version = "dev";
    src = fetchFromGitHub {
      owner = "crackcomm";
      repo = "ocaml-multiformats";
      rev = "380208ded45bc33cfadc5de6709846b3a8b84615";
      sha256 = "sha256-OuGBf8LdoiuC9OkTObwP5sgT6LXVtdTCsPbg8T1OHt8=";
    };
    propagatedBuildInputs = [ ppx_jane ppx_deriving core_kernel stdint digestif ];
  };

  backoff = buildDunePackage {
    pname = "backoff";
    version = "0.1.1";
    src = builtins.fetchurl {
      url = "https://github.com/ocaml-multicore/backoff/releases/download/0.1.1/backoff-0.1.1.tbz";
      sha256 = "00wzmhvkg5d6jgqjqkjfgd2dh7wbwgfa97c7al5brc97n88s7gh0";
    };
  };

  bap = callPackage "${nixpkgs}/pkgs/development/ocaml-modules/bap" {
    inherit (llvmPackages) llvm;
  };
  ppx_bap = callPackage "${nixpkgs}/pkgs/development/ocaml-modules/ppx_bap" { };

  base32 = buildDunePackage {
    pname = "base32";
    version = "dev";
    src = builtins.fetchurl {
      url = "https://gitlab.com/public.dream/dromedar/ocaml-base32/-/archive/main/ocaml-base32-main.tar.gz";
      sha256 = "0babid89q3vpgvq10cw233k9xzblsk89vh02ymviblgfjhm92lk5";
    };
  };

  bechamel = buildDunePackage {
    pname = "bechamel";
    version = "0.5.0";

    src = builtins.fetchurl {
      url = "https://github.com/mirage/bechamel/releases/download/v0.5.0/bechamel-0.5.0.tbz";
      sha256 = "0s68bsfa4j8y69pfxlylc9qrfkgrifc849rmcyh2x9jz752ab6ig";
    };
    propagatedBuildInputs = [ fmt ];
  };

  benchmark = buildDunePackage {
    pname = "benchmark";
    version = "1.6";

    src = fetchFromGitHub {
      owner = "Chris00";
      repo = "ocaml-benchmark";
      rev = "1.6";
      sha256 = "sha256-10KoyCLzY+uv0lCVrXD6YccLFmoknDa58cF9+aRrGzQ=";
    };
  };

  bencode = buildDunePackage {
    pname = "bencode";
    version = "2.0";
    src = fetchFromGitHub {
      owner = "rgrinberg";
      repo = "bencode";
      rev = "2.0";
      sha256 = "sha256-sEMS9oBOPeFX1x7cHjbQhCD2QI5yqC+550pPqqMsVws=";
    };
  };

  bigarray-compat = osuper.bigarray-compat.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = "https://github.com/mirage/bigarray-compat/releases/download/v1.1.0/bigarray-compat-1.1.0.tbz";
      sha256 = "1m8q6ywik6h0wrdgv8ah2s617y37n1gdj4qvc86yi12winj6ji23";
    };
  });

  bigarray-overlap = osuper.bigarray-overlap.overrideAttrs (o: {
    postPatch = ''
      substituteInPlace ./freestanding/Makefile --replace-fail "pkg-config" "\$(PKG_CONFIG)"
    '';
  });

  bigstringaf = osuper.bigstringaf.overrideAttrs (o: {
    buildInputs = [ dune-configurator ];
    src = fetchFromGitHub {
      owner = "inhabitedtype";
      repo = "bigstringaf";
      rev = "0.10.0";
      hash = "sha256-p1hdB3ArOd2UX7S6YvXCFbYjEiXdMDmBaC/lFQgua7Q=";
    };
  });

  binaryen = callPackage ./binaryen { };

  bisect_ppx = osuper.bisect_ppx.overrideAttrs (_: {
    buildInputs = [ ];
    propagatedBuildInputs = [ ppxlib cmdliner ];
  });

  bos = osuper.bos.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "dbuenzli";
      repo = "bos";
      rev = "v0.2.1";
      sha256 = "sha256-ga7CwQpXntW0wg6tP9/c16wfSGEf07DfZdd7b6cp0r0=";
    };
  });

  bz2 = stdenv.mkDerivation rec {
    pname = "ocaml${ocaml.version}-bz2";
    version = "0.7.0";

    src = fetchFromGitLab {
      owner = "irill";
      repo = "camlbz2";
      rev = version;
      sha256 = "sha256-jBFEkLN2fbC3LxTu7C0iuhvNg64duuckBHWZoBxrV/U=";
    };

    autoreconfFlags = [ "-I" "." ];

    nativeBuildInputs = [
      autoreconfHook
      ocaml
      findlib
    ];

    propagatedBuildInputs = [
      bzip2
    ];

    strictDeps = true;

    preInstall = "mkdir -p $OCAMLFIND_DESTDIR/stublibs";
    postPatch = ''
      substituteInPlace bz2.ml --replace-fail "Pervasives" "Stdlib"
      substituteInPlace bz2.mli --replace-fail "Pervasives" "Stdlib"
    '';

    meta = with lib; {
      description = "OCaml bindings for the libbz2 (AKA, bzip2) (de)compression library";
      downloadPage = "https://gitlab.com/irill/camlbz2";
      license = licenses.lgpl21;
      maintainers = with maintainers; [ ];
    };
  };

  ca-certs = osuper.ca-certs.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = "https://github.com/mirage/ca-certs/releases/download/v1.0.0/ca-certs-1.0.0.tbz";
      sha256 = "0wha5i3f5dz2l01lh5nl4yq2gdhnxj2bd8fqyaclfwj64cqz5446";
    };
  });

  ca-certs-nss = osuper.ca-certs-nss.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = "https://github.com/mirage/ca-certs-nss/releases/download/v3.104/ca-certs-nss-3.104.tbz";
      sha256 = "02d7jnv73rrnj7g4f38waqm24xy0ydqy994kmrp8j46kl7i5h92s";
    };
  });

  camlimages = osuper.camlimages.overrideAttrs (o: {
    buildInputs = o.buildInputs ++ [ findlib ];
  });

  camlp5 = callPackage ./camlp5 { };

  camlzip = (osuper.camlzip.override { zlib = zlib-oc; }).overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "xavierleroy";
      repo = "camlzip";
      rev = "rel112";
      hash = "sha256-oZ8zCdHDd90tYv1fw0Ak1nJ6BnZ0WKvDt/C2pUFooOA=";
    };
  });

  charInfo_width = buildDunePackage {
    pname = "charInfo_width";
    version = "2.0.0";
    src = fetchFromGitHub {
      owner = "kandu";
      repo = "charInfo_width";
      rev = "2.0.0";
      hash = "sha256-JYAa3awHqW5lS4a+TSyK3+xQSi123PhfWwNUt5iOmjg=";
    };
    propagatedBuildInputs = [ camomile ];
    postPatch = ''
      substituteInPlace src/dune --replace-fail "result" ""
      substituteInPlace src/cfg.mli --replace-fail "Result.result" "result"
    '';
  };

  camomile = osuper.camomile.overrideAttrs (o: {
    propagatedBuildInputs = [ camlp-streams dune-site ];
    checkInputs = [ stdlib-random ];
    dontConfigure = true;
    doCheck = true;
    postInstall = null;
  });

  coin = osuper.coin.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = "https://github.com/mirage/coin/releases/download/v0.1.4/coin-0.1.4.tbz";
      sha256 = "0069qqswd1ik5ay3d5q1v1pz0ql31kblfsnv0ax0z8jwvacp3ack";
    };
  });

  containers = osuper.containers.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = "https://github.com/c-cube/ocaml-containers/releases/download/v3.14/containers-3.14.tbz";
      sha256 = "0r75yydndv32hga79i9qwkfps6cm0h98a7y345q9nd2lgh6blky9";
    };
  });

  cairo2 = osuper.cairo2.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace ./src/dune --replace-fail "bigarray" ""
    '';
  });

  cairo2-gtk = buildDunePackage {
    pname = "cairo2-gtk";
    inherit (cairo2) version src;
    nativeBuildInputs = [ nativeCairo pkg-config ];
    buildInputs = [ dune-configurator gtk2.dev ];
    propagatedBuildInputs = [ cairo2 lablgtk ];
  };

  cmarkit = osuper.cmarkit.overrideAttrs (_: {
    buildPhase = "${topkg.buildPhase} --with-cmdliner true";
  });

  caqti = osuper.caqti.overrideAttrs (o: {
    version = "2.1.2";
    src = builtins.fetchurl {
      url = "https://github.com/paurkedal/ocaml-caqti/releases/download/v2.1.2/caqti-v2.1.2.tbz";
      sha256 = "0nw9gvhc4wbnzrwkc9d0p85jqf9vgc5l30pn0ghbaxj3z5gzskds";
    };
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ ipaddr mtime dune-site lwt-dllist ];
    checkInputs = [ alcotest re ];
    doCheck = true;
  });

  caqti-async = osuper.caqti-async.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ conduit-async ];
    postPatch = ''
      substituteInPlace caqti-async/lib/caqti_async.ml --replace-fail \
        "Ivar.fill_exn" "Ivar.fill"
    '';
  });

  caqti-dynload = osuper.caqti-dynload.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ findlib ];
  });


  carton = osuper.carton.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = "https://github.com/robur-coop/carton/releases/download/0.7.2/carton-0.7.2.tbz";
      sha256 = "14mndljn8a375mgb4r83ynqa17kca5sxkj8gv5ycxn2d8iamhya6";
    };
    patches = [ ];
  });

  cbor = buildDunePackage {
    pname = "cbor";
    version = "0.5";
    src = fetchFromGitHub {
      owner = "ygrek";
      repo = "ocaml-cbor";
      rev = "0.5";
      hash = "sha256-f7YwzOZQ7CmmIVuDpbYTdr5nn7prcYh9K9i7ar8IBbI=";
    };
    propagatedBuildInputs = [ ocplib-endian ];
  };

  clz = buildDunePackage {
    pname = "clz";
    version = "0.1.0";
    src = builtins.fetchurl {
      url = "https://github.com/mseri/ocaml-clz/releases/download/0.1.0/clz-0.1.0.tbz";
      sha256 = "08n6qf5g470qx8xhvaizd061qcb3bndvb3c8b9p8cg98n3jpms4q";
    };
    propagatedBuildInputs = [
      ptime
      decompress
      bigstringaf
      lwt
      cohttp-lwt
    ];
  };

  colombe = buildDunePackage {
    pname = "colombe";
    version = "0.9.0";
    src = builtins.fetchurl {
      url = "https://github.com/mirage/colombe/releases/download/v0.9.0/colombe-0.9.0.tbz";
      sha256 = "0gkj6fplq600aw45nk7qil9gxxmh097y5asa4m2qr638ffnnyq35";
    };
    propagatedBuildInputs = [ ipaddr fmt angstrom emile ];
  };
  sendmail = buildDunePackage {
    pname = "sendmail";
    inherit (colombe) version src;
    propagatedBuildInputs = [ colombe tls ke rresult base64 ];
  };
  sendmail-lwt = buildDunePackage {
    pname = "sendmail-lwt";
    inherit (colombe) version src;
    propagatedBuildInputs = [ sendmail lwt tls-lwt ];
  };

  received = buildDunePackage {
    pname = "received";
    version = "0.5.2";
    src = builtins.fetchurl {
      url = "https://github.com/mirage/colombe/releases/download/received-v0.5.2/colombe-received-v0.5.2.tbz";
      sha256 = "1gig5kpkp9rfgnvkrgm7n89vdrkjkbbzpd7xcf90dja8mkn7d606";
    };
    propagatedBuildInputs = [ angstrom emile mrmime colombe ];
  };

  http = buildDunePackage {
    pname = "http";
    version = "n/a";
    src = builtins.fetchurl {
      url = "https://github.com/mirage/ocaml-cohttp/releases/download/v6.0.0_beta2/cohttp-v6.0.0_beta2.tbz";
      sha256 = "05xh4hvjy90mqslwd0q6sa2h99f0p7vb4cf0f911nhc0sn5yrv4h";
    };
    doCheck = false;
  };

  cohttp = osuper.cohttp.overrideAttrs (o: {
    inherit (http) src version;
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ http logs ];
    doCheck = false;
  });
  cohttp-lwt-jsoo = disableTests osuper.cohttp-lwt-jsoo;
  cohttp-top = disableTests osuper.cohttp-top;


  conan = callPackage ./conan { };
  conan-lwt = callPackage ./conan/lwt.nix { };
  conan-unix = callPackage ./conan/unix.nix { };
  conan-database = callPackage ./conan/database.nix { };
  conan-cli = callPackage ./conan/cli.nix { };

  conduit = osuper.conduit.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = "https://github.com/mirage/ocaml-conduit/releases/download/v7.1.0/conduit-7.1.0.tbz";
      sha256 = "1xspxb5v8hb9f1zx7b2cbgrp1s9k68js1373bl10c5z70y523ljq";
    };
  });
  conduit-mirage = osuper.conduit-mirage.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ dns-client-mirage ];
  });

  confero =
    let
      allkeys_txt = builtins.fetchurl {
        url = "https://www.unicode.org/Public/UCA/15.0.0/allkeys.txt";
        sha256 = "0xvmfw9sgcmaqs33w31vcmgqabkb2ls146pb9hvidbfl4isj49qq";
      };
      collationTest = builtins.fetchurl {
        url = "https://www.unicode.org/Public/UCA/15.0.0/CollationTest.zip";
        sha256 = "013w1s3nwalyid9n092my9ri1j0kzc35bphzbrdcaz6l22ph81f3";
      };
    in
    buildDunePackage {
      pname = "confero";
      version = "0.1.1";
      src = fetchFromGitHub {
        owner = "paurkedal";
        repo = "confero";
        rev = "252cf3e";
        sha256 = "sha256-YJyyT4uimLJQH0/bIMe/FCPk0ZYemgHYxV4uaQXVE6w=";
      };

      nativeBuildInputs = [ unzip ];
      postPatch = ''
        cp ${allkeys_txt} ./lib/ducet/allkeys.txt
        cp ${collationTest} ./test/CollationTest.zip
      '';

      doCheck = true;

      propagatedBuildInputs = [
        angstrom
        angstrom-unix
        cmdliner
        fmt
        iso639
        uucp
        uunf
        uutf
      ];
    };

  cookie = callPackage ./cookie { };

  cppo = osuper.cppo.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "ocaml-community";
      repo = "cppo";
      rev = "v1.7.0";
      hash = "sha256-Smd/cV08OuK2p1+K0s6YTDybCEb/0RV6iDL4PO5nvSg=";
    };
  });

  cryptokit = (osuper.cryptokit.override { zlib = zlib-oc; });

  cstruct = osuper.cstruct.overrideAttrs (_: {
    doCheck = !isFlambda2;
  });

  ctypes = osuper.ctypes.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "ocamllabs";
      repo = "ocaml-ctypes";
      rev = "0.23.0";
      hash = "sha256-fZfTsOMppHiI7BVvgICVt/9ofGFAfYjXzHSDA7L4vZk=";
    };
    nativeBuildInputs = o.nativeBuildInputs ++ [ pkg-config ];
    buildInputs = [ dune-configurator ];
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ ];
  });

  ctypes-foreign = disableTests (osuper.ctypes-foreign.override { libffi = libffi-oc.dev; });

  ctypes_stubs_js = osuper.ctypes_stubs_js.overrideAttrs (_: {
    doCheck = false;
  });

  crowbar = osuper.crowbar.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "stedolan";
      repo = "crowbar";
      rev = "0cbe3ea7e990a7d233360e6a74b1cb5e712501ad";
      sha256 = "+92SFFI24HEZe2By990wQKGaR6McggSR711tQHTpiis=";
    };

    doCheck = lib.versionAtLeast ocaml.version "5.0";
  });

  data-encoding = osuper.data-encoding.overrideAttrs (o: {
    buildInputs = [ ];
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ ppx_expect ];
    doCheck = false;
  });

  dataloader = callPackage ./dataloader { };
  dataloader-lwt = callPackage ./dataloader/lwt.nix { };

  decimal = callPackage ./decimal { };

  decoders = buildDunePackage {
    pname = "decoders";
    version = "n/a";
    src = fetchFromGitHub {
      owner = "mattjbray";
      repo = "ocaml-decoders";
      rev = "00d930";
      sha256 = "sha256-LK2CZHvs9itx51EVi/MonrvnGOlPtLDXdMhAFX9O8Uc=";
    };
  };
  decoders-yojson = buildDunePackage {
    pname = "decoders-yojson";
    inherit (oself.decoders) src version;
    propagatedBuildInputs = [ decoders yojson ];
  };

  domain-local-await = disableTests osuper.domain-local-await;
  thread-table = disableTests osuper.thread-table;

  domainslib = osuper.domainslib.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "ocaml-multicore";
      repo = "domainslib";
      rev = "731f08891c87e788f2cc95f2a600328f6682a5e2";
      hash = "sha256-32rk+gUeqFbZWFAjDVPezxnInUM9lPSDiNitMdpPyM4=";
    };
    meta.broken = false;
  });

  rfc1951 = buildDunePackage {
    pname = "rfc1951";
    inherit (decompress) src version;
    propagatedBuildInputs = [ decompress ];
  };

  digestif = osuper.digestif.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = "https://github.com/mirage/digestif/releases/download/v1.2.0/digestif-1.2.0.tbz";
      sha256 = "0255nb9wjpkdh9v0w9p5y5s79zcqcdg3wsw0cx9nd6i7zv56h0f3";
    };
    postPatch = ''
      rm -rf fuzz
    '';
  });

  dkim = buildDunePackage {
    pname = "dkim";
    version = "0.7.0";
    src = builtins.fetchurl {
      url = "https://github.com/mirage/ocaml-dkim/releases/download/v0.7.0/dkim-0.7.0.tbz";
      sha256 = "1aa3s83w7kwgzq8r0r7d32psq36cxn498yml002qi076rimkqp6x";
    };
    propagatedBuildInputs = [
      astring
      hmap
      logs
      mirage-crypto-pk
      domain-name
      x509
      mrmime
    ];
  };
  dkim-bin = buildDunePackage {
    pname = "dkim-bin";
    inherit (dkim) src version;
    propagatedBuildInputs = [
      dkim
      lwt
      tls
      ca-certs
      cmdliner
      logs
      fmt
      fpath
      dns-client
      dns-client-lwt
    ];
  };
  dkim-mirage = buildDunePackage {
    pname = "dkim-mirage";
    inherit (dkim) src version;
    propagatedBuildInputs = [
      dkim
      lwt
      mirage-time
      mirage-clock
      tcpip
      dns-client-mirage
    ];
  };

  dns = osuper.dns.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = "https://github.com/mirage/ocaml-dns/releases/download/v9.0.0/dns-9.0.0.tbz";
      sha256 = "1xnbxb6zl0pplffk8lgi93ll08zvyfzv8pzcaw3lrhsanm6g1x8y";
    };
    propagatedBuildInputs = [
      logs
      ptime
      fmt
      domain-name
      gmap
      ipaddr
      lru
      duration
      metrics
      ohex
      base64
    ];
  });
  dns-client-lwt = osuper.dns-client-lwt.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ happy-eyeballs-lwt ];
  });
  dns-client-mirage = osuper.dns-client-mirage.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ happy-eyeballs-mirage ];
  });
  dns-tsig = osuper.dns-tsig.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ digestif ];
  });

  dose3 = disableTests osuper.dose3;

  dream-html = callPackage ./dream-html { };
  dream-pure = callPackage ./dream/pure.nix { };
  dream-httpaf = callPackage ./dream/httpaf.nix { };
  dream =
    let mf = multipart_form.override { upstream = true; }; in
    callPackage ./dream {
      multipart_form = mf;
      multipart_form-lwt = multipart_form-lwt.override { multipart_form = mf; };
    };

  dream-livereload = callPackage ./dream-livereload { };

  dream-serve = callPackage ./dream-serve { };

  dune_1 = dune;

  dune =
    if lib.versionOlder "4.06" ocaml.version
    then oself.dune_2
    else osuper.dune_1;

  dune_2 = dune_3;

  dune_3 = osuper.dune_3.overrideAttrs (o: {
    version = "3.17.0-dev";
    src = fetchFromGitHub {
      owner = "ocaml";
      repo = "dune";
      rev = "d6f1a2740ac584127105773a43283829ae7a39e7";
      hash = "sha256-tIa6mIQvhPi6B2c7aK+tq3WJkuEPiDuvRtvHkaxCC3w=";
    };
    nativeBuildInputs = o.nativeBuildInputs ++ [ makeWrapper ];
    postFixup =
      if stdenv.isDarwin then ''
        wrapProgram $out/bin/dune \
          --suffix PATH : "${darwin.sigtool}/bin"
      '' else "";
  });

  dune-build-info = osuper.dune-build-info.overrideAttrs (_: {
    buildInputs = [ ];
    propagatedBuildInputs = [ pp ];
    inherit (dyn) preBuild;
  });
  dune-configurator = osuper.dune-configurator.overrideAttrs (_: {
    inherit (dyn) preBuild;
  });
  ordering = osuper.ordering.overrideAttrs (_: {
    inherit (dyn) preBuild;
  });
  dune-rpc = osuper.dune-rpc.overrideAttrs (_: {
    buildInputs = [ ];
    propagatedBuildInputs = [ stdune ordering pp xdg dyn ];
    inherit (dyn) preBuild;
  });
  dune-rpc-lwt = callPackage ./dune/rpc-lwt.nix { };
  dyn = osuper.dyn.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ pp ];
    preBuild = "rm -rf vendor/csexp vendor/pp";
  });
  dune-action-plugin = osuper.dune-action-plugin.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ pp dune-rpc ];
    inherit (dyn) preBuild;
  });
  dune-glob = osuper.dune-glob.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ pp ];
    inherit (dyn) preBuild;
  });
  dune-private-libs = osuper.dune-private-libs.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ pp ];
    inherit (dyn) preBuild;
  });
  dune-site = osuper.dune-site.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ pp ];
    inherit (dyn) preBuild;
  });
  fiber = osuper.fiber.overrideAttrs (o: {
    propagatedBuildInputs = [ dyn stdune ];
    preBuild = "";
  });
  fiber-lwt = buildDunePackage {
    pname = "fiber-lwt";
    inherit (fiber) version src;
    propagatedBuildInputs = [ pp fiber lwt stdune ];
  };

  pp = osuper.pp.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = "https://github.com/ocaml-dune/pp/releases/download/2.0.0/pp-2.0.0.tbz";
      sha256 = "06a4nk6rr4kbkfqsi13azf92y5bnq9qq3q7lvsib94mh30akalc6";
    };
  });

  stdune = osuper.stdune.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ pp ];
    inherit (dyn) preBuild;
  });
  xdg = osuper.xdg.overrideAttrs (o: {
    inherit (dyn) preBuild;
  });

  dune-release = osuper.dune-release.overrideAttrs (o:
    let
      runtimeInputs =
        [ opam findlib nativeGit mercurial bzip2 gnutar coreutils ];
    in
    {
      nativeBuildInputs = [ makeWrapper ocaml dune ] ++ runtimeInputs;
      checkInputs = [ alcotest ] ++ runtimeInputs;
      preFixup = ''
        wrapProgram $out/bin/dune-release \
          --prefix PATH : "${lib.makeBinPath runtimeInputs}"
      '';
    });

  eio-ssl =
    if lib.versionAtLeast ocaml.version "5.0" then
      callPackage ./eio-ssl { }
    else null;

  extlib = osuper.extlib.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "ygrek";
      repo = "ocaml-extlib";
      rev = "1.8.0";
      hash = "sha256-5GvktCAwYSu9SGU06gR51iVf6i5anIYyP+o4pGoF0Dw=";
    };
  });

  ezgzip = buildDunePackage rec {
    pname = "ezgzip";
    version = "0.2.3";
    src = fetchFromGitHub {
      owner = "hcarty";
      repo = pname;
      rev = "v${version}";
      sha256 = "sha256-OQ4JT1pYkeJbi8iMGpcFp8j0DawZCguFfWQmJCwgUXQ=";
    };

    propagatedBuildInputs = [ rresult astring ocplib-endian camlzip ];
  };

  facile = buildDunePackage rec {
    pname = "facile";
    version = "1.1.4";

    src = builtins.fetchurl {
      url = "https://github.com/Emmanuel-PLF/facile/releases/download/${version}/facile-${version}.tbz";
      sha256 = "0jqrwmn6fr2vj2rrbllwxq4cmxykv7zh0y4vnngx29f5084a04jp";
    };

    doCheck = true;
    postPatch = "echo '(lang dune 2.0)' > dune-project";
    meta = {
      homepage = "http://opti.recherche.enac.fr/facile/";
      license = lib.licenses.lgpl21Plus;
      description = "A Functional Constraint Library";
    };
  };

  faraday-async = osuper.faraday-async.overrideAttrs (_: {
    patches = [ ];
  });

  ffmpeg-avdevice = osuper.ffmpeg-avdevice.overrideAttrs (o: {
    propagatedBuildInputs =
      o.propagatedBuildInputs ++
      lib.optionals stdenv.isDarwin
        (with darwin.apple_sdk.frameworks; [ AVFoundation ]);
  });

  fix = osuper.fix.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = "https://anmonteiro.s3.eu-west-3.amazonaws.com/fix-20230505.tar.gz";
      sha256 = "06q8h71q9j1jcr1gprr1ykigb9l4y6zil6c7i9p0b0f4qkyhcvrj";
    };
  });

  ff-pbt = osuper.ff-pbt.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ alcotest ];
  });

  flow_parser = callPackage ./flow_parser { };

  functory = stdenv.mkDerivation {
    pname = "ocaml${ocaml.version}-functory";
    version = "0.6";
    src = builtins.fetchurl {
      url = "https://www.lri.fr/~filliatr/functory/download/functory-0.6.tar.gz";
      sha256 = "18wpyxblz9jh5bfp0hpffnd0q8cq1b0dqp0f36vhqydfknlnpx8y";
    };

    nativeBuildInputs = [ ocaml findlib ];
    strictDeps = true;
    installTargets = [ "ocamlfind-install" ];
    createFindlibDestdir = true;
    postPatch = ''
      substituteInPlace network.ml --replace-fail "Pervasives." "Stdlib."
    '';

    meta = with lib; {
      homepage = "https://www.lri.fr/~filliatr/functory/";
      description = "A distributed computing library for Objective Caml which facilitates distributed execution of parallelizable computations in a seamless fashion";
      license = licenses.lgpl21;
      inherit (ocaml.meta) platforms;
    };
  };

  gettext-camomile = osuper.gettext-camomile.overrideAttrs (_: {
    propagatedBuildInputs = [ camomile ocaml_gettext ];
  });

  git = osuper.git.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = "https://github.com/mirage/ocaml-git/releases/download/3.17.0/git-3.17.0.tbz";
      sha256 = "0r82zmcj7q9sd96hja0508z8j2qfi6c14l6h4n2m66pd2820s87g";
    };
  });

  gluten = callPackage ./gluten { };
  gluten-lwt = callPackage ./gluten/lwt.nix { };
  gluten-lwt-unix = callPackage ./gluten/lwt-unix.nix { };
  gluten-mirage = callPackage ./gluten/mirage.nix { };
  gluten-async = callPackage ./gluten/async.nix { };
  gluten-eio =
    if lib.versionAtLeast ocaml.version "5.0" then
      callPackage ./gluten/eio.nix { }
    else null;

  graphql_parser = callPackage ./graphql/parser.nix { };
  graphql = callPackage ./graphql { };
  graphql-lwt = callPackage ./graphql/lwt.nix { };
  graphql-async = callPackage ./graphql/async.nix { };

  graphql_ppx = callPackage ./graphql_ppx { };
  graphql-cohttp = osuper.graphql-cohttp.overrideAttrs (o: {
    # https://github.com/NixOS/nixpkgs/pull/170664
    nativeBuildInputs = [ ocaml dune findlib crunch ];
  });

  gstreamer = osuper.gstreamer.overrideAttrs (o: {
    buildInputs = o.buildInputs ++
    lib.optionals stdenv.isDarwin [ darwin.apple_sdk.frameworks.Cocoa ];
  });

  hacl-star = osuper.hacl-star.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace ./dune --replace-fail "libraries " "libraries ctypes.stubs "
    '';
  });

  hack_parallel = osuper.hack_parallel.override { sqlite = sqlite-oc; };

  h2 = callPackage ./h2 { };
  h2-lwt = callPackage ./h2/lwt.nix { };
  h2-lwt-unix = callPackage ./h2/lwt-unix.nix { };
  h2-mirage = callPackage ./h2/mirage.nix { };
  h2-async = callPackage ./h2/async.nix { };
  h2-eio =
    if lib.versionAtLeast ocaml.version "5.0" then
      callPackage ./h2/eio.nix { }
    else null;

  hpack = callPackage ./h2/hpack.nix { };

  hachis = buildDunePackage {
    pname = "hachis";
    version = "20240918";
    src = fetchFromGitHub {
      owner = "fpottier";
      repo = "hachis";
      rev = "20240918";
      hash = "sha256-zrsrzZPBqnzEyk+BQqxSSf3j0+h+YfHC/1T0BY1xNcE=";
    };
    nativeBuildInputs = [ cppo ];
  };

  hdr_histogram = buildDunePackage {
    pname = "hdr_histogram";
    version = "0.0.3";

    dontUseCmakeConfigure = true;
    src = builtins.fetchurl {
      url = "https://github.com/ocaml-multicore/hdr_histogram_ocaml/releases/download/v0.0.3/hdr_histogram-0.0.3.tbz";
      sha256 = "05d4w4a5x9kgyx02px2biggkbs8id4xlij2w7gfj663ppc1jr49d";
    };

    nativeBuildInputs = [ cmake ];
    propagatedBuildInputs = [ zlib-oc ctypes ];
  };

  hilite = buildDunePackage {
    pname = "hilite";
    version = "0.5.0";
    src = builtins.fetchurl {
      url = "https://github.com/patricoferris/hilite/releases/download/v0.5.0/hilite-0.5.0.tbz";
      sha256 = "092q0lbpjjbv9szhp9lv0jczf5rr1gqv0wfynv3w9gqhpw5mb2j9";
    };

    propagatedBuildInputs = [ cmarkit textmate-language ];
  };

  hkdf = osuper.hkdf.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = "https://github.com/hannesm/ocaml-hkdf/releases/download/v2.0.0/hkdf-2.0.0.tbz";
      sha256 = "1lsq2frgzhnzcj3i3zblbkmkvzxb0s03845dkkskjkg2kckp3c2l";
    };
    propagatedBuildInputs = [ digestif ];
    checkInputs = [ ohex alcotest ];
  });

  http-mirage-client = osuper.http-mirage-client.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = "https://github.com/robur-coop/http-mirage-client/releases/download/v0.0.7/http-mirage-client-0.0.7.tbz";
      sha256 = "0lxlij4wr7bnvpszvqafa0cjmv51npqwpdnx5xybn4a7bclwk8qq";
    };
  });

  httpun-types = callPackage ./httpun/types.nix { };
  httpun = callPackage ./httpun { };
  httpun-lwt = callPackage ./httpun/lwt.nix { };
  httpun-lwt-unix = callPackage ./httpun/lwt-unix.nix { };
  httpun-mirage = callPackage ./httpun/mirage.nix { };
  httpun-async = callPackage ./httpun/async.nix { };
  httpun-eio =
    if lib.versionAtLeast ocaml.version "5.0" then
      callPackage ./httpun/eio.nix { }
    else null;

  hxd = osuper.hxd.overrideAttrs (o: {
    buildInputs = o.buildInputs ++ [ dune-configurator ];
    doCheck = false;
  });

  hyper = callPackage ./hyper { };

  inotify = osuper.inotify.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = "https://github.com/whitequark/ocaml-inotify/releases/download/v2.6/inotify-2.6.tbz";
      sha256 = "1i6ci7m30bq7ggpvwwy1gcklh9bnbdn2yb8v43qx1p9gsdykw40x";
    };
  });

  iomux = osuper.iomux.overrideAttrs (_: {
    hardeningDisable = [ "strictoverflow" ];
  });

  ipaddr = osuper.ipaddr.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = "https://github.com/mirage/ocaml-ipaddr/releases/download/v5.6.0/ipaddr-5.6.0.tbz";
      sha256 = "0cw1431idd54v067p3mqbxhsgsx5mixl9ywgmak3g92cvczl6c4y";
    };
    doCheck = false;
  });

  macaddr = disableTests osuper.macaddr;

  ipaddr-sexp = osuper.ipaddr-sexp.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ ppx_sexp_conv ];
  });

  irmin-server = buildDunePackage {
    pname = "irmin-server";
    inherit (irmin) src version;
    propagatedBuildInputs = [
      optint
      irmin
      ppx_irmin
      irmin-pack
      uri
      fmt
      cmdliner
      logs
      lwt
      conduit-lwt-unix
      websocket-lwt-unix
      cohttp-lwt-unix
      ppx_blob
      digestif
    ];
    checkInputs = [ alcotest-lwt ];
    doCheck = true;
  };
  irmin-pack-tools = buildDunePackage {
    pname = "irmin-pack-tools";
    inherit (irmin) src version;
    propagatedBuildInputs = [
      ppx_repr
      cmdliner
      ppx_irmin
      ptime
      irmin-pack
      hex
      notty
      irmin-tezos
    ];
  };
  irmin-git = disableTests osuper.irmin-git;

  iostream = buildDunePackage {
    pname = "iostream";
    version = "0.1";
    src = builtins.fetchurl {
      url = "https://github.com/c-cube/ocaml-iostream/releases/download/v0.2.2/iostream-0.2.2.tbz";
      sha256 = "17c2wg6cyhi030vw922p3h6z525h5x2amz2lij6gx96c1zr2a9vd";
    };
  };

  iso639 = buildDunePackage {
    pname = "iso639";
    version = "0.0.5";
    src = builtins.fetchurl {
      url = "https://github.com/paurkedal/ocaml-iso639/releases/download/v0.0.5/iso639-v0.0.5.tbz";
      sha256 = "11bk38m5wsh3g4pr1px3865w8p42n0cq401pnrgpgyl25zdfamk0";
    };
  };

  itv-tree = buildDunePackage {
    pname = "itv-tree";
    version = "2.2";
    src = fetchFromGitHub {
      owner = "UnixJunkie";
      repo = "interval-tree";
      rev = "v2.2";
      sha256 = "sha256-jt8JnY5l9uW5Epjv1ZqGDiLEFU4HHsebcCIS7n6gh6M=";
    };

    propagatedBuildInputs = [ camlp-streams ];
  };

  jose = callPackage ./jose { };

  jsonrpc = osuper.jsonrpc.overrideAttrs (o: {
    src =
      if lib.versionOlder "5.2" ocaml.version then
        builtins.fetchurl
          {
            url = "https://github.com/ocaml/ocaml-lsp/releases/download/1.19.0/lsp-1.19.0.tbz";
            sha256 = "1v75vqhr4i8bx0ys9k5v978qndi8l8salj4i9jzy377qlzqxk0z7";
          }
      else o.src;
  });

  kafka = (osuper.kafka.override {
    rdkafka = rdkafka-oc;
    zlib = zlib-oc;
  }).overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "anmonteiro";
      repo = "ocaml-kafka";
      # https://github.com/anmonteiro/ocaml-kafka/tree/anmonteiro/eio
      rev = "b3497434003a63be349fd413b3f4a7bd9613e33b";
      hash = "sha256-vinwVYDCHdPXvQ4z4nMnaV/9q8fboF6qKp7XHtV3Ow8=";
    };
    nativeBuildInputs = o.nativeBuildInputs ++ [ pkg-config ];
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ dune-configurator ];
    hardeningDisable = [ "strictoverflow" ];
  });

  kafka_async = buildDunePackage {
    pname = "kafka_async";
    inherit (kafka) src version;
    propagatedBuildInputs = [ async kafka ];
    hardeningDisable = [ "strictoverflow" ];
  };

  kafka_lwt =
    buildDunePackage rec {
      pname = "kafka_lwt";
      hardeningDisable = [ "strictoverflow" ];

      inherit (kafka) version src;

      buildInputs = [ cmdliner ];

      propagatedBuildInputs = [ kafka lwt ];

      meta = kafka.meta // {
        description = "OCaml bindings for Kafka, Lwt bindings";
      };
    };

  # Added by the ocaml5.nix
  kcas = null;

  kdf = buildDunePackage {
    pname = "kdf";
    version = "1.0.0";
    src = builtins.fetchurl {
      url = "https://github.com/robur-coop/kdf/releases/download/v1.0.0/kdf-1.0.0.tbz";
      sha256 = "1kp0cbn3v0l7rzb7g0r1rra697wf0qhrr33bvmcdjrpy1qmmhqfi";
    };
    propagatedBuildInputs = [ mirage-crypto digestif ];
    doCheck = true;
    checkInputs = [ alcotest ohex ];
  };

  lablgtk3 = osuper.lablgtk3.overrideAttrs (_: {
    # https://github.com/garrigue/lablgtk/pull/175
    src = fetchFromGitHub {
      owner = "garrigue";
      repo = "lablgtk";
      rev = "a9b64b9ed8a13855c672cde0a2d9f78687f4214b";
      hash = "sha256-CRUIuZ4ILJ0GegrIVHkOg9migQz/OUEGWoN0V0Nb7vc=";
    };
    patches = [ ];
  });

  lacaml = osuper.lacaml.overrideAttrs (_: {
    postPatch =
      if lib.versionAtLeast ocaml.version "5.0" then ''
        substituteInPlace src/dune --replace-fail " bigarray" ""
      '' else "";
  });

  letsencrypt = osuper.letsencrypt.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = "https://github.com/robur-coop/ocaml-letsencrypt/releases/download/v1.0.0/letsencrypt-1.0.0.tbz";
      sha256 = "1w0sli6czy5iinppvxir044ank15xviwmimy3ny8sbd8svbld0wj";
    };
  });

  lev = buildDunePackage {
    pname = "lev";
    version = "n/a";
    src = fetchFromGitHub {
      "owner" = "rgrinberg";
      repo = "lev";
      rev = "2c98545efbc2a485b836294627ad78ca9f562c7d";
      hash = "sha256-kvQIV/b0rlnCmJtQJeqhEsfEQfWS7XWwKGhMYxKHFL8=";
    };
    buildInputs = [ libev-oc ];
  };
  lev-fiber =
    if lib.versionAtLeast osuper.ocaml.version "4.14" then
      buildDunePackage
        {
          pname = "lev-fiber";
          inherit (lev) version src;
          propagatedBuildInputs = [ lev dyn fiber stdune ];
          checkInputs = [ ppx_expect ];
        } else null;
  lev-fiber-csexp =
    if lib.versionAtLeast osuper.ocaml.version "4.14" then
      buildDunePackage
        {
          pname = "lev-fiber";
          inherit (lev) version src;
          propagatedBuildInputs = [ lev-fiber csexp ];
        } else null;

  lilv = osuper.lilv.overrideAttrs (o: {
    postPatch = ''
      substituteInPlace src/dune --replace-fail "ctypes.foreign" "ctypes-foreign"
    '';
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ ctypes-foreign ];
  });

  logs = (osuper.logs.override { jsooSupport = false; }).overrideAttrs (_: {
    pname = "logs";
    propagatedBuildInputs = [ ];
  });

  logs-ppx = callPackage ./logs-ppx { };
  lmdb = buildDunePackage {
    pname = "lmdb";
    version = "1.0";
    src = fetchFromGitHub {
      owner = "Drup";
      repo = "ocaml-lmdb";
      rev = "1.0";
      sha256 = "sha256-NbiM7xNpuihzqAMiAaYXVeItspWufnr1/e3WZEkMhsA=";
    };
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ lmdb-pkg dune-configurator ];
    propagatedBuildInputs = [ bigstringaf ];
  };

  lutils = buildDunePackage {
    pname = "lutils";
    version = "1.51.3";
    src = builtins.fetchurl {
      url = "https://gricad-gitlab.univ-grenoble-alpes.fr/verimag/synchrone/lutils/-/archive/1.51.3/lutils-1.51.3.tar.gz";
      sha256 = "0brbv0hzddac8v9kfm97i81d0x9nnlfpmwgk0mzc2vpy3p3vd315";
    };
    propagatedBuildInputs = [ num camlp-streams ];

    postPatch = ''
      substituteInPlace lib/dune --replace-fail "(libraries " "(libraries camlp-streams "
    '';
  };

  luv = osuper.luv.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "aantron";
      repo = "luv";
      rev = "0.5.14";
      hash = "sha256-N0rtBuxoHg45BqTf+aR8f6SfCEtiFVAspDgWfSkjH6w=";
      fetchSubmodules = true;
    };
    doCheck = false;
  });

  luv_unix = buildDunePackage {
    pname = "luv_unix";
    inherit (luv) version src;
    propagatedBuildInputs = [ luv ];
  };

  lwt = (osuper.lwt.override { libev = libev-oc; });

  lwt-watcher = osuper.lwt-watcher.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = "https://gitlab.com/nomadic-labs/lwt-watcher/-/archive/70f826c503cc094ed2de3aa81fa385ea9fddb903.tar.gz";
      sha256 = "0q1qdmagldhwrcqiinsfag6zxcn5wbvn2p10wpyi8rgk27q3l8sk";
    };
  });

  lwt_react = callPackage ./lwt/react.nix { };

  lz4 = buildDunePackage {
    pname = "lz4";
    version = "1.3.0";
    src = builtins.fetchurl {
      url = "https://github.com/whitequark/ocaml-lz4/releases/download/v1.3.0/lz4-1.3.0.tbz";
      sha256 = "13i4fjvhybnys1x7fjf5k07abq9khh68zr4pqy72si0n740d5frw";
    };
    propagatedBuildInputs = [ dune-configurator ctypes lz4-oc ];
  };

  markup-lwt = buildDunePackage {
    pname = "markup-lwt";
    inherit (markup) src version;
    propagatedBuildInputs = [ markup lwt ];
  };

  matrix-common = callPackage ./matrix { };
  matrix-ctos = callPackage ./matrix/ctos.nix { };
  matrix-stos = callPackage ./matrix/stos.nix { };

  mdx = (osuper.mdx.override { inherit logs; }).overrideAttrs (o: {
    # Break the attempt to reduce `mdx`'s closure size by adding a different
    # `logs` override, which breaks anything that uses logs (with OCaml package
    # conflicts)
    # https://github.com/NixOS/nixpkgs/blob/f6ed1c3c/pkgs/top-level/ocaml-packages.nix#L1035-L1037
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ result cmdliner ];
  });

  melange-json-native = buildDunePackage {
    pname = "melange-json-native";
    version = "1.3.0";
    src = builtins.fetchurl {
      url = "https://github.com/melange-community/melange-json/releases/download/1.3.0/melange-json-1.3.0.tbz";
      sha256 = "1iasna813gdm3aa4xpl5vqgjsh3yrvhz1253m3w3dickjzhpdlwy";
    };
    propagatedBuildInputs = [ ppxlib yojson ];
  };

  mirage-channel = buildDunePackage rec {
    pname = "mirage-channel";
    version = "4.1.0";

    minimalOCamlVersion = "4.07";
    duneVersion = "3";

    src = builtins.fetchurl {
      url = "https://github.com/mirage/mirage-channel/releases/download/v${version}/mirage-channel-${version}.tbz";
      sha256 = "0011lzyxkwz3bwcb2cqbll707rkqh48j1d3jf26rgxfxsi8nh5xh";
    };

    propagatedBuildInputs = [ cstruct logs lwt mirage-flow ];

    meta = {
      description = "Buffered channels for MirageOS FLOW types";
      license = lib.licenses.isc;
      maintainers = [ lib.maintainers.anmonteiro ];
      homepage = "https://github.com/mirage/mirage-channel";
    };
  };

  mirage-crypto = osuper.mirage-crypto.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = "https://github.com/mirage/mirage-crypto/releases/download/v1.1.0/mirage-crypto-1.1.0.tbz";
      sha256 = "0lv3afzql0jgv4wnjxs8n3agfjn3s2fg685hr8ilkmgalxkrf667";
    };
    propagatedBuildInputs = [ eqaf ];
    checkInputs = o.checkInputs ++ [ ohex ];
  });

  mirage-crypto-ec = disableTests osuper.mirage-crypto-ec;
  mirage-crypto-pk = disableTests (osuper.mirage-crypto-pk.override { gmp = gmp-oc; });
  mirage-crypto-rng = osuper.mirage-crypto-rng.overrideAttrs (o: {
    doCheck = false;
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ digestif ];
  });
  mirage-crypto-rng-mirage = osuper.mirage-crypto-rng-mirage.overrideAttrs (o: {
    checkInputs = o.checkInputs ++ [ ohex ];
  });

  mirage-runtime = osuper.mirage-runtime.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = "https://github.com/mirage/mirage/releases/download/v4.5.1/mirage-4.5.1.tbz";
      sha256 = "033yhprafg792c3adlr9na3yb08nzv0j3xvb4ky740y0mbj0pq41";
    };
  });

  mirage-kv-unix = buildDunePackage {
    pname = "mirage-kv-unix";
    version = "3.0.0";
    src = builtins.fetchurl {
      url = "https://github.com/mirage/mirage-kv-unix/releases/download/v3.0.0/mirage-kv-unix-3.0.0.tbz";
      sha256 = "1ian5bb4xhxv902lnn94pzwncqy89asyvmkr8jyrzqml3575923y";
    };
    propagatedBuildInputs = [ mirage-kv ];
    doCheck = true;
    checkInputs = [ alcotest cstruct mirage-clock-unix ];
  };

  mirage-kv-mem = buildDunePackage {
    pname = "mirage-kv-mem";
    version = "3.2.1";
    src = builtins.fetchurl {
      url = "https://github.com/mirage/mirage-kv-mem/releases/download/v3.2.1/mirage-kv-mem-3.2.1.tbz";
      sha256 = "07qr508kb4v9acybncz395p0mnlakib3r8wx5gk7sxdxhmic1z59";
    };
    propagatedBuildInputs = [ optint mirage-kv fmt ptime mirage-clock ];
  };

  mirage-logs = osuper.mirage-logs.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = "https://github.com/mirage/mirage-logs/releases/download/v2.1.0/mirage-logs-2.1.0.tbz";
      sha256 = "1fww8q0an84wiqfwycqlv9chc52a9apf6swbiqk28h1v1jrc52mf";
    };
  });

  miou = osuper.miou.overrideAttrs {
    doCheck = true;
    checkInputs = [ dscheck fmt ];
  };

  mustache = osuper.mustache.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "rgrinberg";
      repo = "ocaml-mustache";
      rev = "d0c45499f9a5ee91c38cf605ae20ecee47142fd8";
      sha256 = "sha256-TOgN4dhI7yjP4cm7q/yvVOtauXMnKOCdMjAgVNzNvSA=";
    };

    doCheck = false;
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ cmdliner ];
    postPatch = ''
      rm -rf bin/dune
      rm -rf bin/mustache_cli.ml
    '';
  });

  melange =
    # No version supported on 5.0
    if (lib.versionAtLeast ocaml.version "4.14" && !(lib.versionAtLeast ocaml.version "5.0"))
    || lib.versionAtLeast ocaml.version "5.1"
    then
      callPackage ./melange { }
    else null;

  menhirCST = buildDunePackage {
    pname = "menhirCST";
    inherit (menhirLib) version src;
  };
  menhir = osuper.menhir.overrideAttrs (o: {
    buildInputs = o.buildInputs ++ [ menhirCST ];
  });
  menhirLib = osuper.menhirLib.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = "https://anmonteiro.s3.eu-west-3.amazonaws.com/menhir-20240715.tar.gz";
      sha256 = "0c60kby2b1zmr0ypqaclakhk3kk4km4qvw7blynzmjxam928cj7g";
    };
  });

  merlin-extend = osuper.merlin-extend.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "let-def";
      repo = "merlin-extend";
      rev = "5780147e47ec2dbbc88d41c2f8cd421814f28db7";
      hash = "sha256-G7AEXKoUMnvQYkPkQ+mn4h+EXrbUUwDESxVmZnEnW/I=";
    };
  });

  merlin-lib =
    if lib.versionAtLeast ocaml.version "4.14" then
      callPackage ./merlin/lib.nix { }
    else null;
  dot-merlin-reader = callPackage ./merlin/dot-merlin.nix { };
  merlin = callPackage ./merlin { };

  metapp = buildDunePackage {
    pname = "metapp";
    version = "0.4.4";
    src = fetchFromGitHub {
      owner = "thierry-martinez";
      repo = "metapp";
      rev = "26e20714348607cec5d978808e666ed414ba092b";
      hash = "sha256-5h7uFPbVtp8A0PbTc+JGlv8H/6xQ1QjwNeRiImAHcfU=";
    };
    propagatedBuildInputs = [ ppxlib stdcompat findlib ];
  };

  mew = osuper.mew.overrideAttrs (_: {
    propagatedBuildInputs = [ trie ];
    postPatch = ''
      substituteInPlace src/dune --replace-fail "result" ""
    '';
  });

  mmap = osuper.mmap.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "mirage";
      repo = "mmap";
      rev = "41596aa";
      sha256 = "sha256-3sx0Wy8XMiW3gpnEo6s2ENP/X1dSSC6NE9SrJex84Kk=";
    };
  });

  minisat = osuper.minisat.overrideAttrs (_: {
    NIX_CFLAGS_COMPILE =
      lib.optionalString stdenv.isDarwin "-I${lib.getDev libcxx}/include/c++/v1";
  });

  morbig = osuper.morbig.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace src/jsonHelpers.ml --replace-fail \
        "Ppx_deriving_yojson_runtime.Result." ""
    '';
  });

  mongo = callPackage ./mongo { };
  mongo-lwt = callPackage ./mongo/lwt.nix { };
  mongo-lwt-unix = callPackage ./mongo/lwt-unix.nix { };
  ppx_deriving_bson = callPackage ./mongo/ppx.nix { };
  bson = callPackage ./mongo/bson.nix { };

  mrmime = disableTests osuper.mrmime;

  mtime = osuper.mtime.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = "https://erratique.ch/software/mtime/releases/mtime-2.1.0.tbz";
      sha256 = "122dhf4qmba4kfpzljcllgqf5ii8b8ylh6rfazcyl09p5s0b4z09";
    };
  });

  multipart_form = callPackage ./multipart_form { };
  multipart_form-lwt = callPackage ./multipart_form/lwt.nix { };

  multicore-bench =
    if lib.versionAtLeast ocaml.version "5.0"
    then osuper.multicore-bench
    else null;

  nanoid = buildDunePackage {
    pname = "nanoid";
    version = "dev";
    src = fetchFromGitHub {
      owner = "routineco";
      repo = "ocaml-nanoid";
      rev = "fb0f4f3262d33d537c9465262264c7d9b5621ee0";
      hash = "sha256-Qzxi6xva+UagziX54ttZq290Nkexh3HEikwHxlkyUM0=";
    };
    propagatedBuildInputs = [ mirage-crypto-rng ];
    checkInputs = [ alcotest ];
    doCheck = true;
  };

  npy = osuper.npy.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace src/dune --replace-fail " bigarray" ""
    '';
  });

  nonstd = buildDunePackage rec {
    pname = "nonstd";
    version = "0.0.3";

    minimalOCamlVersion = "4.02";

    src = fetchFromBitbucket {
      owner = "smondet";
      repo = "nonstd";
      rev = "nonstd.0.0.3";
      hash = "sha256-hkh0zpJXrvafH+q5a9YkBdjIE1uWBRmT2A5VHjPjkjE=";
    };

    postPatch = "echo '(lang dune 2.0)' > dune-project";
    doCheck = true;

    meta = with lib; {
      homepage = "https://bitbucket.org/smondet/nonstd";
      description = "Non-standard mini-library";
      license = licenses.isc;
      maintainers = [ maintainers.alexfmpe ];
    };
  };

  num = (osuper.num.override { withStatic = true; }).overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "ocaml";
      repo = "num";
      rev = "v1.5";
      hash = "sha256-60yT7BN+E93LJWKlO3v55Lbb11pNLPzdf1wrNXkLtmk=";
    };
    buildFlags = [ "opam-modern" ];
    patches = [ ];
    installPhase = ''
      # Not sure if this is entirely correct, but opaline doesn't like `lib_root`
      substituteInPlace num.install --replace-fail lib_root lib
      ${opaline}/bin/opaline -prefix $out -libdir $OCAMLFIND_DESTDIR num.install
    '';
  });

  ocaml =
    (if isFlambda2
    then osuper.ocaml
    else osuper.ocaml.override { flambdaSupport = true; }).overrideAttrs (o: {
      buildPhase = if isFlambda2 then (o.buildPhase or null) else ''
        make defaultentry -j$NIX_BUILD_CORES
      '';
    });

  ocaml-index =
    if lib.versionAtLeast ocaml.version "5.2" then
      callPackage ./ocaml-index { }
    else null;

  ocaml-protoc-plugin = osuper.ocaml-protoc-plugin.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = "https://github.com/andersfugmann/ocaml-protoc-plugin/releases/download/6.1.0/ocaml-protoc-plugin-6.1.0.tbz";
      sha256 = "0yy5d2ih21inx02gdylcscp30gd9vvrm7ky1abyzahcypz3x2m32";
    };
    buildInputs = o.buildInputs ++ [ ptime base64 dune-configurator ];
  });

  ocamlformat = osuper.ocamlformat.overrideAttrs (_: {
    inherit (ocamlformat-lib) src;
  });
  ocamlformat-rpc-lib = buildDunePackage {
    pname = "ocamlformat-rpc-lib";
    inherit (ocamlformat-lib) src version;

    minimumOCamlVersion = "4.08";
    strictDeps = true;

    propagatedBuildInputs = [ csexp ];
  };

  ocamlfuse = osuper.ocamlfuse.overrideAttrs (_: {
    meta = {
      platforms = lib.platforms.all;
    };
  });

  ocaml_sqlite3 = osuper.ocaml_sqlite3.overrideAttrs (o: {
    doCheck = true;
    checkInputs = [ ppx_inline_test ];

    # https://github.com/mmottl/sqlite3-ocaml/pull/62
    patches = [ ./sqlite3-pkg-config-env-var.patch ];
  });

  ocaml_libvirt = osuper.ocaml_libvirt.override {
    libvirt = disableTests libvirt;
  };

  ez_subst = buildDunePackage {
    pname = "ez_subst";
    version = "0.2.1";
    src = fetchFromGitHub {
      owner = "OCamlPro";
      repo = "ez_subst";
      rev = "v0.2.1";
      sha256 = "sha256-d0+H9dxLioa9QHnf2mF+MBk563qxc7YBhpmV1A0uv0s=";
    };
  };

  ez_cmdliner = buildDunePackage {
    pname = "ez_cmdliner";
    version = "0.4.3";
    src = fetchFromGitHub {
      owner = "OcamlPro";
      repo = "ez_cmdliner";
      rev = "v0.4.3";
      sha256 = "sha256-l1JQrMxZsk+CuTDNmoKvzDO/8kGJOY3C8WGetprgR1M=";
    };
    propagatedBuildInputs = [ cmdliner ez_subst ocplib_stuff ];
  };

  ocaml-migrate-types = callPackage ./ocaml-migrate-types { };
  typedppxlib = callPackage ./typedppxlib { };
  ppx_debug = callPackage ./typedppxlib/ppx_debug.nix { };

  ocamlbuild = osuper.ocamlbuild.overrideAttrs (o: {
    nativeBuildInputs = o.nativeBuildInputs ++ [ makeWrapper ];

    patches =
      if isFlambda2
      then [ ./flambda2-ocamlbuild.patch ]
      else [ ];

    # OCamlbuild needs to find the native toolchain when cross compiling (to
    # link myocamlbuild programs)
    postFixup = ''
      wrapProgram $out/bin/ocamlbuild \
        --suffix PATH : "${ buildPackages.stdenv.cc }/bin"
    '';
  });

  ocaml-canvas = buildDunePackage {
    pname = "ocaml-canvas";
    version = "n/a";
    hardeningDisable = [ "strictoverflow" ];
    src = fetchFromGitHub {
      owner = "OCamlPro";
      repo = "ocaml-canvas";
      rev = "962dedd98";
      sha256 = "sha256-PghULCfekMhs88a2F+RJtJFoBJxi80ieDiKzhWukJw4=";
    };

    buildInputs = lib.optionals (! stdenv.isDarwin) [
      freetype
      fontconfig
      libxkbcommon
      libxcb
      xorg.xcbutilkeysyms
      xorg.xcbutilimage
    ] ++ lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
      AppKit
      Foundation
      Carbon
      Cocoa
      CoreGraphics
    ]);

    propagatedBuildInputs = [ dune-configurator react ];
  };

  ocaml-lsp = osuper.ocaml-lsp.overrideAttrs (o: {
    buildInputs = o.buildInputs ++ [ base ];

    postPatch = if lib.versionOlder "5.2" ocaml.version then "" else ''
      substituteInPlace ocaml-lsp-server/src/merlin_config.ml --replace-fail \
        '| `ERROR_MSG' '| `SOURCE_ROOT _ | `UNIT_NAME _ | `WRAPPING_PREFIX _ -> assert false | `ERROR_MSG'

      substituteInPlace \
        "ocaml-lsp-server/src/rename.ml" \
        "ocaml-lsp-server/src/ocaml_lsp_server.ml" --replace-fail \
        'List.map locs' 'List.map (fst locs)'

      substituteInPlace \
        "ocaml-lsp-server/src/ocaml_lsp_server.ml" --replace-fail \
        'List.filter_map locs' 'List.filter_map (fst locs)'

      substituteInPlace \
        "ocaml-lsp-server/src/ocaml_lsp_server.ml" --replace-fail \
        'List.find_opt locs' 'List.find_opt (fst locs)'
    '';
  });

  ocaml-recovery-parser = osuper.ocaml-recovery-parser.overrideAttrs (o: {
    postPatch = ''
      substituteInPlace "menhir-recover/emitter.ml" --replace-fail \
        "String.capitalize" "String.capitalize_ascii"
    '';
  });

  ocaml-version = osuper.ocaml-version.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = "https://github.com/ocurrent/ocaml-version/releases/download/v3.6.9/ocaml-version-3.6.9.tbz";
      sha256 = "11lmfdh1cpzlfarsfcm28a587cfvlsymm7xi7w78lgh34xhabirm";
    };
  });

  ocaml_gettext = osuper.ocaml_gettext.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "gildor478";
      repo = "ocaml-gettext";
      rev = "9fa474310f383abf3d4349a25c44955ee62410c1";
      hash = "sha256-QYKWtHJMHVU86aWh9f6zlB4nuzgQYvignA01m3b54Kg=";
    };
  });

  ocp-indent = osuper.ocp-indent.overrideAttrs (o: {
    postPatch = ''
      substituteInPlace src/dune --replace-fail "libraries bytes" "libraries "
    '';
    buildInputs = o.buildInputs ++ [ findlib ];
  });

  ocplib-simplex = buildDunePackage {
    pname = "ocplib-simplex";
    version = "0.5.1";
    src = builtins.fetchurl {
      url = "https://github.com/OCamlPro/ocplib-simplex/releases/download/v0.5.1/ocplib-simplex-0.5.1.tbz";
      sha256 = "1kqkslhka5r07nm53cspghpb818bi0gb5i9pbm90rrhq9nz19j55";
    };

    propagatedBuildInputs = [ logs ];
  };

  ocplib_stuff = buildDunePackage {
    pname = "ocplib_stuff";
    version = "0.3.0";
    src = fetchFromGitHub {
      owner = "OCamlPro";
      repo = "ocplib_stuff";
      rev = "v0.3.0";
      sha256 = "sha256-Wd9l1pBKaBFMzKaqSBT9mx5oHIQiXd1xB9enov2JWN8=";
    };

    # `String.sub Sys.ocaml_version 0 6` doesn't work on OCaml 5.0
    postPatch =
      if lib.versionAtLeast ocaml.version "5.0" then ''
        substituteInPlace ./src/ocplib_stuff/dune \
          --replace-fail "failwith \"Wrong ocaml version\"" "\"5.0.0\""
      '' else "";
  };

  ocurl = osuper.ocurl.overrideAttrs (_: {
    propagatedBuildInputs = [ curl ];
  });

  odep = buildDunePackage {
    pname = "odep";
    version = "0.2.2";
    src = builtins.fetchurl {
      url = "https://github.com/sim642/odep/releases/download/0.2.1/odep-0.2.1.tbz";
      sha256 = "0snwz7fg46bab9xhg19lfdmw57zcc06q939zih1qjq97rrcyiqgs";
    };
    propagatedBuildInputs = [
      bos
      opam-state
      parsexp
      ppx_deriving
      sexplib
      ppx_sexp_conv
      cmdliner
    ];
  };

  odoc-parser = osuper.odoc-parser.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = "https://github.com/ocaml/odoc/releases/download/2.4.3/odoc-2.4.3.tbz";
      sha256 = "04ibpcxvzyxy21kl8h78rp6kyn5n21hv3dyphzkkr2dl0pn2rfyn";
    };
    propagatedBuildInputs = [ astring camlp-streams ppx_expect ];
    postPatch = ''
      substituteInPlace src/parser/dune --replace-fail "result" ""
    '';
  });

  odoc = osuper.odoc.overrideAttrs (o: {
    inherit (odoc-parser) src;
    nativeBuildInputs = o.nativeBuildInputs ++ [ crunch.bin ];
  });

  oidc = callPackage ./oidc { };
  oidc-client = callPackage ./oidc/client.nix { };

  omd = osuper.omd.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = "https://github.com/ocaml/omd/releases/download/2.0.0.alpha4/omd-2.0.0.alpha4.tbz";
      sha256 = "076zc9mbz9698lcx5fw0hvllbv4n29flglz64n15n02vhybrd5lk";
    };
    preBuild = "";
    propagatedBuildInputs = [ uutf uucp uunf dune-build-info ];
  });

  oniguruma = buildDunePackage {
    pname = "oniguruma";
    version = "0.1.2";
    src = builtins.fetchurl {
      url = "https://github.com/alan-j-hu/ocaml-oniguruma/releases/download/0.1.2/oniguruma-0.1.2.tbz";
      sha256 = "0rc70nwgx4bqm3h7rar2pmnh543np67rw5m8f6gwzhrwvbykzxp3";
    };
    buildInputs = [ dune-configurator ];
    propagatedBuildInputs = [ oniguruma-lib ];
  };

  spdx_licenses = osuper.spdx_licenses.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "kit-ty-kate";
      repo = "spdx_licenses";
      rev = "v1.2.0";
      hash = "sha256-GRadJmX+ddzYa8XwX1Nxe7iYIkcumI94fuTCq6FHAGA=";
    };

  });
  x0install-solver = buildDunePackage {
    pname = "0install-solver";
    version = "2.18";
    src = builtins.fetchurl {
      url = "https://github.com/0install/0install/releases/download/v2.18/0install-2.18.tbz";
      sha256 = "1hr0k47cxqcsycxhmn2ajaakfwnap1m24p068k5xy9hsihqlp334";
    };
  };
  opam-0install-cudf = buildDunePackage {
    pname = "opam-0install-cudf";
    version = "0.5.0";
    src = fetchFromGitHub {
      owner = "ocaml-opam";
      repo = "opam-0install-cudf";
      rev = "v0.5.0";
      hash = "sha256-TETfvR1Di4c8CylsKnMal/GfQcqMSr36o7511u1bYYs=";
    };
    propagatedBuildInputs = [ cudf x0install-solver ];
  };

  opam-client = buildDunePackage {
    pname = "opam-client";
    inherit (opam-format) src version meta;
    configureFlags = [ "--disable-checks" ];
    propagatedBuildInputs = [ cmdliner base64 re opam-repository opam-solver opam-state ];
  };
  opam = buildDunePackage {
    pname = "opam";
    inherit (opam-format) src version meta;
    nativeBuildInputs = [ curl ];
    configureFlags = [ "--disable-checks" ];
    propagatedBuildInputs = [ cmdliner opam-client ];
  };
  opam-core = osuper.opam-core.overrideAttrs (o: {
    inherit (opam-format) src version meta;
  });
  opam-solver = buildDunePackage {
    pname = "opam-solver";
    inherit (opam-format) src version meta;
    configureFlags = [ "--disable-checks" ];
    propagatedBuildInputs = [ opam-0install-cudf re dose3 opam-format ];
  };
  opam-format = osuper.opam-format.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "ocaml";
      repo = "opam";
      rev = "2.3.0-alpha1";
      hash = "sha256-+YTJjZpOd4SelbqemeOKepSwOwfbXi+/2T1ltRfozKA=";
    };
    version = "2.3.0-alpha1";
    meta = with lib; {
      description = "A package manager for OCaml";
      homepage = "https://opam.ocaml.org/";
      changelog = "https://github.com/ocaml/opam/raw/${version}/CHANGES";
      maintainers = [ maintainers.henrytill maintainers.marsam ];
      license = licenses.lgpl21Only;
      platforms = platforms.all;
    };
  });
  opam-state = osuper.opam-state.overrideAttrs (o: {
    inherit (opam-format) src version meta;
  });

  opaline = super-opaline.override { ocamlPackages = oself; };

  eigen = osuper.eigen.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = "https://github.com/owlbarn/eigen/releases/download/0.3.3/eigen-0.3.3.tbz";
      sha256 = "1kiy0pg0a5cnf9zff0137lfgbk7nbs5yc9dimwqdr5lihbi88cd9";
    };
    buildInputs = [ dune-configurator ];
    meta.platforms = lib.platforms.all;
    postPatch = ''
      substituteInPlace "eigen/configure/configure.ml" --replace-fail '-mcpu=apple-m1' ""
      substituteInPlace "eigen_cpp/configure/configure.ml" --replace-fail '-mcpu=apple-m1' ""
    '';
  });
  owl-base = osuper.owl-base.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "owlbarn";
      repo = "owl";
      rev = "d957bd8b6f074947f07a80b835de4e6645b245a0";
      hash = "sha256-hQ7BDFEBIIRhbKtjtf+/AyfO7HVpym3H+P1Y8Vlgah0=";
    };
    meta.platforms = lib.platforms.all;
  });
  owl = osuper.owl.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ eigen ];
    doCheck = false;
    meta = owl-base.meta;
  });

  ocaml_pcre = osuper.ocaml_pcre.override { pcre = pcre-oc; };

  otfed = osuper.otfed.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ stdio ];
  });

  paf = osuper.paf.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "dinosaure";
      repo = "paf-le-chien";
      rev = "0.7.0";
      hash = "sha256-1syLjF30a7xd7VOtSCbNaWAAum+2ewFo+hoH40xyLew=";
    };
  });

  patch = buildDunePackage {
    pname = "patch";
    version = "2.0.0";
    src = builtins.fetchurl {
      url = "https://github.com/hannesm/patch/releases/download/v2.0.0/patch-2.0.0.tbz";
      sha256 = "0n75k3pjj4a9a8y7rxjlscjv15sy3chkibaqfdalr7fpr59lprdh";
    };
    doCheck = true;
    checkInputs = [ alcotest ];
  };

  pbkdf = osuper.pbkdf.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "abeaumont";
      repo = "ocaml-pbkdf";
      rev = "2.0.0";
      hash = "sha256-D2dXpf1D/wsJrcajU3If37tuLYjahoA/+QoXZKr1vQs=";
    };
    propagatedBuildInputs = [ mirage-crypto digestif ];
    checkInputs = o.checkInputs ++ [ ohex ];
  });

  pg_query = callPackage ./pg_query { };

  piaf =
    if lib.versionAtLeast ocaml.version "5.0" then
      callPackage ./piaf { }
    else null;

  plist-xml = buildDunePackage {
    pname = "plist-xml";
    version = "";
    src = builtins.fetchurl {
      url = "https://github.com/alan-j-hu/ocaml-plist-xml/releases/download/0.5.0/plist-xml-0.5.0.tbz";
      sha256 = "1hw3l8q8ip56niszh24yr6dijm7da2rrixdyviffyxv4c9dhd1di";
    };
    nativeBuildInputs = [ menhir ];
    propagatedBuildInputs = [ menhirLib xmlm base64 cstruct iso8601 ];
  };

  postgresql = (osuper.postgresql.override { postgresql = libpq; }).overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "mmottl";
      repo = "postgresql-ocaml";
      rev = "42c42e9cb";
      sha256 = "sha256-6xo0P3kBjnzddOHGP6PZ1ODIkQoZ7pNlTHLrDcd1EYM=";
    };
    nativeBuildInputs = o.nativeBuildInputs ++ [ pkg-config ];

    postPatch = ''
      substituteInPlace src/dune --replace-fail " bigarray" ""
    '';
  });

  ppx_cstruct = disableTests osuper.ppx_cstruct;

  ppx_cstubs = buildDunePackage {
    pname = "ppx_cstubs";
    version = "0.7.0";
    minimalOCamlVersion = "4.08";

    src = fetchFromGitHub {
      owner = "fdopen";
      repo = "ppx_cstubs";
      rev = "0.7.0";
      hash = "sha256-qMmwRWCIfNyhCQYPKLiufnb57sTR3P+WInOqtPDywFs=";
    };

    # patches = [ ./ppxlib.patch ];
    postPatch = ''
      substituteInPlace src/internal/ppxc__script_real.ml \
      --replace 'C_content_make ()' 'C_content_make (struct end)'

      ${lib.optionalString (lib.versionOlder "5.2" ocaml.version) ''
      substituteInPlace src/custom/ppx_cstubs_custom.cppo.ml \
      --replace-fail "init_code fun_code" "init_code" \
      --replace-fail "can_free = fun_code = []" "can_free = fun_code"
      ''}
    '';

    nativeBuildInputs = [ cppo ];

    buildInputs = [
      bigarray-compat
      containers
      findlib
      integers
      num
      ppxlib
      re
    ];

    propagatedBuildInputs = [ ctypes ];

    meta = with lib; {
      homepage = "https://github.com/fdopen/ppx_cstubs";
      description = "Preprocessor for easier stub generation with ocaml-ctypes";
      license = licenses.lgpl21Plus;
      maintainers = [ lib.maintainers.anmonteiro ];
    };
  };

  ppx_jsx_embed = callPackage ./ppx_jsx_embed { };

  ppx_optint = buildDunePackage {
    pname = "ppx_optint";
    version = "0.2.0";
    src = builtins.fetchurl {
      url = "https://github.com/reynir/ppx_optint/releases/download/v0.2.0/ppx_optint-0.2.0.tbz";
      sha256 = "09casz0hzmhj8ajjq595a8aa1l567lzhiszjrv2d8q0jbr8zw19l";
    };
    propagatedBuildInputs = [ optint ppxlib ];
  };

  ppx_rapper = callPackage ./ppx_rapper { };
  ppx_rapper_async = callPackage ./ppx_rapper/async.nix { };
  ppx_rapper_lwt = callPackage ./ppx_rapper/lwt.nix { };

  ppx_deriving = osuper.ppx_deriving.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "ocaml-ppx";
      repo = "ppx_deriving";
      rev = "c3227d1f1ef15d907387dba38c26ea0167645b47";
      hash = "sha256-xq96yAFIKbSl9xnNy8uCzgH2Qc7qHKwuFWoUtDgy0kg=";
    };
    buildInputs = [ ];
    propagatedBuildInputs = [
      findlib
      ppxlib
      ppx_derivers
    ];
  });

  ppx_deriving_cmdliner = osuper.ppx_deriving_cmdliner.overrideAttrs (o: {
    patches = o.patches ++ [ ./ppx_deriving_cmdliner.patch ];
    postPatch = ''
      substituteInPlace src/dune --replace-fail "runtime result" "runtime"
      substituteInPlace test/dune --replace-fail "alcotest result" "alcotest"
    '';
  });

  ppx_deriving_variant_string = buildDunePackage {
    pname = "ppx_deriving_variant_string";
    version = "1.0.0";
    src = builtins.fetchurl {
      url = "https://github.com/ahrefs/ppx_deriving_variant_string/releases/download/1.0.1/ppx_deriving_variant_string-1.0.1.tbz";
      sha256 = "01rgcg3x7yw81kfrv33h9sx0grqs0445ah4k18pf8f0g9hn3s9cx";
    };
    propagatedBuildInputs = [ ppxlib ];
  };

  ppx_deriving_jsonschema = buildDunePackage {
    pname = "ppx_deriving_jsonschema";
    version = "0.0.1";
    src = builtins.fetchurl {
      url = "https://github.com/ahrefs/ppx_deriving_jsonschema/releases/download/0.0.1/ppx_deriving_jsonschema-0.0.1.tbz";
      sha256 = "19l5jvk6w3v6jqik13826nsc62yd3ahni80gb94ipcp8056hivsk";
    };
    propagatedBuildInputs = [ ppxlib ];
  };

  ppx_deriving_yojson = osuper.ppx_deriving_yojson.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = "https://github.com/ocaml-ppx/ppx_deriving_yojson/releases/download/v3.9.0/ppx_deriving_yojson-3.9.0.tbz";
      sha256 = "0is03hbr8grilnvz22v5p2radh90vbh62q99005qp4awc7vg8ib7";
    };
  });

  ppx_tools =
    if lib.versionOlder "5.2" ocaml.version
    then null
    else osuper.ppx_tools;

  ppxlib = osuper.ppxlib.overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "ppxlib";
            rev = "e5ae762556a59c25a7356fe2282adbf51f93e25e";
            hash = "sha256-EB+i0iMt/u/IRp0U/dS2tvQrSjuSxHaPQ3XaPZI6hAs=";
          }
      else
        fetchFromGitHub {
          owner = "ocaml-ppx";
          repo = "ppxlib";
          rev = "ac7fcfc88d574609b62cc0a38e0de59d03cc96de";
          hash = "sha256-I+AZfPyUNmHNJ37FTRUMpKlBY3B+haXaS/fmQIH6WG4=";
        };
    propagatedBuildInputs = [
      ocaml-compiler-libs
      ppx_derivers
      sexplib0
      stdlib-shims
    ];
  });

  processor = buildDunePackage {
    version = "0.2";
    pname = "processor";
    src = fetchFromGitHub {
      owner = "haesbaert";
      repo = "ocaml-processor";
      rev = "0.2";
      hash = "sha256-0jxi3Qz1nlnClPQ6Za0vFBig4ahrkyezicyqmErx1QE=";
    };
    propagatedBuildInputs =
      lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
        Foundation
      ]);
  };

  ptime = osuper.ptime.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = "https://erratique.ch/software/ptime/releases/ptime-1.2.0.tbz";
      sha256 = "1c1swx6h794gcck358nqfzshlfhyw1zb5ji4h1pc63j9vxzp85ln";
    };
  });

  qrc =
    let
      version = "0.2.0";
    in
    stdenv.mkDerivation {
      name = "ocaml${ocaml.version}-qrc-${version}";
      inherit version;
      src = builtins.fetchurl {
        url = "https://erratique.ch/software/qrc/releases/qrc-0.2.0.tbz";
        sha256 = "04cs8h26d9g3n07rb01jgzz2w51y9skvr03488fwchq7y95kk49w";
      };

      nativeBuildInputs = [ ocaml findlib ocamlbuild ];
      buildInputs = [ topkg ];
      propagatedBuildInputs = [ cmdliner ];

      strictDeps = true;
      buildPhase = topkg.buildPhase + " --with-cmdliner true";

      inherit (topkg) installPhase;
    };

  re = osuper.re.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = "https://github.com/ocaml/ocaml-re/releases/download/1.12.0/re-1.12.0.tbz";
      sha256 = "1m6ipbd4si87l3axc6m4qmmvzh9mbriyglyqmfmz9hkj5zr2n7x0";
    };
  });

  randomconv = osuper.randomconv.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = "https://github.com/hannesm/randomconv/releases/download/v0.2.0/randomconv-0.2.0.tbz";
      sha256 = "1sk3bdfz1nlqrivp8vy3slpbhqw858gc5zwjix3a8hg30zgiw5xk";
    };
  });

  reanalyze = buildDunePackage {
    pname = "reanalyze";
    version = "2.25.1";
    src = fetchFromGitHub {
      owner = "rescript-association";
      repo = "reanalyze";
      rev = "v2.25.1";
      hash = "sha256-cM39Gk4Ko7o/DyhrzgEHilobaB3h91Knltkcv2sglFw=";
    };

    nativeBuildInputs = [ cppo ];
  };

  reason = callPackage ./reason { };

  rtop = callPackage ./reason/rtop.nix { };

  react = osuper.react.overrideAttrs (o: {
    nativeBuildInputs = o.nativeBuildInputs ++ [ topkg ];
  });

  redemon = callPackage ./redemon { };
  redis = callPackage ./redis { };
  redis-lwt = callPackage ./redis/lwt.nix { };
  redis-sync = callPackage ./redis/sync.nix { };

  reenv = callPackage ./reenv { };

  resto-cohttp-server = osuper.resto-cohttp-server.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace src/server.ml --replace-fail \
        "wseq ic oc body" "wseq (ic.Cohttp_lwt_unix.Private.Input_channel.chan) oc body"

      substituteInPlace src/server.mli --replace-fail \
        "'d Lwt_io.channel" "Cohttp_lwt_unix.Private.Input_channel.t"
    '';
  });

  rfc7748 = osuper.rfc7748.overrideAttrs (o: {
    patches = [ ];
    src = fetchFromGitHub {
      owner = "burgerdev";
      repo = "ocaml-rfc7748";
      rev = "ed034213ff02cd55870ae1387e91deebc9838eb4";
      hash = "sha256-26w6YcjBgfe2Fz/Z0RvCdU0MR4MAxIk2HGQ0ri0rrqU=";
    };
    checkInputs = o.checkInputs ++ [ hex ];
  });

  rock = osuper.rock.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "ulrikstrid";
      repo = "opium";
      rev = "830f02fb5462619314153cbe7cedf25e49468648";
      sha256 = "sha256-nvSoLvgrlh/wc5IBN5ZHY/onjXFUFcIs+grQslhwe2w=";
    };
  });
  opium = osuper.opium.overrideAttrs (_: {
    patches = [ ./opium-status.patch ];
  });

  rope = osuper.rope.overrideAttrs (_: {
    patches = [ ];
    buildInputs = [ ];
    propagatedBuildInputs = [ benchmark ];
    postPatch = ''
      substituteInPlace "src/dune" --replace-fail "bytes" ""
    '';
  });

  routes = osuper.routes.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = "https://github.com/anuragsoni/routes/releases/download/2.0.0/routes-2.0.0.tbz";
      sha256 = "126nn0gbh12i7yf0qn01ryfp2qw0aj1xfk1vq42fa01biilrsqiv";
    };
  });

  saturn_lockfree = osuper.saturn_lockfree.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = "https://github.com/ocaml-multicore/saturn/releases/download/0.5.0/saturn-0.5.0.tbz";
      sha256 = "0f9y8kscj0g946sdqvyvpzcyy5ldrrv3hvrp9pc26gmrhz0b2sb6";
    };
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ multicore-magic backoff ];
  });

  saturn = osuper.saturn.overrideAttrs (o: {
    checkInputs =
      o.checkInputs
      ++ (if lib.versionOlder "5.0" ocaml.version then [ multicore-bench ] else [ ]);
  });

  semver = buildDunePackage {
    pname = "semver";
    version = "0.2.0";
    src = builtins.fetchurl {
      url = "https://github.com/rgrinberg/ocaml-semver/releases/download/0.2.1/semver-0.2.1.tbz";
      sha256 = "1f4qyrzh8y72k96dyh8l8m2sb2sl5bhny9ijxgnppr0yv99c6g0a";
    };
  };

  sendfile = callPackage ./sendfile { };

  shared-memory-ring = osuper.shared-memory-ring.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = "https://github.com/mirage/shared-memory-ring/releases/download/v3.2.1/shared-memory-ring-3.2.1.tbz";
      sha256 = "0cqqrwpmlb3mb1r2w9w7rrmni2q1ippa1kjn4vy4z8yhqfv6f9x9";
    };
  });

  sherlodoc = callPackage ./sherlodoc { };

  sodium = buildDunePackage {
    pname = "sodium";
    version = "0.8+ahrefs";
    src = fetchFromGitHub {
      owner = "ahrefs";
      repo = "ocaml-sodium";
      rev = "4c92a94a330f969bf4db7fb0ea07602d80c03b14";
      sha256 = "sha256-FRM8F4ID2GOs93Fmt8RLMiz4zbkVTsgqa9Gse6tYvVQ=";
    };
    patches = [ ./sodium-cc-patch.patch ];
    postPatch = ''
      substituteInPlace lib_gen/dune --replace-fail "ctypes)" "ctypes ctypes.stubs)"
      substituteInPlace lib_gen/dune --replace-fail "ctypes s" "ctypes ctypes.stubs s"
      substituteInPlace lib_gen/dune --replace-fail \
        "ocamlfind query ctypes ctypes.stubs" \
        "ocamlfind query ctypes"
    '';
    propagatedBuildInputs = [ ctypes libsodium ];
  };

  soundtouch = osuper.soundtouch.overrideAttrs (o: {
    NIX_CFLAGS_COMPILE = lib.optionalString stdenv.isDarwin "-I${lib.getDev libcxx}/include/c++/v1";
  });

  sourcemaps = buildDunePackage {
    pname = "sourcemaps";
    version = "n/a";
    src = fetchFromGitHub {
      owner = "flow";
      repo = "ocaml-sourcemaps";
      rev = "2bc7e6e";
      sha256 = "sha256-eyiK3bhUMswW9cwlKrSTErwseOp/Qn2rKcw4T5DtuOo=";
    };
    propagatedBuildInputs = [ vlq ];
  };

  srt = osuper.srt.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ ctypes-foreign ];
    postPatch = ''
      substituteInPlace "src/dune" "src/stubs/dune" --replace-fail \
        "ctypes.foreign" "ctypes-foreign"
    '';
  });

  ssl = (osuper.ssl.override { openssl = openssl-oc.dev; }).overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "savonet";
      repo = "ocaml-ssl";
      rev = "v0.7.0";
      hash = "sha256-gi80iwlKaI4TdAVnCyPG03qRWFa19DHdTrA0KMFBAc4=";
    };
    nativeCheckInputs = [ openssl-oc.bin ];
    buildInputs = o.buildInputs ++ [ dune-configurator ];
  });

  stdcompat = buildDunePackage {
    pname = "stdcompat";
    version = "19-dev";

    src = fetchFromGitHub {
      owner = "thierry-martinez";
      repo = "stdcompat";
      # https://github.com/thierry-martinez/stdcompat/pull/33
      rev = "58b6d90fc53333f5e8112d42f96093802678c030";
      hash = "sha256-7xfcCVOOMaZ5dwgTtSn0YAkZg9tdqvn1tNMqsIL4ZfA=";
    };

    dontConfigure = true;

    meta = {
      homepage = "https://github.com/thierry-martinez/stdcompat";
      license = lib.licenses.bsd2;
      maintainers = [ lib.maintainers.anmonteiro ];
    };
  };

  stdlib-random = buildDunePackage {
    pname = "stdlib-random";
    version = "1.1.0";
    src = builtins.fetchurl {
      url = "https://github.com/ocaml/stdlib-random/releases/download/1.1.0/stdlib-random-1.1.0.tbz";
      sha256 = "0n95h57z0d9hf1y5a3v7bbci303wl63jn20ymnb8n2v8zs1034wb";
    };
    nativeBuildInputs = [ cppo ];
    doCheck = ! lib.versionOlder "5.2" ocaml.version;
  };

  subscriptions-transport-ws = callPackage ./subscriptions-transport-ws { };

  syndic = buildDunePackage rec {
    pname = "syndic";
    version = "1.6.1";
    src = builtins.fetchurl {
      url = "https://github.com/Cumulus/${pname}/releases/download/v${version}/syndic-v${version}.tbz";
      sha256 = "1i43yqg0i304vpiy3sf6kvjpapkdm6spkf83mj9ql1d4f7jg6c58";
    };
    propagatedBuildInputs = [ xmlm uri ptime ];
  };

  taglib = osuper.taglib.overrideAttrs (o: {
    NIX_CFLAGS_COMPILE = lib.optionalString stdenv.isDarwin "-I${lib.getDev libcxx}/include/c++/v1";
  });

  tar = osuper.tar.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = "https://github.com/mirage/ocaml-tar/releases/download/v3.1.2/tar-3.1.2.tbz";
      sha256 = "18qnxlmh91cpibjg1c4ffiami1vbwjp2xr6gk15mjg8xlh497iw5";
    };
    propagatedBuildInputs = [ decompress ];
  });

  tar-mirage = buildDunePackage {
    pname = "tar-mirage";
    inherit (tar) version src;
    propagatedBuildInputs = [
      lwt
      mirage-block
      mirage-clock
      mirage-kv
      ptime
      tar
    ];
  };

  tcpip = osuper.tcpip.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = "https://github.com/mirage/mirage-tcpip/releases/download/v8.2.0/tcpip-8.2.0.tbz";
      sha256 = "1vfnnys2hqlw02g1sqxys7w3kmrsjvs2k0fv8k27cxl9pa56hvli";
    };
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ mirage-crypto-rng-mirage ];
    checkInputs = o.checkInputs ++ [ mirage-crypto-rng ohex ];
    doCheck = false;
  });

  textmate-language = buildDunePackage {
    pname = "textmate-language";
    version = "0.3.4";
    src = builtins.fetchurl {
      url = "https://github.com/alan-j-hu/ocaml-textmate-language/releases/download/0.3.4/textmate-language-0.3.4.tbz";
      sha256 = "17c540ddzqzl8c72rzpm3id6ixi91cq5r8dmjvf0kzj6kjdgrg63";
    };
    propagatedBuildInputs = [ oniguruma ];
  };

  timedesc = callPackage ./timere/timedesc.nix { };
  timedesc-json = callPackage ./timere/timedesc-json.nix { };
  timedesc-sexp = callPackage ./timere/timedesc-sexp.nix { };
  timedesc-tzdb = callPackage ./timere/timedesc-tzdb.nix { };
  timedesc-tzlocal = callPackage ./timere/timedesc-tzlocal.nix { };
  timere = callPackage ./timere/default.nix { };
  timere-parse = callPackage ./timere/parse.nix { };

  tls = osuper.tls.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = "https://github.com/mirleft/ocaml-tls/releases/download/v1.0.3/tls-1.0.3.tbz";
      sha256 = "0l317wzc4bsmcrhh5b2q3v4h4vbcgk2zqw2hlkljdshszif0szxj";

    };

    propagatedBuildInputs = [
      domain-name
      fmt
      logs
      ipaddr
      kdf
      mirage-crypto
      mirage-crypto-ec
      mirage-crypto-pk
      mirage-crypto-rng
      x509
    ];
  });

  torch = osuper.torch.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "torch";
      rev = "v0.17.0";
      hash = "sha256-zaCL0/8O/saoslTGfCQfiEaivjeDoS9ogJI1Hk8kj4M=";
    };
    patches = [ ];
    # postPatch = ''
    # substituteInPlace src/wrapper/dune --replace-fail "ctypes.foreign" "ctypes-foreign"
    # '';
    NIX_CFLAGS_COMPILE = lib.optionalString stdenv.isDarwin "-I${lib.getDev libcxx}/include/c++/v1";
    propagatedBuildInputs = [
      ppx_jane
      ppx_string
      ctypes
      core_unix
      ctypes-foreign
    ];
    # o.propagatedBuildInputs ++
    # [  ] ++
    # lib.optionals stdenv.isDarwin [ darwin.apple_sdk.frameworks.Accelerate ];
    doCheck = !stdenv.isDarwin;
    checkPhase = "dune runtest --profile=release";
  });

  trace = osuper.trace.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = "https://github.com/c-cube/ocaml-trace/releases/download/v0.8/trace-0.8.tbz";
      sha256 = "1hvq13kwgbai5y45w44w6l5vkvh5wqg17f0gdwj1w7315dkabkrl";
    };
    propagatedBuildInputs = [ mtime ];
  });

  tsdl = osuper.tsdl.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = "https://erratique.ch/software/tsdl/releases/tsdl-1.1.0.tbz";
      sha256 = "0fw78qby010ai8apgwc66ary6zm3a5nw57228i44vccypav3xpk4";
    };

    propagatedBuildInputs =
      o.propagatedBuildInputs
      ++ [ ctypes-foreign ]
      ++ lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
        Cocoa
        CoreAudio
        CoreVideo
        AudioToolbox
        ForceFeedback
      ]);
  });

  tuntap = osuper.tuntap.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = "https://github.com/mirage/ocaml-tuntap/releases/download/v2.0.1/tuntap-2.0.1.tbz";
      sha256 = "1p8c9j32vzy59yavsis1rsb8i86wyhn5wzxb1rl5ki1vrjbh3ii7";
    };
  });

  tyxml-jsx = callPackage ./tyxml/jsx.nix { };
  tyxml-ppx = callPackage ./tyxml/ppx.nix { };
  tyxml-syntax = callPackage ./tyxml/syntax.nix { };

  unix-errno = osuper.unix-errno.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "xapi-project";
      repo = "ocaml-unix-errno";
      rev = "a36eec0aa612141ababbc8131a489bc6df7094a8";
      hash = "sha256-8e5NR69LyHnNdbDA/18OOYCUtsJW0h3mZkgxiQ85/QI=";
    };
    propagatedBuildInputs = [ ctypes integers ];
  });

  uring = osuper.uring.overrideAttrs (_: {
    postPatch = ''
      patchShebangs vendor/liburing/configure
      substituteInPlace lib/uring/dune --replace-fail \
        '(run ./configure)' '(bash "./configure")'
    '';
  });

  utop = osuper.utop.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "ocaml-community";
      repo = "utop";
      rev = "c7bab9e66e8b82795b2026c46e593ed87cdfa43d";
      hash = "sha256-i8W4tnI8WMwDpWL37mjqqBd3FYr1C39AfzqvsHCxg9c=";
    };
  });

  uuidm = osuper.uuidm.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "dbuenzli";
      repo = "uuidm";
      rev = "v0.9.9";
      hash = "sha256-FyI90b/qHn25VZcALlN4lksduBPw8dXNfFpB5KR+/Pk=";
    };
  });

  uutf = osuper.uutf.overrideAttrs (_: {
    pname = "uutf";
    patches = if isFlambda2 then [ ./uutf-locals.patch ] else [ ];
  });

  vg = osuper.vg.overrideAttrs (_: {
    propagatedBuildInputs = [
      uchar
      gg
      uutf
      otfm
      js_of_ocaml
      js_of_ocaml-ppx
    ];
  });
  visitors = osuper.visitors.overrideAttrs (_: {
    propagatedBuildInputs = [ ppxlib ppx_deriving ];
    postPatch = ''
      substituteInPlace runtime/dune --replace-fail '(libraries result)' ""
      substituteInPlace src/dune --replace-fail '(libraries result' "(libraries "
    '';
  });

  vlq = buildDunePackage {
    pname = "vlq";
    version = "0.2.1";

    src = builtins.fetchurl {
      url = "https://github.com/flowtype/ocaml-vlq/releases/download/v0.2.1/vlq-v0.2.1.tbz";
      sha256 = "02wr9ph4q0nxmqgbc67ydf165hmrdv9b655krm2glc3ahb6larxi";
    };

    buildInputs = [ dune-configurator ];
    propagatedBuildInputs = [ camlp-streams ];
    postPatch = ''
      substituteInPlace "src/dune" --replace-fail \
        '(public_name vlq))' '(libraries camlp-streams)(public_name vlq))'
    '';
  };

  websocket = buildDunePackage {
    pname = "websocket";
    version = "2.16";
    src = builtins.fetchurl {
      url = "https://github.com/vbmithr/ocaml-websocket/releases/download/2.17/websocket-2.17.tbz";
      sha256 = "173sgbk0xdlanj08wjl615gvwf04c850nw6gbjvgababafsmxbrr";
    };
    propagatedBuildInputs = [
      cohttp
      astring
      base64
      ocplib-endian
      conduit
      mirage-crypto-rng
    ];
  };
  websocket-lwt-unix = buildDunePackage {
    pname = "websocket-lwt-unix";
    inherit (websocket) src version;
    propagatedBuildInputs = [ lwt websocket cohttp-lwt-unix lwt_log sexplib ];
    doCheck = true;

    postPatch = ''
      substituteInPlace lwt/websocket_lwt_unix.ml --replace-fail \
        "fun (flow, ic, oc) ->" \
        "fun (flow, ic, oc) -> let ic = (Cohttp_lwt_unix.Private.Input_channel.create ic) in" \
        --replace "Lwt_io.close ic" "Cohttp_lwt_unix.Private.Input_channel.close ic" \
        --replace "(fun flow ic oc ->" "(fun flow ic oc -> let ic = (Cohttp_lwt_unix.Private.Input_channel.create ic) in "
    '';

  };

  httpun-ws = callPackage ./httpun-ws { };
  httpun-ws-lwt = callPackage ./httpun-ws/lwt.nix { };
  httpun-ws-lwt-unix = callPackage ./httpun-ws/lwt-unix.nix { };
  httpun-ws-async = callPackage ./httpun-ws/async.nix { };
  httpun-ws-mirage = callPackage ./httpun-ws/mirage.nix { };

  ohex = buildDunePackage {
    pname = "ohex";
    version = "0.2.0";
    src = fetchFromGitHub {
      owner = "robur-coop";
      repo = "ohex";
      rev = "v0.2.0";
      hash = "sha256-9lg/IAkVuHFzk92IkuBjfJSwPUZ1AbLklxwFWMTbws8=";
    };
  };

  x509 = osuper.x509.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = "https://github.com/mirleft/ocaml-x509/releases/download/v1.0.4/x509-1.0.4.tbz";
      sha256 = "00p7ymc64an859gnzw4xbh67vnwmsl3rpyhbrd09s4ak7scd629y";
    };

    checkInputs = [ alcotest ];
    propagatedBuildInputs = [
      asn1-combinators
      domain-name
      fmt
      gmap
      mirage-crypto
      mirage-crypto-pk
      mirage-crypto-ec
      kdf
      logs
      ohex
      base64
      ipaddr
    ];
  });

  webauthn = buildDunePackage {
    pname = "webauthn";
    version = "0.2.0";
    src = fetchFromGitHub {
      owner = "robur-coop";
      repo = "webauthn";
      rev = "ea5fc357da2d6bf1f1a35cc89af26d281f5c6521";
      hash = "sha256-85Aoep+/qxr3qkRIte5QgyitvzDdGsPG4kR3xa0Gq4E=";
    };
    propagatedBuildInputs = [
      ppx_deriving_yojson
      cbor
      mirage-crypto-rng
      mirage-crypto-ec
      base64
      x509
    ];
  };

  xxhash = osuper.xxhash.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace lib/dune --replace-fail "ctypes.foreign" ""
      substituteInPlace stubs/dune --replace-fail "ctypes.foreign" ""
      substituteInPlace stubs/dune --replace-fail "libraries ctypes)" "libraries ctypes ctypes.stubs)"
    '';
  });

  yaml = osuper.yaml.overrideAttrs (_: {
    src = builtins.fetchurl {
      url = "https://github.com/avsm/ocaml-yaml/releases/download/v3.2.0/yaml-3.2.0.tbz";
      sha256 = "09w2l2inc0ymzd9l8gpx9pd4xlp5a4rn1qbi5dwndydr5352l3f5";
    };
  });

  yuscii = disableTests osuper.yuscii;

  zarith = (osuper.zarith.override { gmp = gmp-oc; });

  zed = osuper.zed.overrideAttrs (o: {
    propagatedBuildInputs = [ react uchar uutf uucp uuseg ];
    postPatch = ''
      substituteInPlace src/dune --replace-fail "result" ""
    '';
  });

  zstd = buildDunePackage {
    pname = "zstd";
    version = "0.4";
    src = builtins.fetchurl {
      url = "https://github.com/ygrek/ocaml-zstd/releases/download/v0.4/zstd-0.4.tbz";
      sha256 = "0481m7rfk21n1wxqnczbpfmqkh8qky9wgvs9pl24xscmw91qd5n1";
    };
    nativeBuildInputs = [ pkg-config ];
    propagatedBuildInputs = [ integers ctypes zstd-oc ];
    doCheck = true;
    checkInputs = [ extlib ];
  };
} // (if lib.versionAtLeast osuper.ocaml.version "5.1" then janeStreet_0_17 else janeStreet_0_16) // (
  if lib.hasPrefix "5." osuper.ocaml.version
  then
    (import ./ocaml5.nix {
      inherit
        oself osuper
        darwin stdenv overrideSDK
        fetchFromGitHub nodejs_latest nixpkgs;
    })
  else { }
) // (
  if # No version supported on 5.0
    (lib.versionAtLeast osuper.ocaml.version "4.14" && !(lib.versionAtLeast osuper.ocaml.version "5.0"))
    || lib.versionAtLeast osuper.ocaml.version "5.1"
  then (import ./melange-packages.nix { inherit oself fetchFromGitHub; })
  else { }
)
