# Yodawg Tenants

Yodawg Tenants segregate deployed resources between users and organizations
sharing the same physical computer hardware.

## Overview

A tenant consists of a tenant host user, with a home directory structured to 
allow easy assessment of services, socket pipelines, and linked environments.
The tenant home is an overlayfs of the host tenant template, guarunteeing core
tenant files are up to date at all times.  All of the processes in the tenant
are managed by a supervisor; all service processes are also supervised by a
rootless docker daemon run by the tenant user.

 - [ ] Tenant home directory overlay of host tenant template
 - [ ] Tenant users run tenant supervisor over tenant home direvtory
 - [ ] Tenant supervisor supervises rootless docker daemon
 - [ ] Tenant PID namespaced
 - [ ] Tenant chroot namespaced

Tenant services and their data are captured in the tenant services/ directory
where a sub-supervisor supervises all service runs.  Each service directory
contains a complete run definition for the service.  See 
[Services](./services.md)

 - [ ] Services sub-supervisor supervises services
 - [ ] All services disabled by default

All host services are overlay mounted into each tenant to ensure a consistent
baseline for service deployments on a host, while leaving flexibility to tenant
administrators to modify runtimes as they may wish.

 - [ ] Host service definitions overlay mounted into tenant

Host script libraries are bind mounted into the tenant libs directory to ensure
accessibilty and consistency across tenants.

 - [ ] host script libraries bind mounted into tenants

Tenant pipelines and their data are captured in the tenant pipelines/ directory
where a sub-supervisor supervises all the pipeline runs.  Pipelines are
small processes which listen on a named unix socket and perform a service or
bridge a connection to another service, pipeline, host, or otherwise. See
[Pipelines](./pipelines.md)

 - [ ] Pipelines sub-supervisor supervises pipelines

Each tenant has configurations which fine tune how services and resources are
deployed and managed within the tenant.  Each configuration is a file named the
config key, and containing the config value.  Configurations are easily looked
up in scripts using the config library

 - [ ] Config library allows defining of tenant configs

