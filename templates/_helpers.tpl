{{/* SPDX-FileCopyrightText: 2025 Deutsche Telekom AG

 SPDX-License-Identifier: Apache-2.0*/}}
{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "iris.name" -}}
{{- default .Release.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "iris.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- if .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "iris.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{/*
Define release name with chart version.
*/}}
{{- define "iris.release" -}}
{{- printf "%s-%s" .Release.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{/*
Ensure there is always a way to track down source of the deployment.
It is unlikely AppVersion will be missing, but we will fallback on the
chart's version in that case.
*/}}
{{- define "iris.version" -}}
{{- if .Chart.AppVersion }}
{{- .Chart.AppVersion -}}
{{- else -}}
{{- printf "v%s" .Chart.Version -}}
{{- end -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "iris.labels" -}}
"app.kubernetes.io/name": {{ include "iris.name" . | quote }}
"app.kubernetes.io/instance": {{ .Release.Name | quote }}
"app.kubernetes.io/version": {{ include "iris.version" . | quote }}
"app.kubernetes.io/managed-by": {{ .Release.Service | quote }}
"helm.sh/chart": {{ include "iris.release" . | quote }}
{{- end -}}

{{/*
Generate the dsn value
*/}}
{{- define "iris.dsn" -}}
{{- if .Values.demo -}}
memory
{{- else if .Values.component.hydra.config.dsn -}}
{{- .Values.component.hydra.config.dsn }}
{{- end -}}
{{- end -}}

{{/*
Generate the configmap data, redacting secrets
*/}}
{{- define "iris.configmap" -}}
{{- $config := unset .Values.component.hydra.config "dsn" -}}
{{- $config := unset $config "secrets" -}}
{{- toYaml $config -}}
{{- end -}}

{{/*
Generate the urls.issuer value
*/}}
{{- define "iris.config.urls.issuer" -}}
{{- if .Values.component.hydra.config.urls.self.issuer -}}
{{- .Values.component.hydra.config.urls.self.issuer }}
{{- else if .Values.ingress.public.enabled -}}
{{- $host := index .Values.ingress.public.hosts 0 -}}
http{{ if $.Values.ingress.public.tls }}s{{ end }}://{{ $host.host }}
{{- else if contains "ClusterIP" .Values.service.public.type -}}
http://127.0.0.1:{{ .Values.service.public.port }}/
{{- end -}}
{{- end -}}

{{/*
Check overrides consistency
*/}}
{{- define "iris.check.override.consistency" -}}
{{- if and .Values.maester.enabled .Values.fullnameOverride -}}
{{- if not .Values.maester.irisFullnameOverride -}}
{{ fail "iris fullname has been overridden, but the new value has not been provided to maester. Set maester.irisFullnameOverride" }}
{{- else if not (eq .Values.maester.irisFullnameOverride .Values.fullnameOverride) -}}
{{ fail (tpl "iris fullname has been overridden, but a different value was provided to maester. {{ .Values.maester.irisFullnameOverride }} different of {{ .Values.fullnameOverride }}" . ) }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "iris.utils.joinListWithComma" -}}
{{- $local := dict "first" true -}}
{{- range $k, $v := . -}}{{- if not $local.first -}},{{- end -}}{{- $v -}}{{- $_ := set $local "first" false -}}{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "iris.serviceAccountName" -}}
{{- if .Values.deployment.serviceAccount.create }}
{{- default (include "iris.fullname" .) .Values.deployment.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.deployment.serviceAccount.name }}
{{- end }}
{{- end -}}

{{- define "imageRef" -}}
{{- $image := . -}}
{{ $image.repository }}:{{ $image.tag }}
{{- end -}}
