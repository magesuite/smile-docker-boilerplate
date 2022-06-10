# Deployment

The deployment process depends on how your project is hosted on the production environment.

There are three possible situations with the production environment:

- Hosted on Magento cloud.
- Hosted on a docker architecture.
- Hosted on a "standard" server (no virtualization).

## Magento Cloud

The deployment process is documented in the official documentation:

- https://devdocs.magento.com/cloud/reference/discover-deploy.html
- https://devdocs.magento.com/cloud/deploy/cloud-deployment-process.html

A simple git push to the cloud repository triggers a new build on the environment that is associated to the git branch.

## Environments hosted on a docker architecture

There is nothing available yet, but we are currently creating helm charts.

## Environments hosted without Docker

If your production environment is hosted on a Linux server with SSH access, you can use [php deployer](https://deployer.org/) to manage the deployment process.

Please find below an example on how to implement PHP Deployer and set up aumomatic deployment with GitLab CI.

**Warning**: this example is a proof of concept.
It was not tested on a real production environment.
Expect a few bugs/issues, especially on the very first deployment (because the file app/etc/env.php will not exist yet on the remote environment).

### Deployment File

Create a file named "deploy.php" at the root of the magento directory.

Example contents of this file:

```php
<?php

namespace Deployer;

require 'recipe/magento2.php';

// Hosts
host('preprod')
    ->setHostname('preprod_hostname')
    ->setRemoteUser('myuser')
    ->setDeployPath('/var/www/myproject');

host('prod')
    ->setHostname('prod_hostname')
    ->setRemoteUser('myuser')
    ->setDeployPath('/var/www/myproject');

// Variables
set('static_content_locales', 'en_US');
add('magento_themes', []);
add('shared_files', []);
add('shared_dirs', []);
add('writable_dirs', []);

set('artifact_source_dir', '/tmp');
set('artifact_dest_dir', '/tmp');
set('artifact_name', sprintf('artifact-%s.tgz', date('YmdHis')));
set('artifact_exclude', [
    './.git',
    './*.dist',
    './*.md',
    './*.txt',
    './*.sample',
    './.editorconfig',
    './.gitignore',
    './.gitlab-ci.yml',
    './.smileanalyser.yaml',
    './.user.ini',
    './deploy.php',
    './grunt-config.json',
    './Gruntfile.js',
    './package.json',
]);

desc('Create an artifact file with the contents of the current directory');
task('artifact:create', function () {
    $artifact = get('artifact_source_dir') . '/' . get('artifact_name');
    $excludes = array_map(fn($value) => '--exclude=' . $value, get('artifact_exclude', []));
    $excludeOption = implode(' ', $excludes);
    runLocally("tar --xform s:'./':: $excludeOption -zcf $artifact ./");
})->hidden();

desc('Upload an artifact to the remote server');
task('artifact:upload', function () {
    $source = get('artifact_source_dir') . '/' . get('artifact_name');
    $dest = get('artifact_dest_dir') . '/' . get('artifact_name');
    upload($source, $dest);
    runLocally("rm -f $source");
})->hidden();

desc('Extract an artifact to the release path');
task ('artifact:unpack', function () {
    $artifact = get('artifact_dest_dir') . '/' . get('artifact_name');
    run("tar -xzf $artifact -C {{release_or_current_path}}");
    run("rm -f $artifact");
})->hidden();

desc('Create an artifact file locally and deploy it to the release path');
task('deploy:artifact', [
    'artifact:create',
    'artifact:upload',
    'artifact:unpack',
]);

// Create and upload an artifact file instead of using git
task('deploy:update_code')->disable();
after('deploy:update_code', 'deploy:artifact');

// Override deploy:info
task('deploy:info', function () {
    info("Deploying {{artifact_name}}");
});

after('deploy:failed', 'deploy:unlock');
```

Don't forget to replace the sample values defined in the host functions (hostname, remote user, deploy path).

Quick explanation of this configuration file:

- Uses the magento2 recipe.
- Creates and uploads an artifact to the remote host instead of using git.

To launch a deployment:

```
deployer deploy <host>
```

### Build Magento Locally

The magento2 recipe builds Magento on the remote host (composer install, setup:di:compile, setup:static-content:deploy).
To speed up the deployment process, we recommend building Magento on the local machine instead (GitLab CI if possible).

Example implementation (in deploy.php):

```php
desc('Build Magento locally');
task('build', function () {
    $themesToCompile = '';
    if (count(get('magento_themes')) > 0) {
        foreach (get('magento_themes') as $theme) {
            $themesToCompile .= ' -t ' . $theme;
        }
    }

    info('Building Magento locally');
    runLocally('composer install --no-interaction');
    runLocally('bin/magento setup:di:compile');
    runLocally("bin/magento setup:static-content:deploy -f --content-version={{content_version}} {{static_content_locales}} $themesToCompile -j {{static_content_jobs}}");
});

// Disable tasks that build Magento on the remote host (it is built locally instead with the "build" task)
task('deploy:vendors')->disable();
task('deploy:clear_paths')->disable();
task('magento:compile')->disable();
task('magento:deploy:assets')->disable();
```

The deployment process becomes the following:

1. Run `deployer build` to build Magento locally
2. Run `deployer deploy <host>` to deploy Magento to the remote host

### Automatic Deployment

Now that the deploy.php file is created, you can add a job in .gitlab-ci.yml that automates the deployment process.

First, GitLab CI must be able to connect to the remote hosts:

1. [Generate SSH keys](https://docs.gitlab.com/ee/user/ssh.html#generate-an-ssh-key-pair) with ssh-keygen (do not specify a passphrase).
2. Add the private key to a variable named "SSH_PRIVATE_KEY" in Settings > CI / DI > Variables.
3. Add the public key to the file ~/.ssh/authorized_keys on the remote hosts.

Then, you must add a deployment stage to the .gitlab-ci.yml file:

```yaml
.deploy: &deploy
    stage: deploy
    script:
        # Install deployer
        - curl -L -o /usr/local/bin/deployer https://github.com/deployphp/deployer/releases/download/v7.0.0-rc.8/deployer.phar
        - chmod +x /usr/local/bin/deployer
        # Add SSH key
        - apk add --no-cache bash openssh rsync
        - eval $(ssh-agent -s)
        - echo "$SSH_PRIVATE_KEY" | tr -d '\r' | ssh-add -
        - mkdir -p ~/.ssh && chmod 700 ~/.ssh
        - ssh-keyscan -t rsa $HOSTNAME >> ~/.ssh/known_hosts
        # Run deployer
        - deployer build
        - deployer deploy $ENV_NAME

deploy_preprod:
    variables:
        ENV_NAME: preprod
        HOSTNAME: preprod_hostname
    <<: *deploy
    only:
        refs:
            - tags
        variables:
            - $CI_COMMIT_TAG =~ /^preprod-*/

deploy_prod:
    variables:
        ENV_NAME: prod
        HOSTNAME: prod_hostname
    <<: *deploy
    only:
        refs:
            - tags
        variables:
            - $CI_COMMIT_TAG =~ /^prod-*/
```

Don't forget to replace the HOSTNAME value with the IP or domain of the servers.

When a tag is created with the pattern `preprod-*` or `prod-*`, this job will be automatically executed by the GitLab CI.

We recommend creating a custom image that already includes deployer and the ssh keys.
It will make the build process more reliable.

### Troubleshooting

If you get the following error during static content compilation:

> The default website isn't defined.

You need to include the list of websites, stores and groups to the file app/etc/config.php
(cf. https://devdocs.magento.com/guides/v2.4/config-guide/prod/config-reference-configphp.html#scopes).
