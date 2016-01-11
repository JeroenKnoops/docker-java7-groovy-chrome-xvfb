FROM java:7

MAINTAINER Jeroen Knoops <jeroen.knoops@gmail.com>

#=========
# Env variables
#=========

ENV GROOVY_VERSION 2.4.5
ENV CHROME_DRIVER_VERSION 2.20

#=========
# Install groovy from SDKMan
#=========

# Installs curl, git and SDKMan
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip
    
RUN curl -s get.sdkman.io | bash

# Installs Groovy from GVM
RUN /bin/bash -c "source /root/.sdkman/bin/sdkman-init.sh && sdk install groovy ${GROOVY_VERSION}"
ENV GROOVY_HOME /root/.sdkman/groovy/current
ENV PATH $GROOVY_HOME/bin:$PATH


#=========
# Adding Headless Selenium with Chrome and Firefox
#=========
# Firefox
RUN apt-get install -y -q software-properties-common wget
RUN add-apt-repository -y ppa:mozillateam/firefox-next

RUN apt-get update && apt-get install -y \
	firefox

# Chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list
RUN apt-get update && apt-get install -y \
	google-chrome-stable

# Chrome driver
RUN wget -O /tmp/chromedriver.zip http://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip
RUN unzip /tmp/chromedriver.zip chromedriver -d /usr/bin/
RUN chmod ugo+rx /usr/bin/chromedriver

# Dependencies to make "headless" selenium work
RUN apt-get -y install \
	gtk2-engines-pixbuf \
	libxtst6 \
	xfonts-100dpi \
	xfonts-75dpi \
	xfonts-base \
	xfonts-cyrillic \
	xfonts-scalable \
	xvfb

# Starting xfvb as a service
ENV DISPLAY=:99
ADD xvfb /etc/init.d/
RUN chmod 755 /etc/init.d/xvfb

