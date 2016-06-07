{%- set graphite_api_rev = salt['pillar.get']('graphite_api:rev', 'master') -%}
{%- set graphite_api_target = salt['pillar.get']('graphite_api:target', '/tmp/graphite_api') -%}
{%- set graphite_api_warning_repo_url = salt['pillar.get']('graphite_api_warning:url', 'https://github.com/absalon-james/graphite_api_warning.git') -%}
{%- set graphite_api_warning_repo_rev = salt['pillar.get']('graphite_api_warning:rev', 'master') -%}
{%- set graphite_api_warning_repo_target = salt['pillar.get']('graphite_api_warning:target', '/root/graphite_api_warning') -%}
{%- set graphite_api_warning_python_path = salt['pillar.get']('graphite_api_warning:python_path', '/usr/local/lib/python2.7/dist-packages') -%}
{%- set blueflood_rev = salt['pillar.get']('blueflood:rev', 'master') -%}
{%- set blueflood_target = salt['pillar.get']('blueflood:target', '/tmp/blueflood') -%}
include:
  - grafana.common

libffi-dev:
  pkg.installed

libcairo-dev:
  pkg.installed

gunicorn:
  pip.installed:
    - require:
      - pkg: libffi-dev
      - pkg: libcairo-dev

/etc/graphite-api.yaml:
  file.managed:
    - source: salt://grafana/graphite_api/files/graphite-api.yaml
    - template: jinja
    - user: root
    - group: root
    - mode: 600

/etc/init/graphite-api.conf:
  file.managed:
    - source: salt://grafana/graphite_api/files/graphite-api.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 600

https://github.com/rackerlabs/blueflood.git:
  git.latest:
    - rev: {{ blueflood_rev }}
    - target: {{ blueflood_target }}
    - require:
      - pkg: git

/usr/local/lib/python2.7/dist-packages/cached_blueflood.py:
  file.managed:
    - source: salt://grafana/graphite_api/files/cached_blueflood.py

install and start graphite-api:
  cmd.run:
    - name: echo "cd /tmp/blueflood/contrib/graphite; python setup.py install; pip install graphite-api; service graphite-api restart" | at now + 3 minutes
    - require:
      - git: https://github.com/rackerlabs/blueflood.git
