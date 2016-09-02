load("//docker:rules.bzl", "docker_build")

docker_build(
    name = "github",
    base = "@gliderlabs_alpine_3_4//:base",
)

docker_build(
    name = "export",
    base = "@gliderlabs_alpine_3_4_exported//:base",
)

docker_build(
    name = "scratch",
    base = "@scratch//:base",
    repository = "test",
)
