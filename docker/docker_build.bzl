load("@bazel_tools//tools/build_defs/docker:docker.bzl", bazel_docker_build = "docker_build")

def docker_build(incremental_load_template = "//docker:incremental_load.sh.tpl", **kwargs):
  """Macro to substitute alternate incremental load file (default one fails on osx)"""
  bazel_docker_build(incremental_load_template = incremental_load_template, **kwargs)
