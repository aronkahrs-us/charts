{{/* Define the configmap */}}
{{- define "nextcloud.configmap" -}}

{{- $hosts := "" }}
{{- if .Values.ingress.main.enabled }}
  {{- range .Values.ingress }}
    {{- range $index, $host := .hosts }}
      {{- if $index }}
        {{ $hosts = ( printf "%v %v" $hosts $host.host ) }}
      {{- else }}
        {{ $hosts = ( printf "%s" $host.host ) }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
enabled: true
data:
  {{- $aliasgroup1 := (  printf "http://%s" ( .Values.workload.main.podSpec.containers.main.env.AccessIP | default ( printf "%v-%v" .Release.Name "nextcloud" ) ) ) }}
  {{- if .Values.ingress.main.enabled }}
    {{- with (first .Values.ingress.main.hosts) }}
    {{- $aliasgroup1 = (  printf "https://%s" .host ) }}
    {{- end }}
  {{- end }}
  aliasgroup1: {{ $aliasgroup1 }}
  NEXTCLOUD_TRUSTED_DOMAINS: {{ ( printf "%v %v %v %v %v %v %v %v" "test.fakedomain.dns" "localhost" "127.0.0.1" ( printf "%v:%v" "127.0.0.1" .Values.service.main.ports.main.port ) ( .Values.workload.main.podSpec.containers.main.env.AccessIP | default "localhost" ) ( printf "%v-%v" .Release.Name "nextcloud" ) ( printf "%v-%v" .Release.Name "nextcloud-backend" ) $hosts ) | quote }}
  {{- if .Values.ingress.main.enabled }}
  APACHE_DISABLE_REWRITE_IP: "1"
  {{- end }}

{{- end -}}
