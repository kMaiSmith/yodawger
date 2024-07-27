# Yodawg Services

Yodawg services are sets of scripts and configuraitons which make up a
dockerized process and it's supporting pipelines and configuraitons.

## Overview

Services runtimes are made up of process components, which can be:

 - Docker containers
 - Exec's into existing docker containers
 - Pipeline processes; see [Pipelines](./pipelines.md)

The service environment is configured by the main supervisor for the service.
All data and configs for the service are bundled in the service directory to
ensure easy management.  Service scripts utilize tenant and host script
libraries.  Service configurations for the tenant are stored as files named the
config key containing the config value, mirroring the tenant and host config
scheme.
