{{/*
Expand the name of the chart.
*/}}
{{- define "langsmith.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "langsmith.fullname" -}}
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
{{- define "langsmith.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "langsmith.labels" -}}
{{- if .Values.commonLabels }}
{{ toYaml .Values.commonLabels }}
{{- end }}
helm.sh/chart: {{ include "langsmith.chart" . }}
{{ include "langsmith.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Common annotations
*/}}
{{- define "langsmith.annotations" -}}
{{- if .Values.commonAnnotations }}
{{ toYaml .Values.commonAnnotations }}
{{- end }}
helm.sh/chart: {{ include "langsmith.chart" . }}
{{ include "langsmith.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "langsmith.selectorLabels" -}}
app.kubernetes.io/name: {{ include "langsmith.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Name of the secret containing the secrets for this chart. This can be overriden by a secrets file created by
the user or some other secret provisioning mechanism
*/}}
{{- define "langsmith.secretsName" -}}
{{- if .Values.config.existingSecretName }}
{{- .Values.config.existingSecretName }}
{{- else }}
{{- include "langsmith.fullname" . }}-secrets
{{- end }}
{{- end }}

{{/*
Name of the secret containing the secrets for postgres. This can be overriden by a secrets file created by
the user or some other secret provisioning mechanism
*/}}
{{- define "langsmith.postgresSecretsName" -}}
{{- if .Values.postgres.external.existingSecretName }}
{{- .Values.postgres.external.existingSecretName }}
{{- else }}
{{- include "langsmith.fullname" . }}-postgres
{{- end }}
{{- end }}

{{/*
Name of the secret containing the secrets for postgres. This can be overriden by a secrets file created by
the user or some other secret provisioning mechanism
*/}}
{{- define "langsmith.redisSecretsName" -}}
{{- if .Values.redis.external.existingSecretName }}
{{- .Values.redis.external.existingSecretName }}
{{- else }}
{{- include "langsmith.fullname" . }}-redis
{{- end }}
{{- end }}

{{/*
Template containing common environment variables that are used by several services.
*/}}
{{- define "langsmith.commonEnv" -}}
- name: POSTGRES_DATABASE_URI
  valueFrom:
    secretKeyRef:
      name: {{ include "langsmith.postgresSecretsName" . }}
      key: connection_url
{{- with.Values.postgres.external.schema }}
- name: POSTGRES_SCHEMA
  value: {{ . }}
{{- end }}
- name: REDIS_DATABASE_URI
  valueFrom:
    secretKeyRef:
      name: {{ include "langsmith.redisSecretsName" . }}
      key: connection_url
- name: LOG_LEVEL
  value: debug
{{- if .Values.config.oauth.enabled }}
- name: OAUTH_CLIENT_ID
  valueFrom:
    secretKeyRef:
      name: {{ include "langsmith.secretsName" . }}
      key: oauth_client_id
- name: OAUTH_ISSUER_URL
  valueFrom:
    secretKeyRef:
      name: {{ include "langsmith.secretsName" . }}
      key: oauth_issuer_url
{{- end }}
- name: LANGSMITH_LICENSE_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "langsmith.secretsName" . }}
      key: langsmith_license_key
- name: API_KEY_SALT
  valueFrom:
    secretKeyRef:
      name: {{ include "langsmith.secretsName" . }}
      key: api_key_salt
{{- end }}

{{- define "backend.serviceAccountName" -}}
{{- if .Values.backend.serviceAccount.create -}}
    {{ default (printf "%s-%s" (include "langsmith.fullname" .) .Values.backend.name) .Values.backend.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
    {{ default "default" .Values.backend.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "frontend.serviceAccountName" -}}
{{- if .Values.frontend.serviceAccount.create -}}
    {{ default (printf "%s-%s" (include "langsmith.fullname" .) .Values.frontend.name) .Values.frontend.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
    {{ default "default" .Values.frontend.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "hubBackend.serviceAccountName" -}}
{{- if .Values.hubBackend.serviceAccount.create -}}
    {{ default (printf "%s-%s" (include "langsmith.fullname" .) .Values.hubBackend.name) .Values.hubBackend.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
    {{ default "default" .Values.hubBackend.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "playground.serviceAccountName" -}}
{{- if .Values.playground.serviceAccount.create -}}
    {{ default (printf "%s-%s" (include "langsmith.fullname" .) .Values.playground.name) .Values.playground.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
    {{ default "default" .Values.playground.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "postgres.serviceAccountName" -}}
{{- if .Values.postgres.serviceAccount.create -}}
    {{ default (printf "%s-%s" (include "langsmith.fullname" .) .Values.postgres.name) .Values.postgres.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
    {{ default "default" .Values.postgres.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "queue.serviceAccountName" -}}
{{- if .Values.queue.serviceAccount.create -}}
    {{ default (printf "%s-%s" (include "langsmith.fullname" .) .Values.queue.name) .Values.queue.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
    {{ default "default" .Values.queue.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "redis.serviceAccountName" -}}
{{- if .Values.redis.serviceAccount.create -}}
    {{ default (printf "%s-%s" (include "langsmith.fullname" .) .Values.redis.name) .Values.redis.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
    {{ default "default" .Values.redis.serviceAccount.name }}
{{- end -}}
{{- end -}}
