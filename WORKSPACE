workspace(name = "org_pubref_rules_docker")

load(
    "//docker:rules.bzl",
    "docker_rootfs",
    "docker_rootfs_github_repository",
    "docker_rootfs_http_file",
)

docker_rootfs(
    name = "iron_go",
    dockerfile_content = "FROM iron/go", # Having trouble with go:dev due to tar issue
    #excludes = ["/usr/share/terminfo/*",],
)

docker_rootfs(
    name = "iron_java8",
    dockerfile_content = "FROM iron/java:1.8",
)

docker_rootfs(
    name = "scratch",
    dockerfile_content = "FROM scratch",
    verbose = 3,
)

docker_rootfs(
    name = "alpine",
    dockerfile_content = "FROM gliderlabs/alpine:3.4",
    verbose = 0,
    #excludes = ["*.rsa.pub"]
)

docker_rootfs_http_file(
    name = "alpine_edge",
    url = "https://github.com/gliderlabs/docker-alpine/raw/rootfs/gliderlabs-edge/versions/gliderlabs-edge/rootfs.tar.gz",
    # elide sha256 here since it changes frequently
    verbose = 1,
)

docker_rootfs_github_repository(
    name = "alpine_3_4",
    remote = "https://github.com/gliderlabs/docker-alpine",
    commit = "9f5e5e129febdfe4dd96a6162094655bd6c438b5",
    artifact = "versions/gliderlabs-3.4/rootfs.tar.gz",
    verbose = 1,
)

docker_rootfs_github_repository(
    name = "ubuntu_trusty",
    remote = "https://github.com/tianon/docker-brew-ubuntu-core",
    commit = "3485528d76452eff9e7d3b3f222bd21a966659a5",
    artifact = "trusty/ubuntu-trusty-core-cloudimg-amd64-root.tar.gz",
    verbose = 1,
)

docker_rootfs_github_repository(
    name = "debian_wheezy",
    remote = "https://github.com/tianon/docker-brew-debian",
    commit = "e9bafb113f432c48c7e86c616424cb4b2f2c7a51",
    artifact = "wheezy/rootfs.tar.xz",
    verbose = 1,
)
