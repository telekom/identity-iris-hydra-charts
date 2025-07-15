<!---
# SPDX-FileCopyrightText: 2025 Deutsche Telekom AG
#
# SPDX-License-Identifier: Apache-2.0
-->

# Iris-Hydra Helm Chart

This Helm chart deploys [Iris-Hydra](https://github.com/telekom/identity-iris-hydra), a fork of ORY Hydra, supporting multiple realms, advanced configuration, and optional sidecar/token hook containers.

---

## Table of Contents

- [Introduction](#introduction)
- [Features](#features)
- [Parameters](#parameters)
  - [Realm](#realm)
  - [Component](#component)
  - [Deployment](#deployment)
  - [Service](#service)
  - [Ingress](#ingress)
  - [Job](#job)
  - [Global](#global)
- [Usage](#usage)
- [Examples](#examples)
- [References](#references)

---

## Introduction

This chart supports deploying multiple Iris-Hydra realms, each with its own configuration.  
You can enable a token hook container to customize JWT token claims, and an auth sidecar container to secure the Hydra admin interface with OAuth2.

A **Realm** is an isolated and independent Hydra instance, having its own:

- Hydra admin interface
- OAuth2 endpoints
- OAuth2 clients
- OAuth2 JWK keys
- Number of Kubernetes pods and CPU/memory resources (realms can be scaled independently)

Realms share:

- Database
- Hydra configuration

Each realm results in a corresponding:

- Kubernetes Deployment
- Kubernetes Service
- Kubernetes Horizontal Pod Autoscaler (if enabled)

---

## Features

- **Multi-realm support:** Deploy multiple isolated Hydra instances in a single cluster.
- **Customizable scaling:** Each realm can be scaled independently (HPA or fixed replicas).
- **Advanced configuration:** Fine-grained control over Hydra, sidecar, and token hook settings.
- **Optional containers:** Easily enable/disable sidecar and token hook containers.
- **Secure admin interface:** Protect Hydra admin endpoints with OAuth2 via sidecar.
- **Automated jobs:** Janitor and JWKS management jobs included.
- **Flexible ingress:** Keycloak-compatible endpoints and custom ingress rules.

---

## Parameters

### Realm

Define one or more realms, each with its own configuration.

| Parameter | Description |
|-----------|-------------|
| `realm` | Map of realm names to realm configuration. |
| `realm.<realm>.nid` | Network ID for the realm (UUID). |
| `realm.<realm>.autoscaling.enabled` | Enable autoscaling for this realm. |
| `realm.<realm>.autoscaling.minReplicas` | Minimum number of replicas for autoscaling. |
| `realm.<realm>.autoscaling.maxReplicas` | Maximum number of replicas for autoscaling. |
| `realm.<realm>.autoscaling.targetMemoryUtilizationPercentage` | Target memory utilization percentage for autoscaling. |
| `realm.<realm>.autoscaling.targetMemoryAverageValue` | Target average memory value for autoscaling. |
| `realm.<realm>.autoscaling.targetCPUUtilizationPercentage` | Target CPU utilization percentage for autoscaling. |
| `realm.<realm>.autoscaling.targetCPUAverageValue` | Target average CPU value for autoscaling. |
| `realm.<realm>.replicaCount` | Number of replicas (if autoscaling is disabled). |
| `realm.<realm>.resources` | Resource requests and limits for the deployment. |
| `realm.<realm>.db.options` | List of DB options (key/value pairs). |

---

### Component

#### Hydra

| Parameter | Description |
|-----------|-------------|
| `component.hydra.image.repository` | Hydra image repository. |
| `component.hydra.image.pullPolicy` | Image pull policy. |
| `component.hydra.image.tag` | Hydra image tag. |
| `component.hydra.autoMigrate` | Run DB migration job on install/upgrade. |
| `component.hydra.dev` | Enable Hydra dev mode. |
| `component.hydra.config` | Hydra configuration object. |
| `component.hydra.config.urls.self.issuer` | JWT Token Issuer URL for this deployment. |
| `component.hydra.config.log.level` | Log level. |
| `component.hydra.config.log.format` | Log format. |
| `component.hydra.config.log.leak_sensitive_values` | Log sensitive values. |
| `component.hydra.config.dsn` | Database DSN. |
| `component.hydra.config.serve.public.port` | Public port. |
| `component.hydra.config.serve.admin.port` | Port for the Hydra admin interface. |
| `component.hydra.config.serve.tls.allow_termination_from` | List of CIDRs allowed for TLS termination. |
| `component.hydra.config.secrets.system` | System secret. |
| `component.hydra.config.strategies.access_token` | Access token strategy. |
| `component.hydra.config.ttl.access_token` | Access token TTL. |
| `component.hydra.config.ttl.refresh_token` | Refresh token TTL. |
| `component.hydra.config.ttl.id_token` | ID token TTL. |
| `component.hydra.config.oauth2.token_hook.url` | Token hook URL. |
| `component.hydra.config.oauth2.hashers.bcrypt.cost` | Bcrypt cost for password hashing. |
| `component.hydra.config.oauth2.session.encrypt_at_rest` | Encrypt session at rest. |
| `component.hydra.config.oauth2.allowed_top_level_claims` | List of allowed top-level claims. |
| `component.hydra.config.oauth2.mirror_top_level_claims` | Mirror top-level claims. |

#### Tracing

| Parameter | Description |
|-----------|-------------|
| `component.hydra.tracing.enabled` | Enable tracing. |
| `component.hydra.tracing.provider` | Tracing provider (e.g., zipkin). |
| `component.hydra.tracing.samplingRatio` | Tracing sampling ratio. |
| `component.hydra.tracing.spanUrl` | Tracing span URL. |
| `component.hydra.tracing.url` | Tracing admin URL. |

#### Token Hook

| Parameter | Description |
|-----------|-------------|
| `component.tokenHook.enabled` | Enable token hook container. |
| `component.tokenHook.image.repository` | Token hook image repository. |
| `component.tokenHook.image.pullPolicy` | Token hook image pull policy. |
| `component.tokenHook.image.tag` | Token hook image tag. |
| `component.tokenHook.config.customClaims.originStargate` | Custom claim for originStargate. |
| `component.tokenHook.config.customClaims.originZone` | Custom claim for originZone. |
| `component.tokenHook.config.debug` | Enable debug for token hook. |

#### Auth Sidecar

| Parameter | Description |
|-----------|-------------|
| `component.sidecar.enabled` | Enable auth sidecar container. |
| `component.sidecar.image.repository` | Sidecar image repository. |
| `component.sidecar.image.pullPolicy` | Sidecar image pull policy. |
| `component.sidecar.image.tag` | Sidecar image tag. |
| `component.sidecar.config.trustedIssuer` | Trusted issuer for sidecar. |
| `component.sidecar.config.jwkPath` | JWK path for sidecar. |
| `component.sidecar.config.basicAuthUsername` | Basic auth username for admin. |
| `component.sidecar.config.basicAuthPassword` | Basic auth password for admin. |

---

### Deployment

| Parameter | Description |
|-----------|-------------|
| `deployment.securityContext.pod` | Pod-level security context. |
| `deployment.securityContext.container` | Container-level security context. |
| `deployment.pdb.enabled` | Enable PodDisruptionBudget. |
| `deployment.pdb.minAvailable` | Minimum available pods for PDB. |
| `deployment.labels` | Additional deployment labels. |
| `deployment.annotations` | Additional deployment annotations. |
| `deployment.nodeSelector` | Node selector for pods. |
| `deployment.tolerations` | Tolerations for pods. |
| `deployment.serviceAccount.create` | Create service account. |
| `deployment.serviceAccount.annotations` | Service account annotations. |
| `deployment.serviceAccount.name` | Service account name. |
| `deployment.extraVolumes` | Extra volumes for pods. |
| `deployment.extraVolumeMounts` | Extra volume mounts for containers. |
| `deployment.livenessProbe` | Liveness probe configuration. |
| `deployment.readinessProbe` | Readiness probe configuration. |
| `deployment.startupProbe` | Startup probe configuration. |
| `deployment.preStopSleepTime` | Pre-stop sleep time (seconds). |
| `deployment.automountServiceAccountToken` | Automount service account token. |
| `deployment.extraContainers` | Additional containers to add to the pod. |

---

### Service

| Parameter | Description |
|-----------|-------------|
| `service.public.enabled` | Enable public service. |
| `service.public.type` | Public service type (e.g., ClusterIP). |
| `service.public.port` | Public service port. |
| `service.public.name` | Public service port name. |
| `service.public.annotations` | Public service annotations. |
| `service.public.labels` | Public service labels. |
| `service.admin.enabled` | Enable admin service. |
| `service.admin.isDirectAccess` | Enable direct access to admin. |
| `service.admin.type` | Admin service type. |
| `service.admin.port` | Admin service port. |
| `service.admin.name` | Admin service port name. |
| `service.admin.annotations` | Admin service annotations. |
| `service.admin.labels` | Admin service labels. |
| `service.sidecar.enabled` | Enable sidecar service. |
| `service.sidecar.name` | Sidecar service name. |
| `service.sidecar.port` | Sidecar service port. |
| `service.tokenHook.enabled` | Enable token hook service. |
| `service.tokenHook.port` | Token hook service port. |

---

### Ingress

| Parameter | Description |
|-----------|-------------|
| `ingress.host` | Ingress host. |
| `ingress.tls` | Enable ingress TLS. |
| `ingress.admin` | Enable admin ingress. |
| `ingress.public` | Enable public ingress. |
| `ingress.className` | Ingress class name. |
| `ingress.keycloakUrls` | Add keycloak-like ingress rules. |
| `ingress.annotations` | Ingress annotations. |

---

### Job

| Parameter | Description |
|-----------|-------------|
| `job.janitor.schedule` | Janitor cron schedule. |
| `job.janitor.labels` | Janitor job labels. |
| `job.jwk.enabled` | Enable JWKS job. |

---

### Global

| Parameter | Description |
|-----------|-------------|
| `global.imagePullSecrets` | Image pull secrets for all pods. |

---

## Usage

To install the chart with your custom values:

```sh
helm install my-iris-hydra ./identity-iris-hydra-charts -f my-values.yaml
```

To upgrade:

```sh
helm upgrade my-iris-hydra ./identity-iris-hydra-charts -f my-values.yaml
```

To uninstall:

```sh
helm uninstall my-iris-hydra
```

---

## Examples

### Minimal Example

```yaml
realm:
  default:
    nid: "36c99b75-99ce-4b45-b507-e2e345da1071"
    autoscaling:
      enabled: true
      minReplicas: 2
      maxReplicas: 5
    resources:
      requests:
        cpu: 100m
        memory: 64Mi
      limits:
        cpu: 200m
        memory: 128Mi
component:
  hydra:
    config:
      dsn: "memory"
```

### Enabling Sidecar and Token Hook

```yaml
component:
  sidecar:
    enabled: true
    config:
      basicAuthUsername: admin
      basicAuthPassword: secret
  tokenHook:
    enabled: true
    config:
      customClaims:
        originStargate: https://example.com
        originZone: zone1
```

---

## References

- [Iris-Hydra](https://github.com/telekom/identity-iris-hydra)
- [Iris-Hydra Tokenhook](https://github.com/telekom/identity-iris-hydra-tokenhook)
- [ORY Hydra](https://www.ory.sh/hydra/)
- See [`values.yaml`](./values.yaml) for all configuration options and structure.
