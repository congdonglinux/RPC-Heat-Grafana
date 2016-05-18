{%- set es_version = salt['pillar.get']('es_version', '1.3.4') -%}
{%- set es_hash = salt['pillar.get']('es_hash') -%}
include:
  - grafana.java

/tmp/elasticsearch-{{ es_version }}.deb:
  file.managed:
    - source: https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-{{ es_version }}.deb
    - source_hash: md5={{ es_hash }}

install_elasticsearch:
  cmd.wait:
    - name: dpkg -i /tmp/elasticsearch-{{ es_version }}.deb
    - watch:
      - file: /tmp/elasticsearch-{{ es_version }}.deb

/etc/elasticsearch/elasticsearch.yml:
  file.managed:
    - source: salt://grafana/elasticsearch/files/elasticsearch.yml
    - template: jinja
    - context:
      cluster_name: es_grafana
      network_host: 127.0.0.1
    - require:
      - cmd: install_elasticsearch

service_elasticsearch:
  service.running:
    - name: elasticsearch
    - enable: True
    - require:
      - cmd: install_elasticsearch
    - watch:
      - file: /etc/elasticsearch/elasticsearch.yml
