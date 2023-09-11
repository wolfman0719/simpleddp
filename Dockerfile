ARG IMAGE=containers.intersystems.com/intersystems/iris-community-arm64:2023.1.0.235.1
ARG IMAGE=containers.intersystems.com/intersystems/iris-community-arm64:2023.2.0.227.0
ARG IMAGE=containers.intersystems.com/intersystems/iris-community:2023.1.0.235.1
ARG IMAGE=containers.intersystems.com/intersystems/iris-community:2023.2.0.227.0
FROM $IMAGE

ARG COMMIT_ID="simpleddp"

USER root   
        
ENV ISC_TEMP_DIR=/intersystems/iris/simpleddp

USER ${ISC_PACKAGE_MGRUSER}

COPY simpleddp.mac $ISC_TEMP_DIR/simpleddp.mac
COPY config.json $ISC_TEMP_DIR/config.json
COPY src $ISC_TEMP_DIR
COPY src/%ZTools $ISC_TEMP_DIR/%ZTools
COPY iris.script /tmp/iris.script

USER root

RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /intersystems/iris/simpleddp

USER ${ISC_PACKAGE_MGRUSER}

RUN iris start IRIS \
	&& iris session IRIS < /tmp/iris.script \
    && iris stop IRIS quietly
