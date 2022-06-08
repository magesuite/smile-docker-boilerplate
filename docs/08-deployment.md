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

### Configuration

Create a file named "deploy.php" at the root of the magento directory.

Example contents of this file:

```php
<?php

namespace Deployer;

require 'contrib/rsync.php';
require 'recipe/magento2.php';

// Config
set('rsync_src', __DIR__);
set('rsync',[
    'exclude' => [
        '.git',
        'deploy.php',
    ],
    'exclude-file' => false,
    'include' => [],
    'include-file' => false,
    'filter' => [],
    'filter-file'  => false,
    'filter-perdir'=> false,
    'flags' => 'rz', // Recursive, with compress
    'options' => ['delete'],
    'timeout' => 60,
]);

add('shared_files', []);
add('shared_dirs', []);
add('writable_dirs', []);

// Hosts
host('preprod-host')
    ->set('remote_user', 'myuser')
    ->set('deploy_path', '/var/www/myproject');

host('prod-host')
    ->set('remote_user', 'myuser')
    ->set('deploy_path', '/var/www/myproject');

// Rsync the source code to the remote host
after('deploy:update_code', 'rsync');

// Disable tasks that pull and compile the code on the remote host (the code is already compiled and sent via rsync)
task('deploy:update_code')->disable();
task('deploy:vendors')->disable();
task('deploy:clear_paths')->disable();
task('magento:compile')->disable();
task('magento:deploy:assets')->disable();

after('deploy:failed', 'deploy:unlock');
```

Don't forget to replace the sample values defined in the host functions (hostname, remote user, deploy path).

Quick explanation of this configuration file:

- Uses the magento2 recipe.
- Disables the tasks that pull/compile the code on the remote host.
- Adds a rsync mechanism that sends the code to the remote host.

The rsync will be done by the GitLab CI (cf. automatic deployment below).

### Automatic Deployment

Now that the deploy.php file is created, you can add a job in .gitlab-ci.yml that automates the deployment process.

First, GitLab CI must be able to connect to the remote hosts:

- Generate a private key (e.g. with`ssh-add`).
- Add a variable named "SSH_PRIVATE_KEY" in Settings > CI / DI > Variables, with the private key as its value.
- Add the private key to the authorized_keys file on the remote hosts.

Then, you must add a deployment stage to the .gitlab-ci.yml file:

```yaml
.deploy: &deploy
    stage: deploy
    script:
        - curl -L -o /usr/local/bin/deployer https://github.com/deployphp/deployer/releases/download/v7.0.0-rc.8/deployer.phar
        - chmod +x /usr/local/bin/deployer
        - apk add --no-cache bash openssh rsync
        - composer install --no-dev --prefer-dist --optimize-autoloader --no-interaction
        - bin/magento setup:di:compile
        - bin/magento setup:static-content:deploy -f -t Magento/luma -j 1 en_US
        - deployer deploy $HOSTNAME

deploy_preprod:
    variables:
        HOSTNAME: preprod-host
    <<: *deploy
    only:
        refs:
            - tags
        variables:
            - $CI_COMMIT_TAG =~ /^preprod-*/

deploy_prod:
    variables:
        HOSTNAME: prod-host
    <<: *deploy
    only:
        refs:
            - tags
        variables:
            - $CI_COMMIT_TAG =~ /^prod-*/
```

Replace "preprod-host" and "prod-host" in the HOSTNAME variable by the real server hostnames.

When a tag is created with the pattern `preprod-*` or `prod-*`, this job will be automatically executed by the GitLab CI.
It will run the following steps:

- Pull an image with PHP preinstalled.
- Add composer and deployer to the image.
- Run composer install.
- Compile Magento.
- Run deployer.

**WARNING** - don't blindly copy/paste these examples:

- They were not tested on a real production environment.
  There might be a few issues with them.
- Make sure that you understand the contents of the deployer config file and the gitlab-ci.yml file.
  You might need to change some things according to the requirements of your project.
