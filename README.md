# YoDawger

Yo Dawg, i heard you like deploying things onto servers, but don't like not
being able to easily manage the data and services running on your server.
This is the tool for deploying services in a decentralized manner, allowing
you to easily plug components in and out of the service mesh by hand or by
script.

## Installation

Clone the repository onto your server at `/yodawg`

## Getting Started

First you will need a YoDawg compatible service.  Either use one of the
pre-assembled YoDawg services, or write your own:  See the
[Service Spec](SERVICE.md) for instructions.

## Design Outline

Services are a collecton of one or more dockerized processes which create a
socially useful deployed service.  Services can depend on, connect to, and
influence other services in their environment.  Environments allow socially
separated groups to deploy identical services to the same infrastructure
without interfering with other social groups operations.  Environments can
contain subenvironments whose resources are accessible from parent environments
while the children remain isolated from the parent and eachother.
