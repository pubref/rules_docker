workspace(name = "org_pubref_rules_docker")

load("//docker:rules.bzl", "docker_repositories", "docker_export_base")

docker_repositories(
    requires = [
        "gliderlabs_alpine_3_4",
        #"openjdk_7_jre_headless",
    ]
)

docker_export_base(
    name = "gliderlabs_alpine_3_4_exported",
    dockerfile_content = "FROM gliderlabs/alpine:3.4",
    verbose = 2,
)

docker_export_base(
    name = "iron_go",
    dockerfile_content = "FROM iron/go:dev",
)

docker_export_base(
    name = "iron_java8",
    dockerfile_content = "FROM iron/java:1.8",
)

docker_export_base(
    name = "scratch",
    dockerfile_content = "FROM scratch",
)
