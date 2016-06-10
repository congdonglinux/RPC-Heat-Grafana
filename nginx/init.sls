{%- set web_username = salt['grains.get']('web_username', 'grafana') -%}
{%- set web_password = salt['grains.get']('web_password', 'changeme') -%}
nginx:
  pkg.installed

nginx-extras:
  pkg.installed

apache2-utils:
  pkg.installed

{{ web_username }}:
  webutil.user_exists:
    - password: {{ web_password }}
    - htpasswd_file: /etc/nginx/.htpasswd
    - options: c
    - force: True
    - require:
      - pkg: nginx
      - pkg: apache2-utils

/etc/nginx/sites-enabled/default:
  file.absent:
    - require:
      - pkg: nginx

/etc/nginx/sites-available/grafana:
  file.managed:
    - source: salt://grafana/nginx/files/grafana
    - template: jinja
    - require:
      - pkg: nginx

/etc/nginx/sites-enabled/grafana:
  file.symlink:
    - target: /etc/nginx/sites-available/grafana
    - require:
      - file: /etc/nginx/sites-available/grafana

/etc/nginx/ssl:
  file.directory:
    - user: root
    - owner: root
    - mode: 700
    - require:
      - pkg: nginx

self_signed_cert:
  cmd.run:
    - name: openssl req -x509 -nodes -newkey rsa:2048 -keyout /etc/nginx/ssl/grafana.key -out /etc/nginx/ssl/grafana.crt -days 999 -subj "/CN={{ salt['network.ipaddrs']('eth0')[0] }}"
    - creates: /etc/nginx/ssl/grafana.crt
    - require:
      - file: /etc/nginx/ssl

nginx_service:
  service.running:
    - name: nginx
    - enable: True
    - watch:
      - file: /etc/nginx/sites-available/grafana
    - require:
      - pkg: nginx
      - cmd: self_signed_cert

