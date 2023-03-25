
cat > /etc/systemd/system/sentinel.service <<END
[Unit]
Description=Sentinel for Redis
After=network.target

StartLimitBurst=5
StartLimitIntervalSec=33

[Service]
Type=forking
User=redis
Group=redis
PIDFile=/var/redis/redis-sentinel.pid
ExecStart=/usr/bin/redis-sentinel /etc/redis-sentinel.conf 
ExecStop=/bin/kill -s TERM 

Restart=on-failure
RestartSec=15


[Install]
WantedBy=multi-user.target
END
cp -rf /etc/redis-sentinel.conf /etc/redis-sentinel-26379.conf
mkdir -p /var/lib/redis-sentinel
chmod 777 /var/lib/redis-sentinel
chown redis /var/lib/redis-sentinel
sed -i "s/^# bind 127.0.0.1.*/bind 127.0.0.1/"  /etc/redis-sentinel-26379.conf
sed -i "s/^daemonize.*/daemonize yes/"  /etc/redis-sentinel-26379.conf
sed -i "s/^dir.*/dir \/var\/lib\/redis-sentinel\//"  /etc/redis-sentinel-26379.conf
sed -i "s/^sentinel down-after-milliseconds.*/sentinel down-after-milliseconds mymaster 3100/"  /etc/redis-sentinel-26379.conf
sed -i "s/^sentinel failover-timeout.*/sentinel failover-timeout mymaster 5000/"  /etc/redis-sentinel-26379.conf
sed -i "s/^logfile.*/logfile \/var\/log\/redis\/sentinel.log/"  /etc/redis-sentinel-26379.conf
sed -i "s/^pidfile.*/pidfile \/var\/redis\/redis-sentinel.pid/"  /etc/redis-sentinel-26379.conf


rm -rf /etc/redis-sentinel.conf
cat > /etc/redis-sentinel.conf <<END
include /etc/redis-sentinel-26379.conf
END



chown redis:redis /var/log/redis/sentinel.log
chmod 777 /etc/redis-sentinel.conf
chmod 666 /etc/redis-sentinel-26379.conf
chmod 666 /var/log/redis/sentinel.log
sudo chown redis:redis /etc/redis-sentinel.conf
sudo systemctl daemon-reload
sudo systemctl enable sentinel.service
cat >> /etc/redis-6382.conf <<END
slaveof 127.0.0.1 6379
END

sudo systemctl start sentinel
#sudo  systemctl start|restart|stop|status sentinel
#redis-server /etc/redis-sentinel.conf –sentinel


















