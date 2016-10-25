package(default_visibility = ["//visibility:public"])

load(":rules.bzl", "docker_build")


exports_files([
    "incremental_load.sh.tpl",
    "sleep",
])

docker_build(
    name = "scratch",
    base = "@scratch//:base",
)
