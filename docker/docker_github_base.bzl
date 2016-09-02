def _impl(ctx):

    path = ctx.attr.path
    user = ctx.attr.user
    repo = ctx.attr.repo
    commit = ctx.attr.commit

    url = "%s/%s/%s/%s/%s" % (
        ctx.attr.github_url_prefix,
        user,
        repo,
        ctx.attr.github_archive_type,
        commit
    )

    if ctx.attr.verbose:
        #print("Downloading zip file from GitHub: %s..." % url)
        ctx.download_and_extract(url, ".", ctx.attr.sha256, ctx.attr.github_archive_type, "")

    # The zip archive from github unpacks to REPO-COMMIT/
    unzippeddir = repo + "-" + commit
    archive = unzippeddir + "/" + path
    basename = path.rsplit('/', 1)[1]
    rootname = basename
    extract_tool = "gunzip" # Most common default

    if basename.endswith(".tar.gz"):
        extract_tool = "gunzip"
        rootname = basename[:-len(".tar.gz")]

    elif basename.endswith(".tgz"):
        extract_tool = "gunzip"
        rootname = basename[:-len(".tgz")]

    elif basename.endswith(".tar.xz"):
        extract_tool = "unxz"
        rootname = basename[:-len(".tar.xz")]

    elif basename.endswith(".txz"):
        extract_tool = "unxz"
        rootname = basename[:-len(".txz")]

    elif basename.endswith(".tlz"):
        extract_tool = "unxz"
        rootname = basename[:-len(".tlz")]

    tarname = rootname + ".tar"
    rootfsname = ctx.name + "_rootfs.tar"

    # Setting overrides autodetected
    if ctx.attr.extract_tool:
        extract_tool = ctx.attr.extract_tool

    # If the path to the rootfs file contains a 'BUILD' or 'build' file,
    # bazel will refuse to work within it, so move the archive file to
    # the output_base so we don't have to look inside dirs and deal with
    # conflicting package problems.
    cmd = ["mv", archive, basename]
    if ctx.attr.verbose:
        #print("Moving rootfs archive to external base directory: %s" % cmd)
        ctx.execute(cmd)

    # Now unpack the rootfs.tar.gz or similar file.  This would all be
    # easier if the ctx.execute did shell redirection better...
    cmd = [extract_tool, basename]
    if ctx.attr.verbose:
        #print("Extract rootfs archive: %s" % cmd)
        ctx.execute(cmd)

    # Normalize the name of the tarball for the BUILD file.
    cmd = ["mv", tarname, rootfsname]
    if ctx.attr.verbose:
        #print("Normalize rootfs tarball name: %s" % cmd)
        ctx.execute(cmd)

    # Write the BUILD file.
    ctx.template("BUILD", ctx.attr.build_file_template, {
        "URL": url,
        "NAME": ctx.name,
        "USER": user,
        "TAR_FILE": rootfsname,
        "PATH": path,
        "COMMIT": commit,
        "REPO": repo,
    })


docker_github_base = repository_rule(
  implementation = _impl,
  local = True,
  attrs = {
    "user": attr.string(mandatory = True),
    "repo": attr.string(mandatory = True),
    "commit": attr.string(mandatory = True),
    "path": attr.string(mandatory = True),
    "type": attr.string(),
    "sha256": attr.string(),
    "github_url_prefix": attr.string(
      default = "https://codeload.github.com",
    ),
    "github_archive_type": attr.string(
      default = "zip",
    ),
    "build_file_template": attr.label(
      default = Label("//docker:docker_github_base.BUILD.tpl"),
    ),
    "extract_tool": attr.string(),
    "verbose": attr.int(default = 0),
  }
)
