es_version: 1.3.4
es_hash: 3d9e3a30481270179eab8fc093bc2569
gr_version: 1.8.1
gr_hash: 7019fc7c9e5a7bbbf992fbb4f22779c9
grafanizer_branch: master
#graphite_api_warning:
#  url: https://github.com/absalon-james/graphite_api_warning.git
#  rev: master
#  target: /root/graphite_api_warning
#  python_path: /usr/local/lib/python2.7/dist-packages
graphite_api:
  rev: a2104da9ffed42f3d0ee1dfcfe342152b4ad4e77
  target: /tmp/graphite_api
  gunicorn:
    worker_timeout: 300
blueflood:
  rev: master
  target: /tmp/blueflood
nginx:
  graphite:
    proxy_read_timeout: 300
user-ports:
  ssh:
    chain: INPUT
    proto: tcp
    dport: 22
  http:
    chain: INPUT
    proto: tcp
    dport: 80
  https:
    chain: INPUT
    proto: tcp
    dport: 443
  graphite-api:
    chain: INPUT
    proto: tcp
    dport: 8888
  elasticsearch:
    chain: INPUT
    proto: tcp
    dport: 9200
  memcached:
    chain: INPUT
    proto: tcp
    source: 127.0.0.1
    dport: 11211
