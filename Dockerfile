FROM nfcore/base
LABEL authors="Marc Hoeppner" \
      description="Docker image containing all requirements for HLA pipeline"

COPY environment.yml /
RUN conda env create -f /environment.yml && conda clean -a
ENV PATH /opt/conda/envs/hla-1.0/bin:/opt/hisat-genotype:/opt/hisat-genotype/hisat2:/opt/hlascan/$PATH
ENV PYTHONPATH /opt/hisat-genotype/hisatgenotype_modules:$PYTHONPATH

RUN apt-get -y update && apt-get -y install make wget git g++ ruby-full ruby-dev

RUN cd /opt && git clone --recurse-submodules https://github.com/DaehwanKimLab/hisat-genotype \
	&& cd hisat-genotype/hisat2 && make -j2

RUN cd /opt && mkdir hlascan && cd hlascan && wget https://github.com/SyntekabioTools/HLAscan/releases/download/v2.1.4/hla_scan_r_v2.1.4 && mv hla_scan_r_v2.1.4 hla_scan

RUN gem install json
RUN gem install prawn
RUN gem install prawn-table
