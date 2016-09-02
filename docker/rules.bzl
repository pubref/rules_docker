load("//docker:util.bzl", require = "require")
load("//docker:repositories.bzl", "REPOSITORIES")
load("//docker:docker_github_base.bzl", "docker_github_base")
load("//docker:docker_export_base.bzl", "docker_export_base")
load("//docker:docker_build.bzl", "docker_build")

def docker_repositories(
    verbose = 0,
    overrides = {},
    requires = []):

  repos = {}
  for k, v in REPOSITORIES.items():
    over = overrides.get(k)
    if over:
      repos[k] = v + over
    else:
      repos[k] = v

  context = struct(
    repos = repos,
    verbose = verbose,
    options = {},
  )

  for target in requires:
    require(target, context)
