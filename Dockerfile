ARG IMAGE=containers.intersystems.com/intersystems/iris-community-arm64:2023.1.0.235.1
ARG IMAGE=containers.intersystems.com/intersystems/iris-community:2023.1.0.235.1
FROM $IMAGE

ARG COMMIT_ID="simpleddp"

USER root   
        
ENV ISC_TEMP_DIR=/intersystems/iris/simpleddp

USER ${ISC_PACKAGE_MGRUSER}

COPY dsmdasl_demo-utf8.sav $ISC_TEMP_DIR/
COPY simpleddp.mac $ISC_TEMP_DIR 
COPY src $ISC_TEMP_DIR
COPY src/%ZTools $ISC_TEMP_DIR/%ZTools
COPY iris.script /tmp/iris.script

USER root

RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /intersystems/iris/simpleddp

USER ${ISC_PACKAGE_MGRUSER}

RUN iris start IRIS \
	&& iris session IRIS < /tmp/iris.script \
    && iris stop IRIS quietly
