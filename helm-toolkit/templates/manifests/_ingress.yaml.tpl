{{/*
Copyright 2017 The Openstack-Helm Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/}}

# This function creates a manifest for a services ingress rules.
# It can be used in charts dict created similar to the following:
# {- $ingressOpts := dict "envAll" . "backendServiceType" "key-manager" -}
# { $ingressOpts | include "helm-toolkit.manifests.ingress" }

{{- define "helm-toolkit.manifests.ingress" -}}
{{- $envAll := index . "envAll" -}}
{{- $backendService := index . "backendService" | default "api" -}}
{{- $backendServiceType := index . "backendServiceType" -}}
{{- $backendPort := index . "backendPort" -}}
{{- $ingressName := tuple $backendServiceType "public" $envAll | include "helm-toolkit.endpoints.hostname_short_endpoint_lookup" }}
{{- $backendName := tuple $backendServiceType "internal" $envAll | include "helm-toolkit.endpoints.hostname_short_endpoint_lookup" }}
{{- $hostName := tuple $backendServiceType "public" $envAll | include "helm-toolkit.endpoints.hostname_short_endpoint_lookup" }}
{{- $hostNameNamespaced := tuple $backendServiceType "public" $envAll | include "helm-toolkit.endpoints.hostname_namespaced_endpoint_lookup" }}
{{- $hostNameFull := tuple $backendServiceType "public" $envAll | include "helm-toolkit.endpoints.hostname_fqdn_endpoint_lookup" }}
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: {{ $ingressName }}
  annotations:
{{ toYaml (index $envAll.Values.network $backendService "ingress" "annotations") | indent 4 }}
spec:
  rules:
{{ if ne $hostNameNamespaced $hostNameFull }}
{{- range $key1, $vHost := tuple $hostName $hostNameNamespaced $hostNameFull }}
  - host: {{ $vHost }}
    http:
      paths:
      - path: /
        backend:
          serviceName: {{ $backendName }}
          servicePort: {{ $backendPort }}
{{- end }}
{{- else }}
{{- range $key1, $vHost := tuple $hostName $hostNameNamespaced }}
  - host: {{ $vHost }}
    http:
      paths:
      - path: /
        backend:
          serviceName: {{ $backendName }}
          servicePort: {{ $backendPort }}
{{- end }}
{{- end }}

{{- end }}
