# `rules_docker` (αlpha) [![Build Status](https://travis-ci.org/pubref/rules_docker.svg?branch=master)](https://travis-ci.org/pubref/rules_docker)

These are repository rules for building deterministic base docker
images with bazel.  Bazel provides fantastic support for this with the
[docker_build](https://bazel.io/docs/be/docker.html) rule.  This function removes timestamps and other
non-deterministic data in order to repeatably build docker images
based on content alone.

In practice however, using the `docker_build` rule is challenging as
one is expected to build images based on vendoring of layers via `deb`
archives.  This makes it hard to use distros that use different
packaging systems such as Alpine Linux.

The idea with these rules is that you construct a root filesystem
based on a Dockerfile instructions and then layer on your build
artifacts.

| Rule | Description |
| ---: | ---- |
| `docker_rootfs` | Repository rule that provides a rootfs from the `docker export` command. |
| `docker_rootfs_http_file` | Repository rule that provides a rootfs from a file fetched via http. |
| `docker_rootfs_github_repository` | Repository rule that provides a rootfs from a github repository. |
| `docker_build` | Package macro that calls the `@bazel_tools//tools/docker/docker_build.bzl` rule with an alternative `incremental_load.sh.tpl` template file. See [#1651](https://github.com/bazelbuild/bazel/issues/1651) |

> You must have `docker` running, bazel won't download/install it for
> you at the moment.  Requires bazel 0.3.1 or HEAD is required (fails
> with 0.3.0).

## Step 1: Add rules_docker to your workspace

```python
git_repository(
    name = "org_pubref_rules_docker",
    commit = "COMMIT_ID",
    remote = "https://github.com/pubref/rules_docker.git",
)
load("@org_pubref_rules_docker//docker:rules.bzl",
     "docker_rootfs",
     # "docker_rootfs_http_file",
     # "docker_rootfs_github_repository",
)
```

## Step 2: Add `docker_rootfs` rules to your workspace as needed

Example repository rule to generate a rootfs.tar from the busybox
image.  The image becomes available at `@busybox//:base`.

```python
docker_rootfs(
    name = "busybox",
    dockerfile_content = "FROM busybox",
)
```

## Step 3: Use these as `base` inputs for subsequent layers.

```python
load("@org_pubref_rules_docker//docker:rules.bzl", "docker_build")

docker_build(
    name = "foo",
    base = "@busybox//:base",
    ...
)
```

## Step 4: Load/run it in docker

Generate and run a deterministic docker image with:

```sh
$ bazel run :foo gcr.io/example:busybox
$ docker run -it gcr.io/example:busybox sh
```

---

## Provided BUILD Targets

One can also directly use the targets provided by this workspace:

```sh
$  bazel query //... --output label_kind
docker_build  rule  //alpine:3_4
docker_build  rule  //alpine:alpine
docker_build  rule  //alpine:edge
docker_build  rule  //alpine:go
docker_build  rule  //alpine:java8
docker_build  rule  //debian:wheezy
docker_build  rule  //docker:scratch
docker_build  rule  //ubuntu:trusty
```

## Additional Links

* Blog Post: https://bazel.io/blog/2015/07/28/docker_build.html
* Source: https://github.com/bazelbuild/bazel/blob/master/tools/build_defs/docker/docker.bzl
* Issue #1058 for docker_pull rule: https://github.com/bazelbuild/bazel/issues/1058
