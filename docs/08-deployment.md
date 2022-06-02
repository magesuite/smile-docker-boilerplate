# Deployment

The deployment process depends on how your project is hosted on the production environment.

There are three possible situations with the production environment:

- Hosted on Magento cloud.
- Hosted on a "standard" server (no virtualization).
- Hosted on a docker architecture

## Magento Cloud

The deployment process is documented in the official documentation:

- https://devdocs.magento.com/cloud/reference/discover-deploy.html
- https://devdocs.magento.com/cloud/deploy/cloud-deployment-process.html

A simple git push to the cloud repository triggers a new build on the environment that is associated to the git branch.

## Environments hosted on Linux servers

You have two options to deploy your code to the production environment:

- Use [php deployer](https://deployer.org/). This tool is bundled with a Magento 2 recipe.
- Create a small and simple ansible playbook that uses the [deploy helper module](https://docs.ansible.com/ansible/latest/collections/community/general/deploy_helper_module.html) to deploy an artifact to the server.

If you need to create an artifact file that contains the source code of your application, there are also multiple ways to do that:

- Create a docker image based on [scratch](https://hub.docker.com/_/scratch/) that contains the source code to deploy, then zip it with the [docker save](https://docs.docker.com/engine/reference/commandline/save/) command.
  You can also include additional commands in the Dockerfile, such as DI generation.
- Add [spbuilder](https://git.smile.fr/dirtech/spbuilder) to your project and use it to create the zip file (cf. [project packaging](https://git.smile.fr/dirtech/spbuilder/-/blob/master/Resources/doc/packaging.md)).

## Environments hosted on a docker architecture

There is nothing available yet, but we are currently creating helm charts.
