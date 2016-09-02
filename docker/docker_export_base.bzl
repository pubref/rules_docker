def _execute(ctx, cmd):
    result = ctx.execute(cmd)
    if result.return_code:
        fail("%s failed: %s" % (" ".join(cmd), result.stderr))
    print("Success: %s" % cmd)
    return result

def _impl(ctx):
    #print("pwd %s:" % ctx.execute(["pwd"]).stdout)

    docker = ctx.attr.docker
    if not ctx.which(docker):
        fail("docker not found: %s" % docker)

    # Step 1b: Since we need to start a container and cannot know what
    # a valid entrypoint will be, add an instruction to add sleep to
    # the docker image.  After we extract the flattened image, we'll
    # remove this back out.
    sleep = ctx.path(ctx.attr.sleep)
    result = _execute(ctx, ["cp", sleep, "__sleep__"])
    copy = "COPY __sleep__ __sleep__"

    # Step 1: Prepare Dockerfile
    if (ctx.attr.dockerfile):
        ctx.template("Dockerfile", ctx.attr.dockerfile, ctx.attr.substitutions)
        _execute(ctx, ["awk", 'BEGIN { print "%s" }' % copy, ">>", "Dockerfile"])
    elif ctx.attr.dockerfile_content:
        ctx.file("Dockerfile", ctx.attr.dockerfile_content + "\n" + copy)

    else:
        fail("Either 'dockerfile' or 'dockerfile_content' must be defined.")

    result = _execute(ctx, ["cat", "Dockerfile"])
    #print("Dockerfile content: \n" + result.stdout)
    # Step 2: build image
    cmd = [docker, "build", "--file", "Dockerfile"]
    cmd += ctx.attr.build_args
    cmd += [ctx.attr.path]
    result = _execute(ctx, cmd)

    # 'Successfully built eeae34df12d9'
    image_id = result.stdout.strip().split(" ").pop()

    #print("IMAGE_ID: %s" % image_id)

    # Step 2a: start a container
    timeout = 600
    cmd = [docker, "run", "--detach", image_id, "/__sleep__", "600"]
    #cmd = [docker, "run", "--detach", image_id, "/dev/zero"]
    result = _execute(ctx, cmd)

    # "CONTAINER_ID"
    container_id = result.stdout.strip()
    #print("CONTAINER_ID: %s" % container_id)

    # Export container filesystem
    tarfile = "%s.tar" % image_id
    result = _execute(ctx, [docker, "export", "-o", tarfile, container_id])

    # Stop container
    _execute(ctx, [docker, "stop", container_id])

    # Remove our sleep file
    #_execute(ctx, ["tar", "--delete", "__sleep__"])

    # Write the BUILD file.
    ctx.file("BUILD",
"""
load("@bazel_tools//tools/build_defs/docker:docker.bzl", "docker_build")
docker_build(
    name = "base",
    tars = ["%s"],
    visibility = ["//visibility:public"],
)
""" % tarfile)

docker_export_base = repository_rule(
  implementation = _impl,
  attrs = {
    # Path to docker
    "docker": attr.string(default = "docker"),
    # Dockerfile (this or dockerfile_content must be defined)
    "dockerfile": attr.label(single_file = True),
    # Dockerfile to build
    "dockerfile_content": attr.string(),
    # Optional substitutions if desired
    "substitutions": attr.string_dict(),
    # Expected sha256 (make mandatory?)
    "sha256": attr.string(),
    # Optional Build args
    "build_args": attr.string_list(),
    # docker build PATH
    "path": attr.string(default = "."),
    # sleep binary
    "sleep": attr.label(single_file = True, default = Label("//docker:sleep")),
    # sha256 utility
    "_sha256": attr.label(
        default=Label("@bazel_tools//tools/build_defs/docker:sha256"),
        cfg=HOST_CFG,
        executable=True,
        allow_files=True,
    ),
  }
)
