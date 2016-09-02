# rules_docker

These are experimental pre-release rules for building deterministic
docker images with bazel.  Bazel provides some nice support for this,
but finding and building base images for the `docker_build` command is
a pain.

# docker_github_base

Repository rule to download and install a rootfs.tar from a github
repository.

# docker_export_base

Repository rule to prepare a rootfs.tar file via the docker export
command.

# docker_build

Macro that calls the `@bazel_tools//tools/docker/docker_build.bzl`
rule with an alternative `incremental_load.sh.tpl` template file (due
to bugfix in osx).

# docker_repositories

Repository rule to load dependencies for these rules.  Put this in
your WORKSPACE.
