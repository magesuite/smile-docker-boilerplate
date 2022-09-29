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

The deployment entirely depends on the docker architecture used on the production environment.

Smile is currently developing helm charts, but their main use will be for integration environments hosted on https://rancher.smile.fr.
Once available, these helm charts will be documented here:
https://wiki.smile.fr/wiki/Magento_Helm_Charts

## Environments hosted without Docker

If your production environment is hosted on a Linux server with SSH access, you can use [php deployer](https://deployer.org/) to manage the deployment process.

The following wiki page explains how to set up this deployment process:
https://wiki.smile.fr/wiki/Deploying_Magento_to_On-Premise_Server
