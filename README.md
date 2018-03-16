# Automated deploys for CKAN

Ansible roles for automating deploys and rollbacks for CKAN custom installations that need to manage several extensions on active development, and that need to be deployed into several environments.

## Summary

This set of roles and scripts provides a framework when working on custom developments of CKAN which involve setting up, developing and deploying several extensions. The main issues it tries to solve are:

* Deploying releases of several CKAN extensions in a *[capistrano](http://capistranorb.com)-like* way. Each of them coming from different origins:
  - Open source extensiones developed outisde your organization
  - Forked open source extensions adapted for our use case
  - Private extensions developed by your organization
* Ability to easily rollback a failed deploy
* Encapsulating Python packages dependencies for each of the deploys (we used virtualenv for this), avoiding possible conflicts when releasing a new version.
* Deploying some minor changes to the CKAN core we needed, without forking CKAN.
* Deploying to several environments (production and staging), without duplicating the tasks for each of this roles.

## Repository organization

The repository is organized as follows:

```bash
bin/
  # easy-to-run scripts for each action
  production_deploy.sh
  production_first_deploy.sh
  staging_deploy.sh
  staging_first_deploy.sh
sites/
  ckan/
    files/
    tasks/
      # tasks for cold deploy, deploy and rollback
      deploy.yml
      first_deploy.yml
      main.yml
      rollback.yml
    templates/
      # CKAN config file, parameterized for each environment
      ckan_config.ini.j2
    vars/
      # encrypted vaults for each environment
      production_secrets.yml
      secrets.yml.example
      staging_secrets.yml
ckan_production.yml
ckan_staging.yml
inventory.example
inventory
```

## Assumed setup

We assume you have installed CKAN following the official guide. In our case, we did it on a CentOS 7 machine, following [this guide](https://github.com/ckan/ckan/wiki/How-to-install-CKAN-2.x-on-CentOS-7).

We assume you have the following users in your server:

* `root`
* `apache`
* `ckan`

## Getting started

Clone the repo:

```bash
git clone https://github.com/populatetools/ckan-deploys
```

Copy `inventory.example` and edit it with your server IPs:

```bash
cd ckan-deploys
cp inventory.example inventory
vim inventory
```

Fill in the vault files inside `sites/ckan/vars` according to your own needs and encrypt them. You can copy the `secrets.yml.example` file to use it as a template:

```
cd sites/ckan/vars
cp secrets.yml.example production_secrets.yml
cp secrets.yml.example staging_secrets.yml
```

Edit the variables in `ckan_production.yml`, `ckan_staging.yml` and `sites/ckan/vars/ckan_config.yml` and give them the values that match your needs. Some of them are parameters for the CKAN config file `sites/ckan/templates/ckan_config.ini.j2`.

## How to's

### First deploy

The `first_deploy.yml` tasks prepare the default CKAN instalation to support the workflow of deploying releases. A summary of the steps is:

1. Creates the releases directory `/usr/lib/ckan/releases`.
2. Creates the symlink `/usr/lib/ckan/current` that now points to the default CKAN virtualenv, but that later will point to the current release.
3. Copies the CKAN configuration file inside the default virtualenv.
4. Modifies the `/etc/ckan/default/apache.wsgi` file to point to the `current` symlink, instead of `default`.
5. Sets the domain in the virtualhost file `ckan_default.conf`

After running `bin/production_first_deploy.sh` you should have a working CKAN application accessible via web, and prepare for the next deploys.

### Deploy

The `deploy.yml` tasks deploys a new release of CKAN, with the specified extensions and the changes performed in the CKAN configuration file. You can run it with `bin/production_deploy.sh` and a summary of its steps is:

1. Clones the default virtualenv into the releases directory, inside a timestamped directory (ex. ` /usr/lib/ckan/releases/20180316105723Z`).
2. Clones the specified extensions directory inside the release virutalenv, install the extensions in the virtualenv and their dependencies (presumed to be in a `requirements.txt` file).
3. Updates the release CKAN configuration file (ex. `.../20180316105723Z/production.ini`).
4. Changes the `current` symlink to point to the last release.
5. If the amount of kept releases was exceeded, removes the oldest release.

### Rollbacks

The rollback procedure can be run with `bin/production_rollback.sh`. A summary of the steps is the following:

1. Points the `current` symlink to the previous release.
2. Removes the broken release from `/usr/lib/ckan/releases`.

## Disclaimer

This repository contains an adaptation of the code we used. We've tested it but not extensively, and probably you'll need to adapt some parts of it to your own needs.

## Contact

This tools have been developed by [Populate](http://populate.tools), a studio which designs and builds products around civic engagement, data journalism and open data.
