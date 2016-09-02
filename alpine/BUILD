package(default_visibility = ["//visibility:public"])

load("//docker:rules.bzl", "docker_build")

docker_build(
    name = "3_4",
    base = "@alpine_3_4//:base",
)

docker_build(
    name = "edge",
    base = "@alpine_edge//:base",
)

docker_build(
    name = "alpine",
    base = "@alpine//:base",
)

docker_build(
    name = "java8",
    base = "@iron_java8//:base",
)

docker_build(
    name = "go",
    base = "@iron_go//:base",
)
