# Pipeline Repo Template

This is a reference implementation of a repository for organizing code when automating pcf installations and upgrades. 

## Goals

### Avoid Storing Credentials

Credentials should never be stored in source control. Use concourse variables and parameterization to push credentials out to a configuration store like vault or credhub. 

### Break Codebase into intuitive regions

There are two logical subunits of a pipeline. The first is a task. The second is a pipeline. Tasks tend to be reusable while pipelines are situational. When possible push common code to tasks in the /tasks root folder. If a task is specific to a particular pipeline, you can push it to the /pipelines/pipeline-name/tasks folder. 

### Push common configuration up, push details down

Configuration that is shared across multiple pipelines should be pushed up in the repository. Configuration that is specific to a particular pipeline shoudld be pushed down. 

Distinction should be made between environments and for consistency and clarity, use folders over file renames. 

### Treat dependencies as read only

When consuming a dependency like an example repository, treat that dependency as read only. This will allow you to update the dependency when changes are made to it without dealing with a large merge. Git SubModules are one way to ensure that a dependency is tracked and versioned without needing to store the entire work tree of that dependency. 

## Architecture

The folder structure should be organized in a way that promotes reuse of tasks and treats dependencies as read only. For this purpose we have the following tree structure:

```.
├ dependencies
├ pipelines
└ tasks
```

* `dependencies` contains the submodules or subfolders of all consumed dependencies. 
* `pipelines` contains the list of all pipelines
* `tasks` contains the list of all tasks

### dependencies folder

> add a depenency 

```bash
git submodule add https://github.com/pivotal-cf/bbr-pcf-pipeline-tasks depenencies/github.com/pivotal-cf/bbr-pcf-pipeline-tasks
```

> restore a depenency after clone

```
git submodule update --init --recursive
```

> update a dependency version

```
# change into the submodule directory
cd depenencies/github.com/pivotal-cf/bbr-pcf-pipeline-tasks

# grab all changes
git fetch

# checkout the commit or tag
git checkout c7955a4
```

> remove a dependency

```
rm -rf depenencies/github.com/pivotal-cf/bbr-pcf-pipeline-tasks
git submodule deinit -f -- depenencies/github.com/pivotal-cf/bbr-pcf-pipeline-tasks
rm -rf .git/modules/depenencies/github.com/pivotal-cf/bbr-pcf-pipeline-tasks
git rm -rf depenencies/github.com/pivotal-cf/bbr-pcf-pipeline-tasks
```

### pipelines folder


#### pipelines originating from scratch

The pipelines folder contains a sub folder for each pipeline. The pipeline folder contains a `pipeline.yml` file that contains the pipeline yml for the pipeline. 

If any tasks are needed that are specific to that pipeline, they are stored in the tasks folder. Otherwise they are stored in the repo root tasks folder. 

An example pipelines folder could look like this:

```
.
└ backup
    ├ environments
    │   ├ dev
    │   │   └ params.yml
    │   ├ prod
    │   │   └ params.yml
    │   └ uat
    │       └ params.yml
    ├ params.yml
    ├ patches
    ├ pipeline.yml
    ├ regions
    │   ├ us-central
    │   │   ├ dev
    │   │   │   └ params.yml
    │   │   ├ params.yml
    │   │   ├ prod
    │   │   │   └ params.yml
    │   │   └ uat
    │   │       └ params.yml
    │   └ us-east
    │       ├ dev
    │       │   └ params.yml
    │       ├ params.yml
    │       ├ prod
    │       │   └ params.yml
    │       └ uat
    │           └ params.yml
    └ set-pipeline.sh
```

#### Pipeline originating in a depenency

If a pipeline originates in a depenency, use a tool like yml patch to bring in the pipeline from source and use operations files to modify the pipeline as desired. 

In this situation, you wouldn't need a pipeline.yml file because you would be brining it in from a depenency. 

```
fly -t concourse \
  set-pipeline \
  -p backup-pipeline \
  -c <( cat $DIR/../depenencies/github.com/pivotal-cf/examples/pas-pipeline.yml \
        | yaml_patch -o $DIR/patches/minio.yml)
```
