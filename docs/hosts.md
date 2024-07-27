# Yodawger Hosts

Yodawger hosts act as the base platform for deploying and managing networked
services and resources.

## Overview

The host is the natural root of all deployments.  The hosts resources are
segregated into tenants, which are owned and operated by the consuming users
and organization of the server platform. See [Tenants](./tenants.md).

 - [ ] Host Resource Socket submits requests for new host tenants
 - [ ] Script to approve pending requests
 - [ ] New requeests spawn notification

A special "host" tenant is created when the host is initialized to house
services and resources which are shared with the consuming tenants to maximize
the shared utility of a host.  The host exposes socket endpoints to the tenants
which allow limited manipulation of the host resources.  For example, the host
ingress controller will expose a socket to the tenant which allows that tenant
to create ingress routes for the domain registered to the tenant, and to
tenant http sockets

 - [ ] Host initialization script creates host tenant

The host exposes lower ports in the 0-1024 range to services on the host tenant
by root processes.

 - [ ] Host Resource Socket submits requests to expose ports to services

Tenants can have peer tenants to enable users and organizations to isolate,
link and manage their own complex resources deployments.

 - [ ] Host peers with other hosts
 - [ ] Peering creates encrypted tunnel network between hosts

Hosts peer with other hosts to create networks of host resources which tenants
can consume.  Tenant administrators can explore the networked host resources
and request new tenants on peered hosts to link

 - [ ] Peering creates sockets to neighboring host resource sockets over tunnel

Persisted configuraitons are stored in the yodawger config sub directory as
files named the config key containing the config values.  These configs are
accessible via a library interface

 - [ ] Host configs stored in /yodawg/conf directory
 - [ ] Config library can look up host config values

