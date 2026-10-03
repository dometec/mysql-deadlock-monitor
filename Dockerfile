FROM perl:stable-bookworm
COPY command_exp_wrapper.sh ./

# Percona Distribution for MySQL 8.4 LTS repository: provides both the 8.4-aligned
# MySQL client (percona-server-client) and the matching Percona Toolkit, kept
# updatable via apt instead of vendoring a pinned .deb.
RUN apt-get update \
&& apt-get install -y --no-install-recommends wget gnupg2 ca-certificates lsb-release \
&& wget -qO /tmp/percona-release.deb https://repo.percona.com/apt/percona-release_latest.generic_all.deb \
&& dpkg -i /tmp/percona-release.deb \
&& percona-release enable-only pdps-84-lts release \
&& apt-get update \
&& apt-get install -y --no-install-recommends \
   percona-toolkit \
   percona-server-client \
   libdbi-perl \
   libdbd-mysql-perl \
   libterm-readkey-perl \
   libio-socket-ssl-perl \
   expect \
&& rm -rf /var/lib/apt/lists/* /tmp/percona-release.deb \
&& mkdir logs && chmod +x command_exp_wrapper.sh
CMD ["./command_exp_wrapper.sh"]
