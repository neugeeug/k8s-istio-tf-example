// ...existing code...
{{- /*
Minimal helper templates providing `.name` and `.fullname` for the chart.
These are intentionally small and compatible with the existing templates which call
`include "app-chart.fullname" .` and `include "app-chart.name" .`.
*/ -}}

{{- define "app-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride -}}
{{- end -}}

{{- define "app-chart.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name (include "app-chart.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

// ...existing code...

