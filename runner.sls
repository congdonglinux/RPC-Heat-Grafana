grafana:
  salt.state:
    - tgt: 'roles:grafana'
    - tgt_type: grain
    - highstate: True

hardening:
  salt.state:
    - tgt: 'roles:grafana'
    - tgt_type: grain
    - sls:
      - grafana.hardening
    - require:
      - salt: grafana
