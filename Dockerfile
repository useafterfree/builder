FROM segment/chamber:2 AS chamber
FROM circleci/mongo:xenial
FROM circleci/node:10.15.3-browsers
COPY --from=chamber /chamber /bin/chamber
COPY .terraform-version /.terraform-version
USER root
RUN apt-get update;
RUN apt-get -y install curl git sudo build-essential python3
RUN adduser docker
RUN usermod -aG sudo docker
USER docker
RUN /bin/bash -c  "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
SHELL ["/bin/bash", "-c"]
RUN echo 'eval $(/home/docker/.linuxbrew/bin/brew shellenv)' >> /home/docker/.profile
ENV PATH="/home/docker/.linuxbrew/bin:${PATH}"
# RUN brew install aws-vault
# RUN aws-vault; exit 0;

RUN brew install tfenv
RUN brew install jq
USER root
RUN tfenv install
RUN curl -sO https://bootstrap.pypa.io/get-pip.py && python3 get-pip.py && pip3 install awscli --upgrade
USER docker
RUN terraform; exit 0;
RUN aws; exit 0;
RUN chamber; exit 0
RUN yarn; exit 0
