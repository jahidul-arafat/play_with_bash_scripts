#! /bin/bash
ELKVER="7.6.2"
ELKREPO="7.x"
MAGE_WEB_USER=rubitrux
cp /etc/yum.repos.d/elastic.repo /etc/yum.repos.d/elastic.repo.back
rm -rf /etc/yum.repos.d/elastic.repo
rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
cat > /etc/yum.repos.d/elastic.repo << EOF
[elasticsearch-${ELKREPO}]
name=Elasticsearch repository for ${ELKREPO} packages
baseurl=https://artifacts.elastic.co/packages/${ELKREPO}/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=0
autorefresh=1
type=rpm-md
EOF
echo

service elasticsearch stop
mkdir /etc/elasticsearch.back
cp -rf /etc/elasticsearch/* /etc/elasticsearch.back/
rm -rf /etc/elasticsearch/*
dnf --enablerepo=elasticsearch-7.x update elasticsearch
chown -R :elasticsearch /etc/elasticsearch/*
/usr/share/elasticsearch/bin/elasticsearch-plugin remove analysis-icu
/usr/share/elasticsearch/bin/elasticsearch-plugin remove analysis-phonetic
/usr/share/elasticsearch/bin/elasticsearch-plugin install analysis-icu
/usr/share/elasticsearch/bin/elasticsearch-plugin install analysis-phonetic
sed -i "s/.*network.host.*/network.host: 127.0.0.1/" /etc/elasticsearch/elasticsearch.yml
sed -i "s/.*http.port.*/http.port: 9200/" /etc/elasticsearch/elasticsearch.yml
cat >> /etc/elasticsearch/elasticsearch.yml <<END
indices.query.bool.max_clause_count: 10024
END
echo
sed -i "s/-Xms.*/-Xms1g/" /etc/elasticsearch/jvm.options
sed -i "s/-Xmx.*/-Xmx1g/" /etc/elasticsearch/jvm.options
sed -i "s/.*cluster.name.*/cluster.name: ${MAGE_WEB_USER}/" /etc/elasticsearch/elasticsearch.yml
sed -i "s/.*node.name.*/node.name: ${MAGE_WEB_USER}-node1/" /etc/elasticsearch/elasticsearch.yml
systemctl daemon-reload
systemctl enable elasticsearch.service
systemctl start elasticsearch.service
