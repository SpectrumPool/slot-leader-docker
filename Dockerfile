FROM debian:buster

# Install python
RUN apt-get update && apt-get -y install python3-pip git make

# Build the IOHK LibSodium
RUN apt-get -y install libtool &&\
    git clone https://github.com/input-output-hk/libsodium &&\
    cd libsodium &&\
    git checkout 66f017f1 &&\
    ./autogen.sh &&\
    ./configure &&\
    make &&\
    make install


RUN apt-get -y install jq &&\
    pip3 install pytz

ENV TIME_ZONE=Europe/Berlin
ENV LEDGER_JSON=/ledger.json
ENV VRF_SKEY=/vrf.skey
ENV SILENT=
ENV SIGMA=
ENV BFT=

COPY slot-leader/entrypoint.sh .
RUN chmod 0700 entrypoint.sh

COPY slot-leader/pooltool.io/leaderLogs/leaderLogs.py .
COPY slot-leader/pooltool.io/leaderLogs/getSigma.py .

ENTRYPOINT ./entrypoint.sh
