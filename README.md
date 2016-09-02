# `rules_docker` (αlpha) [![Build Status](https://travis-ci.org/pubref/rules_docker.svg?branch=master)](https://travis-ci.org/pubref/rules_docker)

These are experimental pre-release rules for building deterministic
docker images with bazel.  Bazel provides some nice support for this,
but finding and building base images for the `docker_build` command is
a pain.

> You must have `docker` installed and available on your PATH, bazel
> won't download it for you at the moment.  Also seems to required
> bazel 0.3.1 or HEAD (fails with 0.3.0).

```python
```python
git_repository(
    name = "org_pubref_rules_docker",
    commit = "COMMIT_ID",
    remote = "https://github.com/pubref/rules_docker.git",
)
load("@org_pubref_rules_docker//docker:rules.bzl", "docker_repositories", "docker_export_base")
docker_repositories()

# Example: repository rule to generate a rootfs.tar from the busybox image.
# Base image becomes available at @busybox//:base
#
docker_export_base(
    name = "busybox",
    dockerfile_content = "FROM busybox",
)
```

Later, in a BUILD file:

```python
load("@org_pubref_rules_docker//docker:rules.bzl", "docker_build")

docker_build(
    name = "foo",
    base = "@busybox//:base",
    ...
)
```

Then generate and run a deterministic docker image with:

```sh
$ bazel run :foo gcr.io/example:busybox
$ docker run -it gcr.io/example:busybox sh
```

---

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
