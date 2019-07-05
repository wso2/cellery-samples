#-----------------------------------------------------------------------
#  Copyright (c) 2019 WSO2 Inc. (http:www.wso2.org) All Rights Reserved.
#
#  WSO2 Inc. licenses this file to you under the Apache License,
#  Version 2.0 (the "License"); you may not use this file except
#  in compliance with the License.
#  You may obtain a copy of the License at
#
#  http:www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing,
#  software distributed under the License is distributed on an
#  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#  KIND, either express or implied.  See the License for the
#  specific language governing permissions and limitations
#  under the License.
#-----------------------------------------------------------------------

FROM ubuntu:18.04

# module to build
ARG MODULE
ENV TEST=${MODULE}

# set user configurations
ENV USER=cellery
ENV USER_ID=1000
ENV USER_GROUP=cellery
ENV USER_GROUP_ID=1000
ENV USER_HOME=/home/${USER}

# create a user group and a user
RUN groupadd --system -g ${USER_GROUP_ID} ${USER_GROUP} && \
    useradd --system --create-home --home-dir ${USER_HOME} --no-log-init -g ${USER_GROUP_ID} -u ${USER_ID} ${USER}

# install required packages
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
curl \
gpg-agent \
bash \
software-properties-common

COPY resources/apache-maven-3.5* ${USER_HOME}/software/maven3/
COPY resources/jdk* ${USER_HOME}/software/jdk/
COPY ${TEST} ${USER_HOME}/${TEST}
COPY resources/run.sh ${USER_HOME}/${TEST}/

RUN chmod +x ${USER_HOME}/${TEST}/run.sh

ENV JAVA_HOME=${USER_HOME}/software/jdk
ENV M2_HOME=${USER_HOME}/software/maven3
ENV MAVEN_HOME=${USER_HOME}/software/maven3
ENV PATH=${M2_HOME}/bin:${PATH}

WORKDIR ${USER_HOME}/${TEST}
ENTRYPOINT ${USER_HOME}/${TEST}/run.sh
