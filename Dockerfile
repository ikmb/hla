FROM nfcore/base
LABEL authors="Marc Hoeppner" \
      description="Docker image containing all requirements for HLA pipeline"

COPY environment.yml /
RUN conda env create -f /environment.yml && conda clean -a
ENV PATH /opt/conda/envs/hla-1.6/bin:/opt/hisat-genotype:/opt/hisat-genotype/hisat2:/opt/hlascan/:$PATH
ENV PYTHONPATH /opt/hisat-genotype/hisatgenotype_modules:$PYTHONPATH

# Fix Debian Buster archived repositories
RUN sed -i 's/deb.debian.org/archive.debian.org/g' /etc/apt/sources.list && \
    sed -i 's|security.debian.org|archive.debian.org|g' /etc/apt/sources.list && \
    sed -i 's/^deb /deb [trusted=yes] /' /etc/apt/sources.list

RUN apt-get -y update && \
    apt-get -y install --no-install-recommends \
    make wget git gcc g++ openssl zlib1g-dev libyaml-dev xml2 libjson-c-dev libssl-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN cd /opt && git clone --recurse-submodules https://github.com/DaehwanKimLab/hisat-genotype \
    && cd hisat-genotype/hisat2 && make -j2

RUN cd /opt && mkdir hlascan && cd hlascan && wget https://github.com/SyntekabioTools/HLAscan/releases/download/v2.1.4/hla_scan_r_v2.1.4 && mv hla_scan_r_v2.1.4 hla_scan && chmod +x hla_scan

RUN cd /opt && wget https://cache.ruby-lang.org/pub/ruby/3.2/ruby-3.2.2.tar.gz && tar -xvf ruby-3.2.2.tar.gz && cd ruby-3.2.2 && ./configure && make && make install
RUN cd /opt && rm -Rf ruby*

RUN gem install prawn
RUN gem install prawn-table
RUN gem install pdf-reader
RUN gem install rubyXL
RUN gem install json

