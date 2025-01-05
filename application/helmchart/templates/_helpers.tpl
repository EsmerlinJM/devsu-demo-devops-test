{{/*
Common labels
*/}}
{{- define "node-chart.labels" -}}
helm.sh/chart: {{ .Chart.Name }}
{{ include "node-chart.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "node-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ .Release.Name }}
{{- end }}