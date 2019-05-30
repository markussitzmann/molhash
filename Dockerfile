FROM debian:buster
LABEL maintainer="markus.sitzmann@gmail.com"

ENV RDBASE="/opt/rdkit"
ENV RDKIT_BRANCH="Release_2019_03"

ENV MOLHASH_BASE="/opt/molhash"
ENV MOLHASH_BRANCH="master"

ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$RDBASE/lib:/usr/lib/x86_64-linux-gnu"


RUN apt-get update && apt-get install -y --no-install-recommends  \
    git \
    gnupg2 \
    cmake \
    ca-certificates \
    build-essential \
    libboost-dev \
    libboost-all-dev \
    libboost-system1.67-dev \
    libboost-thread1.67-dev \
    libboost-serialization1.67-dev \
    libboost-python1.67-dev \
    libboost-regex1.67-dev \
    libboost-iostreams1.67-dev \
    libcairo2-dev \
    libeigen3-dev \
    python3-dev \
    python3-numpy \
    python3-pip \
    python3-pil \
    python3-pandas

WORKDIR /opt

RUN git clone -b $RDKIT_BRANCH --single-branch https://github.com/rdkit/rdkit.git

WORKDIR $RDBASE/build

RUN cmake \
  -D Py_ENABLE_SHARED=1 \
  -D PYTHON_EXECUTABLE=/usr/bin/python3 \
  -D RDK_INSTALL_INTREE=ON \
  -D RDK_BUILD_INCHI_SUPPORT=ON \
  -D RDK_BUILD_AVALON_SUPPORT=ON \
  -D RDK_BUILD_PYTHON_WRAPPERS=ON \
  -D RDK_BUILD_CAIRO_SUPPORT=ON \
  -D RDK_BUILD_CPP_TESTS=ON \
  ..

RUN make -j $(nproc) && make install

#ENV PYTHONPATH=$RDBASE
#RUN ctest


WORKDIR /opt

RUN git clone -b $MOLHASH_BRANCH --single-branch https://github.com/nextmovesoftware/molhash.git

WORKDIR $MOLHASH_BASE/build

RUN cmake \
#    -D TARGET=RDKIT \
#    -D RDKIT_DIR=/opt/rdkit \
#    -D BOOST_ROOT=$LD_LIBRARY_PATH \
#    -D BOOST_LIBRARYDIR=$LD_LIBRARY_PATH \
    ..

RUN make -j $(nproc)