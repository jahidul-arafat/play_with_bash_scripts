nginx -v
NGINX_VERSION=$(curl -s http://nginx.org/en/download.html | grep -oP '(?<=gz">nginx-).*?(?=</a>)' | head -1)
echo ${NGINX_VERSION}
wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && tar zxvf nginx-${NGINX_VERSION}.tar.gz
cd ngx_brotli && git submodule update --init && cd ~
cd ..
cd nginx-${NGINX_VERSION}
./configure --with-compat --add-dynamic-module=../ngx_brotli 
#--add-dynamic-module=../ngx_http_geoip2_module
make modules
sudo cp objs/*.so /etc/nginx/modules
ls /etc/nginx/modules
sudo chmod 644 /etc/nginx/modules/*.so
sudo nginx -t