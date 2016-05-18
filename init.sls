{%- set gr_version = salt['pillar.get']('gr_version', '1.8.1') -%}
{%- set gr_hash = salt['pillar.get']('gr_hash') -%}
include:
  - grafana.common
  - grafana.elasticsearch
  - grafana.nginx
  - grafana.memcached
  - grafana.graphite_api
  - grafana.grafanizer

grafana-{{ gr_version }}:
  archive.extracted:
    - name: /usr/share/nginx
    - source: http://grafanarel.s3.amazonaws.com/grafana-{{ gr_version }}.tar.gz
    - source_hash: md5={{ gr_hash }}
    - archive_format: tar
    - tar_options: xf
    - if_missing: /usr/share/nginx/grafana-{{ gr_version }}
    - require:
      - pkg: nginx

/usr/share/nginx/grafana-{{ gr_version }}/config.js:
  file.managed:
    - source: salt://grafana/files/grafana-config.js
    - user: root
    - group: root
    - mode: 644

#grafana_warning_panel_plugin:
#  git.latest:
#    - name: https://github.com/absalon-james/grafana-warning-panel-plugin.git
#    - rev: {{ salt['pillar.get']('grafana_warning_panel_plugin_branch', 'master') }}
#    - target: /usr/share/nginx/grafana-{{ gr_version}}/app/panels/warning
#    - require:
#      - pkg: git
#      - archive: grafana-{{ gr_version }}

/usr/share/nginx/grafana:
  file.symlink:
    - target: /usr/share/nginx/grafana-{{ gr_version }}
    - require:
      - archive: grafana-{{ gr_version }}

rackspace-monitoring-cli:
  pip.installed:
    - require:
      - pkg: python-pip

cp /root/grafanizer/sample_grafana_dashboards/default.js /usr/share/nginx/grafana-{{ gr_version }}/app/dashboards/default.js:
  cmd.run:
    - require:
      - git: grafanizer
      - archive: grafana-{{ gr_version }}

#run_grafanizer:
#  cmd.run:
#    - name: python /root/grafanizer/grafanizer/grafanizer
#    - require:
#      - service: service_elasticsearch
#      - git: grafanizer
#      - file: /root/.grafanizerrc
