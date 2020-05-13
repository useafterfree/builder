FROM segment/chamber:2 AS chamber
FROM circleci/mongo:xenial
FROM circleci/node:10.15.3-browsers

COPY --from=chamber /chamber /bin/chamber
COPY .terraform-version /.terraform-version
USER root
RUN apt-get update;
RUN apt-get -y install curl git sudo build-essential python3 locales
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers ## So we can sudo
RUN adduser docker
RUN usermod -aG sudo docker

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

USER docker

RUN /bin/bash -c  "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
SHELL ["/bin/bash", "-c"]
RUN echo 'eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)' >> /home/docker/.profile
ENV PATH="/home/linuxbrew/.linuxbrew/bin:${PATH}"
# RUN brew install aws-vault
# RUN aws-vault; exit 0;

RUN brew install tfenv dvm jq yarn
USER root

RUN curl -o- -L https://yarnpkg.com/install.sh | sudo bash -s -- --version 1.22.4
RUN echo "[ -f /home/linuxbrew/.linuxbrew/opt/dvm/dvm.sh ] && . /home/linuxbrew/.linuxbrew/opt/dvm/dvm.sh" >> /etc/profile.d/dvm
ENV DOCKER_VERSION=18.09.6
RUN /bin/bash -c '. /home/linuxbrew/.linuxbrew/opt/dvm/dvm.sh; dvm install'
RUN tfenv install
RUN curl -sO https://bootstrap.pypa.io/get-pip.py && python3 get-pip.py && pip3 install awscli --upgrade
USER docker
RUN terraform; exit 0;
RUN aws; exit 0;
RUN chamber; exit 0
RUN yarn --version; exit 0
RUN docker --version; exit 0
