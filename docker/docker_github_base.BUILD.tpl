# Do not edit! Automatically generated BUILD file.
#
# GitHub User: USER
# Repo: REPO
# Commit: COMMIT
# Zipfile Source URL: URL
#
load("@bazel_tools//tools/build_defs/docker:docker.bzl", "docker_build")

docker_build(
    name = "base",
    tars = ["TAR_FILE"],
    visibility = ["//visibility:public"],
)
