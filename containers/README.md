# Building containers

Here is the place to develop and build containers with Contrail components.

## Quickstart
* get Ubuntu 16 or Centos 7 with internet connection
* get the project sources (e.g. with *git clone*)
* run *setup-for-build.sh*
* re-login to renew user permissions
* run *build.sh*

At the result you get Docker registry run on 5000 port on the machine, which registry contains built Contrail containers.

## Environment for building
The building requires
* package repository with Contrail and some 3rd party packages,
* docker to build containers,
* docker registry where to store build result.

To configure the result of *setup-for-build.sh* set appropriate variables in the file common.env in the root project folder. The most valuable variable is CONTRAIL_VERSION, which default value is 4.0.1.0-32. For other variables see info below and common.env.sample.

### Repository
CONTRAIL_VERSION of common.env defines the version of Contrail (and some 3rd party) packages to be uploaded onto the repository. The repository listens on 80 port, which is not configurable.

You may also run *install-repository.sh* separately having custom CONTRAIL_VERSION environment varable specified.

### Docker
