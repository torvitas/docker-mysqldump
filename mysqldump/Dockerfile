FROM centos:7
MAINTAINER Sascha Marcel Schmidt <docker@saschaschmidt.net>

RUN yum update -y && \
    yum install openssh-clients mariadb sudo -y && \
    yum clean all

VOLUME ["/var/dumps/"]
ENTRYPOINT ["/usr/local/bin/entrypoint"]
CMD ["/bin/true"]

COPY entrypoint.sh /usr/local/bin/entrypoint
RUN chmod a+x /usr/local/bin/entrypoint
