{{/*
Expand the name of the chart.
*/}}
{{- define "nexus-operator.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "nexus-operator.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "nexus-operator.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "nexus-operator.metaLabels" -}}
mdtu-ddm.projects.epam.com/operator-name: {{ template "nexus-operator.name" . }}
mdtu-ddm.projects.epam.com/operator-version: {{ .Values.operator.image.version | quote }}
{{- end -}}

{{- define "nexus-operator.selectorLabels" -}}
mdtu-ddm.projects.epam.com/operator-name: {{ template "nexus-operator.name" . }}
{{- end -}}

{{- define "imageRegistry" -}}
{{- if .Values.global.imageRegistry -}}
{{- printf "%s/" .Values.global.imageRegistry -}}
{{- end -}}
{{- end }}

{{- define "nexus-operator.image" -}}
{{- printf "%s%s:%s" (include "imageRegistry" .) .Values.operator.image.name .Values.operator.image.version -}}
{{- end -}}

{{- define "nexus.image.name" -}}
{{- printf "%s%s" (include "imageRegistry" .) .Values.nexus.image.name -}}
{{- end -}}

{{- define "nexus.storageClass" -}}
{{- if .Values.global -}}
  {{- if .Values.global.storageClass -}}
    {{- .Values.global.storageClass -}}
  {{- else -}}
    {{- .Values.nexus.storage.class -}}
  {{- end -}}
{{- else -}}
  {{- .Values.nexus.storage.class -}}
{{- end -}}
{{- end -}}

{{- define "edp.hostnameSuffix" -}}
{{- printf "%s-%s.%s" .Values.cdPipelineName .Values.cdPipelineStageName .Values.dnsWildcard }}
{{- end }}

{{- define "nexus.hostname" -}}
{{- $hostname := printf "%s-%s" "nexus" .Values.edpProject }}
{{- printf "%s-%s" $hostname (include "edp.hostnameSuffix" .) }}
{{- end }}

{{- define "nexus.url" -}}
{{- printf "%s%s" "https://" (include "nexus.hostname" .) }}
{{- end }}

{{- define "keycloak.realm" -}}
{{- printf "%s-%s" .Release.Namespace .Values.keycloakIntegration.realm }}
{{- end -}}

{{- define "nexus.edpMavenRepoUrl" -}}
{{- if .Values.nexus.edpMavenRepoUrl -}}
{{- .Values.nexus.edpMavenRepoUrl -}}
{{- else -}}
http://nexus.{{ .Values.edpProject }}.svc:8081/repository/edp-maven-group/
{{- end -}}
{{- end -}}

{{- define "admin-routes.whitelist.cidr" -}}
{{- if .Values.global }}
{{- if .Values.global.whiteListIP }}
{{- .Values.global.whiteListIP.adminRoutes }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "admin-routes.whitelist.annotation" -}}
haproxy.router.openshift.io/ip_whitelist: {{ (include "admin-routes.whitelist.cidr" . | default "0.0.0.0/0") | quote }}
{{- end -}}
