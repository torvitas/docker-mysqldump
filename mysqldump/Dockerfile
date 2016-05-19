FROM centos:7
MAINTAINER Sascha Marcel Schmidt <docker@saschaschmidt.net>

RUN yum update -y && \
    yum install openssh-clients mariadb -y && \
    yum clean all

COPY entrypoint.sh /usr/local/bin/entrypoint
RUN chmod a+x /usr/local/bin/entrypoint

VOLUME ["/var/dumps/", "/root/.ssh/"]
ENTRYPOINT ["/usr/local/bin/entrypoint"]
CMD ["/bin/true"]
