FROM ubuntu:20.04 as build
LABEL org.opencontainers.image.authors="sjmuniz@gmail.com"
ENV LANG C.UTF-8
WORKDIR /
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Argentina/Buenos_Aires

#Uncomment to enable local cache for speedy download.
#RUN echo 'Acquire::http::Proxy "http://192.168.22.31:8000";' > /etc/apt/apt.conf.d/00proxy

#Required to configure pg repo.
RUN apt -y update && apt install -y --no-install-recommends wget dirmngr gnupg tzdata

#Add PgSQL repo.
RUN echo "deb http://apt.postgresql.org/pub/repos/apt focal-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
wget --no-check-certificate --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

#Install required packages.
RUN apt -y update && apt install -y --no-install-recommends build-essential libwxgtk3.0-gtk3-dev libxml2-dev \
libxslt1-dev libssh2-1-dev python3-sphinx postgresql-server-dev-14 automake python-wxgtk3.0-dev libwxgtk3.0-gtk3-dev \
pkg-config libxpm-dev bison flex libssl-dev libssh-dev python3-wxgtk4.0 xserver-xorg-dev git

#Clone pgadmin3 repo.
RUN cd / && pwd && git clone --depth 1 https://github.com/allentc/pgadmin3-lts.git && ls

#Build and install at prefix /pgadmin3
RUN pwd && ls && cd pgadmin3-lts && bash bootstrap && ./configure --with-wx-version=3.0 --with-openssl --prefix=/pgadmin3 && make -j$(nproc) install

FROM ubuntu:20.04
#RUN echo 'Acquire::http::Proxy "http://192.168.22.31:8000";' > /etc/apt/apt.conf.d/00proxy

#Install runtime and then clean up.
RUN apt -y update && \
apt install -y --no-install-recommends xauth libpq5 libwxgtk3.0-gtk3-0v5 libxml2 libxslt1.1 libssh2-1 python3-sphinx python-wxgtk3.0 && \
apt -y clean && rm -rf /var/lib/apt/lists/* && mkdir -pv /pgadmin3
COPY --from=build /pgadmin3 /pgadmin3
ADD start.sh /start.sh
RUN chmod 0755 /start.sh
CMD /start.sh
