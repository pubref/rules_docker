BASH_TEMPLATE = """
#!/bin/bash
set -euf -o pipefail

ls -alF $(pwd)/examples

# Run it
("{docker_bin}" run --rm -v /Users/pcj/github/rules_docker:/rules_docker -v "{outdir}:/runfiles:rw" -t "{container}" /bin/bash -c '{command}' $@)
"""

def docker_run_impl(ctx):
    inputs = ctx.files.srcs + ctx.files.data
    docker_bin = "docker"
    container = ctx.attr.container
    command = ctx.attr.command

    outdir = str(ctx.configuration.bin_dir)
    print("outdir: %s" % outdir)
    #outdir = ctx.outputs.executable.path
    if outdir.endswith("[derived]"):
        outdir = outdir[:-len("[derived]")]
    #outdir += "/" + ctx.outputs.executable.dirname

    ctx.file_action(
        output = ctx.outputs.executable,
        executable = True,
        content = BASH_TEMPLATE.format(
            docker_bin = docker_bin,
            outdir = outdir,
            container = container,
            command = " ".join(command),
        ),
    )

    runfiles = ctx.runfiles(files = inputs, collect_data = True, collect_default = True)

    print("runfiles: %s" % runfiles.files)

    return struct(
        files = set(inputs),
        runfiles = runfiles,
    )

docker_run = rule(
    docker_run_impl,
    attrs = {
        "command": attr.string_list(
            mandatory = True,
        ),
        "srcs": attr.label_list(
            allow_files = True,
            cfg = "data",
        ),
        "data": attr.label_list(
            allow_files = True,
            cfg = "data",
        ),
        "container": attr.string(
            mandatory = True,
        ),
    },
    executable = True,
)
