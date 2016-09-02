##############################################################################
# Utilities
##############################################################################

tar_filetype = [".tar", ".tar.gz", ".tgz", ".tar.xz"]

def _execute(ctx, cmd):
    result = ctx.execute(cmd)
    if result.return_code:
        fail("%s failed: %s" % (" ".join(cmd), result.stderr))
    if ctx.attr.verbose > 1:
        print("Success: %s" % cmd)
    return result


def _write_build_file(ctx, tarfile):
    ctx.file("BUILD",
"""# DO NOT EDIT: automatically generated BUILD file for %s rule
#load("//docker:rules.bzl", "docker_build")
load("@bazel_tools//tools/build_defs/docker:docker.bzl", "docker_build")
docker_build(
    name = "base",
    tars = ["%s"],
    visibility = ["//visibility:public"],
)
""" % (ctx.name, tarfile))


##############################################################################
# Implementations
##############################################################################

def _docker_rootfs_impl(ctx):

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

    tar = ctx.attr.tar
    if not ctx.which(tar):
        fail("tar not found: %s" % tar)

    excludes = []
    for e in ctx.attr.excludes + ["__sleep__"]:
        excludes += ["--exclude", e]

    # if ctx.attr.excludes_from_content:
    #     ctx.file("EXCLUDE", ctx.attr.excludes_from_content)
    #     excludes += ["--exclude-from", "EXCLUDE"]

    # Filter tarfile to rootfs.tar.  This is stupid, but I can't seem
    # to find a more elegant way to filter that works on both osx and
    # linux, gnutar and bsdtar.
    _execute(ctx, ["mkdir", "tmp"])
    _execute(ctx, [tar, "-xf", tarfile] + excludes + ["-C", "tmp"])

    _execute(ctx, [tar] + excludes + ["-cf", "rootfs.tar", "-C", "tmp", "."])

    # Get rootfs size
    tarsize = _execute(ctx, ["du", "-h", "rootfs.tar"]).stdout.strip().split("\t")[0]
    _execute(ctx, ["gzip", "rootfs.tar"])
    gzsize = _execute(ctx, ["du", "-h", "rootfs.tar.gz"]).stdout.strip().split("\t")[0]

    # Cleanup
    _execute(ctx, ["rm", "-rf", tarfile, "__sleep__", "tmp"])
    _execute(ctx, ["docker", "rm", container_id])
    #_execute(ctx, ["docker", "rmi", "--force", image_id]) # Delete this or leave it?

    # Restore original for posterity
    if (ctx.attr.dockerfile):
        ctx.template("Dockerfile", ctx.attr.dockerfile, ctx.attr.substitutions)
    elif ctx.attr.dockerfile_content:
        ctx.file("Dockerfile", ctx.attr.dockerfile_content)

    _write_build_file(ctx, "rootfs.tar.gz")

    if ctx.attr.verbose > 1:
        print("rootfs.tar manifest:\n%s" % _execute(ctx, [tar, "tvf", "rootfs.tar.gz"]).stdout)
    if ctx.attr.verbose:
        print("rootfs @%s//:base (%s, %s gzipped) from image %s" % (ctx.name, tarsize, gzsize, image_id))


def _docker_rootfs_http_file_impl(ctx):
    url = ctx.attr.url
    parts = url.split("/")
    filename = parts[-1]
    ctx.download(url, filename, ctx.attr.sha256, False)
    _write_build_file(ctx, filename)

    if ctx.attr.verbose:
        filesize = _execute(ctx, ["du", "-h", filename]).stdout.strip().split("\t")[0]
        print("rootfs @%s//:base (%s) from %s" % (ctx.name, filesize, url))


def _docker_rootfs_github_repository_impl(ctx):

    remote = ctx.attr.remote
    parts = remote.partition('github.com/')
    if not parts:
        fail("Remote must point to a github repository: %s" % remote)

    github_id = parts[2]
    if github_id.endswith(".git"):
        github_id = github_id[:-len(".git")]

    components = github_id.split('/')
    user = components[0]
    repo = components[1]

    prefix = ctx.attr.download_prefix
    commit = ctx.attr.commit
    artifact = ctx.attr.artifact
    commit = ctx.attr.commit
    archive_type = ctx.attr.archive_type
    sha256 = ctx.attr.sha256

    url = "/".join([prefix, user, repo, archive_type, commit])
    strip_prefix = ""
    tmp = "tmp"
    _execute(ctx, ["mkdir", tmp])

    ctx.download_and_extract(url, tmp, sha256, archive_type, strip_prefix)

    # The zip archive from github unpacks to REPO-COMMIT/.  Can't just
    # use the artifact path directly as there can be BUILD or build
    # files in the way, making bazel think it's a package (flips table).
    extract_dir = "-".join([repo, commit])
    artifact_file = "/".join([extract_dir, artifact])
    rootfs_file = artifact_file.rsplit('/', 1)[1]

    _execute(ctx, ["cp", tmp + "/" + artifact_file, rootfs_file])
    _execute(ctx, ["rm", "-rf", tmp])

    _write_build_file(ctx, rootfs_file)

    if ctx.attr.verbose:
        filesize = _execute(ctx, ["du", "-h", rootfs_file]).stdout.strip().split("\t")[0]
        print("rootfs @%s//:base (%s) from %s" % (ctx.name, filesize, url))


##############################################################################
# Rules
##############################################################################

docker_rootfs = repository_rule(
  implementation = _docker_rootfs_impl,
  attrs = {
    # Path to docker
    "docker": attr.string(default = "docker"),
    # Dockerfile (this or dockerfile_content must be defined)
    "dockerfile": attr.label(single_file = True),
    # Dockerfile to build
    "dockerfile_content": attr.string(),
    # Optional substitutions if desired
    "substitutions": attr.string_dict(),
    # Optional tar --exclude args for final rootfs.tar
    "excludes": attr.string_list(),
    # Optional tar --exclude args for final rootfs.tar
    #"exclude_from_content": attr.string(),
    # Expected sha256
    "sha256": attr.string(),
    # Optional Build args
    "build_args": attr.string_list(),
    # docker build PATH
    "path": attr.string(default = "."),
    # sleep binary
    "sleep": attr.label(single_file = True, default = Label("//docker:sleep")),
    # tar utility
    "tar": attr.string(default = "tar"),
    "verbose": attr.int(),
  }
)

docker_rootfs_http_file = repository_rule(
  implementation = _docker_rootfs_http_file_impl,
  attrs = {
    "url": attr.string(mandatory = True),
    "sha256": attr.string(),
    "verbose": attr.int(),
  }
)

docker_rootfs_github_repository = repository_rule(

  implementation = _docker_rootfs_github_repository_impl,
  attrs = {
    # The artifact url
    "remote": attr.string(mandatory = True),
    # Commit (not tag) required for now
    "commit": attr.string(mandatory = True),
    # Path to the rootfs.tar artifact
    "artifact": attr.string(mandatory = True),
    # Expected sha256
    "sha256": attr.string(),
    # github download prefix
    "download_prefix": attr.string(default = "https://codeload.github.com"),
    # The archive format to download
    "archive_type": attr.string(default = "zip"),
    "verbose": attr.int(),
  }
)
