FROM marklee77/frankenlibc
MAINTAINER Mark Stillwell <mark@stillwell.me>

RUN apt-get update && \
    apt-get -y install curl && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN cd /usr/src && \
    curl http://nginx.org/download/nginx-1.9.2.tar.gz | tar xzf - && \
    cd nginx-1.9.2 && \
    FRANKEN_VERBOSE=0 CC=/usr/local/bin/franken-cc ./configure \
        --conf-path=/data/conf/nginx.conf \
        --sbin-path=/none \
        --pid-path=/tmp/nginx.pid \
        --lock-path=/tmp/nginx.lock \
        --error-log-path=/tmp/error.log \
        --http-log-path=/tmp/access.log \
        --http-client-body-temp-path=/tmp/client-body \
        --http-proxy-temp-path=/tmp/proxy \
        --http-fastcgi-temp-path=/tmp/fastcgi \
        --http-scgi-temp-path=/tmp/scgi \
        --http-uwsgi-temp-path=/tmp/uwsgi \
        --without-http_gzip_module \
        --without-http_rewrite_module \
        --with-ipv6 && \
    printf "#ifndef NGX_HAVE_MAP_ANON\n#define NGX_HAVE_MAP_ANON 1\n#endif\n" \
        >> objs/ngx_auto_config.h && \
    make && \
    cp objs/nginx /usr/local/bin && \
    cd .. && \
    rm -rf nginx-1.9.2

COPY disk.img /usr/local/share/disk.img

EXPOSE 8080

#CMD rexec nginx -nx -ro fs.img -rw docker:eth0 -- -c /data/conf/nginx.conf
CMD rexec nginx /usr/local/share/disk.img docker:eth0 -- -c /data/conf/nginx.conf
