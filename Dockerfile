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
wget

RUN wget http://weewx.com/downloads/weewx-4.1.1.tar.gz

RUN tar xvfz weewx-4.1.1.tar.gz

WORKDIR /weewx-4.1.1

RUN python3 ./setup.py build
RUN python3 ./setup.py install --no-prompt

WORKDIR /home/weewx

RUN pip3 install paho-mqtt

RUN wget -P /home/weewx https://github.com/bellrichm/WeeWX-MQTTSubscribe/archive/v1.5.3.tar.gz
RUN MQTTSubscribe_install_type=DRIVER ./bin/wee_extension --install=/home/weewx/v1.5.3.tar.gz

COPY neowx-latest.zip /neowe-latest.zip
RUN ./bin/wee_extension --install=/neowe-latest.zip

RUN /home/weewx/bin/wee_config --reconfig --no-prompt

RUN mkdir -p /home/weewx/public_html

CMD ./bin/weewxd weewx.conf
#CMD tail -f /var/log/syslog
