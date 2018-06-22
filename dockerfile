FROM debian

RUN apt-get update && apt-get upgrade -y && \
    apt-get install --no-install-recommends -y -qq clamav-daemon clamav-freshclam libclamunrar7 netcat wget nano daemon && apt-get clean

RUN freshclam

RUN echo 'Acquire::http::Proxy "http://webcache:3128/";' > /etc/apt/apt.conf.d/99local_proxy

RUN rm -v /etc/apt/sources.list

RUN echo deb http://ftp.uk.debian.org/debian/ stretch main non-free contrib > /etc/apt/sources.list
RUN echo deb http://security.debian.org/ stretch/updates main contrib non-free >> /etc/apt/sources.list
RUN echo deb http://ftp.uk.debian.org/debian/ stretch-updates main contrib non-free >> /etc/apt/sources.list

COPY freshclam.conf /etc/clamav/

RUN mkdir /var/run/clamav && \
    chown clamav:clamav /var/run/clamav && \
    chmod 750 /var/run/clamav

COPY clamd.conf /etc/clamav/
COPY clamav-daemon /etc/init.d/

RUN chmod +x /etc/init.d/clamav-daemon
COPY freshclam /etc/cron.hourly/
RUN chmod +x /etc/cron.hourly/freshclam

EXPOSE 3310

ENTRYPOINT /etc/init.d/clamav-daemon start
