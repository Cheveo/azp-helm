{{- define "azp-agent.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "azp-agent.name" -}}
{{- .Chart.Name -}}
{{- end -}}