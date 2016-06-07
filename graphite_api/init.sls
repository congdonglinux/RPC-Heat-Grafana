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

#python-numpy:
#  pkg.installed

#gfortran:
#  pkg.installed

#libopenblas-dev:
#  pkg.installed

#liblapack-dev:
#  pkg.installed

gunicorn:
  pip.installed:
    - require:
      - pkg: libffi-dev
      - pkg: libcairo-dev

#scipy:
#  pip.installed:
#    - require:
#      - pkg: python-numpy
#      - pkg: gfortran
#      - pkg: libopenblas-dev
#      - pkg: liblapack-dev

https://github.com/brutasse/graphite-api.git:
  git.latest:
    - rev: {{ graphite_api_rev }}
    - target: {{ graphite_api_target }}
    - require:
      - pkg: git

install-graphite-api:
  cmd.wait:
    - name: python setup.py install
    - cwd: {{ graphite_api_target }}
    - watch:
      - git: https://github.com/brutasse/graphite-api.git
    - require:
      - pkg: python-setuptools

#graphite_api_warning:
#  git.latest:
#    - name: {{ graphite_api_warning_repo_url }}
#    - rev: {{ graphite_api_warning_repo_rev }}
#    - target: {{ graphite_api_warning_repo_target }}
#    - require:
#      - pkg: git

#{{ graphite_api_warning_python_path }}/graphite_api_warning:
#  file.symlink:
#    - target: {{ graphite_api_warning_repo_target }}
#    - require:
#      - git: graphite_api_warning

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

install-blueflood:
  cmd.wait:
    - name: python setup.py install
    - cwd: /tmp/blueflood/contrib/graphite
    - watch:
      - git: https://github.com/rackerlabs/blueflood.git
    - require:
      - pkg: python-setuptools

/usr/local/lib/python2.7/dist-packages/cached_blueflood.py:
  file.managed:
    - source: salt://grafana/graphite_api/files/cached_blueflood.py

graphite-api-service:
  service.running:
    - name: graphite-api
    - enable: True
    - watch:
      - file: /etc/graphite-api.yaml
      - file: /etc/init/graphite-api.conf
      # - file: {{ graphite_api_warning_python_path }}/graphite_api_warning
      - file: /usr/local/lib/python2.7/dist-packages/cached_blueflood.py
      - cmd: install-blueflood
      - cmd: install-graphite-api
    - require:
      - cmd: install-graphite-api
      - pip: gunicorn
      - pip: scipy
