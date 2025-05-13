# Iris-Hydra Charts changelog

## Versions

## [1.0.1]
### Changed
- Configured K8s Jobs to generate JWKs with the ES256 algorithm 
    - A separate Job is created for each realm 
    - Jobs can be enabled by setting the `job.jwk.enabled` flag to `true` in the `values.yaml` file
    - Jobs access Iris-Hydra admin endpoint directly 

## [1.0.0] - Iris-Hydra init version