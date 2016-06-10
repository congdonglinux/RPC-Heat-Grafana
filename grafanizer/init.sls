include:
  - grafana.common

eventlet:
  pip.installed:
    - require:
      - pkg: python-pip

cerberus:
  pip.installed:
    - name: cerberus == 0.8
    - require:
      - pkg: python-pip

elasticsearch:
  pip.installed:
    - require:
      - pkg: python-pip

pyparsing:
  pip.installed:
    - require:
      - pkg: python-pip

grafanizer:
  git.latest:
    - name: https://github.com/absalon-james/grafanizer.git
    - rev: {{ salt['pillar.get']('grafanizer_branch', 'master') }}
    - target: /root/grafanizer
    - require:
      - pkg: git

/root/.grafanizerrc:
  file.managed:
    - source: salt://grafana/grafanizer/files/grafanizerrc
    - template: jinja
    - user: root
    - owner: root
    - mode: 600

/var/log/grafanizer:
  file.directory:
    - user: root
    - group: root
    - mode: 600

# Moving this out to a salt job
python /root/grafanizer/grafanizer:
  cron.absent:
    - user: root
    - minute: 0
    - hour: '*/12'
