package(default_visibility = ["//visibility:public"])

load("//docker:rules.bzl", "docker_run")

docker_run(
    name = "python-version",
    container = "xenial-bazel",
    command = [
        "ls",
        "-alF",
        #"/usr/bin/python",
        #"-V",
    ],
)

docker_run(
    name = "tf",
    container = "tensorflow/tensorflow:latest",
    srcs = [
        "hello.py",
    ],
    command = [
        "pwd",
        #"&&", "find", "/runfiles",
        #"&&", "ls -alF", "/github/rules_docker",
        #"&&", "ls", "-alF", "/runfiles/bazel-out/local-fastbuild/bin/examples/tf/",
        "&&", "python", "-V",
        "&&", "python", "/rules_docker/examples/hello.py",
        #"&&", "python", "/runfiles/examples/hello.py",
        "&&", "ls", "-alF", "/runfiles",
        "&&", "ls", "-alF", "/runfiles/examples",
    ],
)
