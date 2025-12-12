# OpenTelemetry Collector configuration.
#
# https://opentelemetry.io/docs/collector/
# https://opentelemetry.io/docs/collector/configuration/
# https://opentelemetry.io/docs/collector/internal-telemetry/
extensions:
  file_storage:
    directory: /var/log/otelcol
    create_directory: true
  bearertokenauth:
    filename: {{ .pathAuthToken }}

receivers:
  kubeletstats:
    collection_interval: 20s
    initial_delay: 1s
    auth_type: "tls"
    ca_file: {{ .kubeletCA }}
    key_file: {{ .kubeletCertKey }}
    cert_file: {{ .kubeletCert }}
    endpoint: "https://127.0.0.1:10250"
    insecure_skip_verify: true
  hostmetrics:
    collection_interval: 10s
    scrapers:
      cpu:
      disk:
      load:
      filesystem:
      memory:
      network:
      system:
  journald/journal:
    start_at: beginning
    storage: file_storage
    matches:
      - _TRANSPORT: kernel
      - _SYSTEMD_UNIT: kubelet.service
      - _SYSTEMD_UNIT: containerd.service
      - _SYSTEMD_UNIT: gardener-node-agent.service
    operators:
      - type: move
        from: body._SYSTEMD_UNIT
        to: resource.unit
      - type: move
        from: body._HOSTNAME
        to: resource.nodename
      - type: move
        from: body.MESSAGE
        to: body

  filelog/pods:
    include: /var/log/pods/kube-system_*/*/*.log
    storage: file_storage
    include_file_path: true
    operators:
      - type: container
        format: containerd
        add_metadata_from_filepath: true

processors:
  batch:
    timeout: 10s

  # Include resource attributes from the Kubernetes environment.
  # The Shoot KAPI server is queried for pods in the kube-system namespace
  # which are labeled with "resources.gardener.cloud/managed-by=gardener".
  k8sattributes:
    auth_type: "kubeConfig"
    context: "shoot"
    wait_for_metadata: true
    wait_for_metadata_timeout: 30s
    filter:
        namespace: kube-system
        labels:
          - key: resources.gardener.cloud/managed-by
            op: equals
            value: gardener
    pod_association:
      - sources:
          - from: resource_attribute
            name: k8s.pod.name

  # If the log came from a pod that is managed by Gardener, the 'k8sattributes' processor
  # will successfully associate the datapoint (log) with the a pod. Since we only
  # watch the kube-system namespace for pods that are managed by Gardener, we can
  # simply drop all logs that do not have a specific label that we know should have been
  # added by the 'k8sattributes' processor. In this case, we check for the
  # existence of the 'k8s.node.name' attribute.
  filter/drop_non_gardener:
    error_mode: ignore
    logs:
      log_record:
        - resource.attributes["k8s.node.name"] == nil

  resource/journal:
    attributes:
      - action: insert
        key: origin
        value: systemd_journal

  resource/pod_labels:
    attributes:
      - key: origin
        value: "shoot_system"
        action: insert
      - key: namespace_name
        value: "kube-system"
        action: insert

exporters:
  debug:
    verbosity: detailed
  otlp:
    endpoint: {{ .clientURL }}
    auth:
      authenticator: bearertokenauth
    tls:
      ca_file: {{ .pathCACert }}

service:
  telemetry:
    metrics:
      level: normal
      readers:
        - pull:
            exporter:
              prometheus:
                host: 0.0.0.0
                port: {{ .metricsPort }}
    logs:
      level: INFO
      encoding: json

  extensions: [file_storage, bearertokenauth]
  pipelines:
    metrics:
      receivers: [hostmetrics, kubeletstats]
      processors: [resource/journal, batch]
      exporters: [otlp, debug]
    logs/journal:
      receivers: [journald/journal]
      processors: [resource/journal, batch]
      exporters: [otlp]
    logs/pods:
      receivers: [filelog/pods]
      processors: [k8sattributes, filter/drop_non_gardener, resource/pod_labels, batch]
      exporters: [otlp]
