
---

# docker_stack

## Variables available to override

with their default values:

### Required

```yaml
# Container name
DOCKER_STACK_NAME: stack
# Container image
DOCKER_STACK_IMAGE: alpine/alpine:latest
```

### Optional

```yaml
# Container capabilities; https://man7.org/linux/man-pages/man7/capabilities.7.html
DOCKER_STACK_CAPABILITIES: []
# Container environment variables
DOCKER_STACK_ENVIRONMENT: {}
# Container network definition and use
DOCKER_STACK_NETWORKS_ATTACH: []
DOCKER_STACK_NETWORKS_DEFINE: {}
# Container port maps
DOCKER_STACK_PORTS: []
# Container restart policy
DOCKER_STACK_RESTART_POLICY: unless-stopped
# Container volume mounts
DOCKER_STACK_VOLUMES: []
```

## Example Use

The following could be used to deploy a `pihole` instance with custom:
  - timezone inside the container
  - a local volume mount for the configuration directory

`roles/pihole/meta/main.yaml`

```yaml
---
dependencies:
  - role: docker_stack
    vars:
      DOCKER_STACK_NAME: pihole
      DOCKER_STACK_IMAGE: pihole/pihole:latest
      DOCKER_STACK_ENVIRONMENT:
        TZ: 'US/Pacific'
      DOCKER_STACK_VOLUMES:
        - './etc:/etc/pihole'
```
