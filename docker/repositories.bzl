# ****************************************************************
# Master list of external dependencies
# ****************************************************************

REPOSITORIES = {

    "gliderlabs_alpine_3_4": {
        "kind": "docker_github_base",
        "name": "gliderlabs_alpine_3_4",
        "user": "gliderlabs",
        "repo": "docker-alpine",
        "commit": "9f5e5e129febdfe4dd96a6162094655bd6c438b5",
        "path": "versions/gliderlabs-3.4/rootfs.tar.gz",
        "verbose": 1,
    },

    "openjdk_7_jre_headless": {
        "kind": "http_file",
        "name": "openjdk_7_jre_headless",
        "url": "http://security.debian.org/debian-security/pool/updates/main/o/openjdk-7/openjdk-7-jre-headless_7u111-2.6.7-1~deb7u1_amd64.deb",
        "sha256": "7c611a3a9d4dbac4f3fdc570728ed97938234545f2ba5f6b6aea4d8628151a03",
        #"url": "http://security.debian.org/debian-security/pool/updates/main/o/openjdk-7/openjdk-7-jre-headless_7u79-2.5.5-1~deb7u1_amd64.deb",
        #"sha256": "b632f0864450161d475c012dcfcc37a1243d9ebf7ff9d6292150955616d71c23",
    },

}
