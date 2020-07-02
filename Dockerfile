FROM debian:buster

RUN apt-get update && apt-get install -y \
python3-configobj \
python3-pil \
python3-serial \
python3-usb \
python3-pip \
python3-cheetah \
python3-ephem \
mariadb-client \
python3-mysqldb \
fonts-roboto \
tzdata \
git \
libtool \
libusb-1.0.0-dev \
librtlsdr-dev \
build-essential \
autoconf \
cmake \
pkg-config \
wget

ENV TZ="America/New_York"

RUN wget http://weewx.com/downloads/weewx-4.1.1.tar.gz

RUN tar xvfz weewx-4.1.1.tar.gz

WORKDIR /weewx-4.1.1


RUN python3 ./setup.py build
RUN python3 ./setup.py install --no-prompt


RUN git clone git://git.osmocom.org/rtl-sdr.git
COPY rtl-sdr/build.sh ./buildrtl.sh
RUN ./buildrtl.sh

WORKDIR /weewx-4.1.1

RUN git clone https://github.com/merbanan/rtl_433.git
COPY rtl-433/build.sh .
RUN ./build.sh


WORKDIR /home/weewx

RUN pip3 install paho-mqtt

RUN wget -O weewx-mqtt.zip https://github.com/matthewwall/weewx-mqtt/archive/master.zip
RUN ./bin/wee_extension --install weewx-mqtt.zip

RUN wget -P /home/weewx https://github.com/bellrichm/WeeWX-MQTTSubscribe/archive/v1.5.3.tar.gz
RUN MQTTSubscribe_install_type=SERVICE ./bin/wee_extension --install=/home/weewx/v1.5.3.tar.gz

COPY skins/neowx-latest.zip /neowx-latest.zip
RUN ./bin/wee_extension --install=/neowx-latest.zip

COPY skins/weewx-belchertown-development.zip /weewx-belchertown-development.zip
RUN ./bin/wee_extension --install=/weewx-belchertown-development.zip

RUN wget -O weewx-sdr.zip https://github.com/magimat/weewx-sdr/archive/master.zip
RUN ./bin/wee_extension --install weewx-sdr.zip
RUN ./bin/wee_config --reconfigure --driver=user.sdr --no-prompt

RUN /home/weewx/bin/wee_config --reconfig --no-prompt

RUN mkdir -p /home/weewx/public_html
RUN echo 'blacklist dvb_usb_rtl28xxu' > /etc/modprobe.d/blacklist-dvb_usb_rtl28xxu.conf

CMD ./bin/weewxd weewx.conf
#CMD tail -f /var/log/syslog
