FROM alpine:latest

ENV SHARE=""
ENV USER=""
ENV USER_PASSWORD=""

ENV GLOBALS_WORKGROUP="DEFAULTWG"
ENV GLOBALS_SERVER_STRING="Simple SAMBA server by r4263(github.com/r4263)"
ENV GLOBALS_NETBIOS_NAME="samba"
ENV GLOBALS_SECURITY="user"
ENV GLOBALS_MAP_TO_GUEST="Bad User"
ENV GLOBALS_LOG_FILE="/var/log/samba/log.%m"
ENV GLOBALS_MAX_LOG_SIZE="1024"
ENV GLOBALS_LOAD_PRINTERS="no"
ENV GLOBALS_DNS_PROXY="no"
ENV GLOBALS_SMB_PORT="445"
ENV GLOBALS_LOCAL_MASTER="yes"
ENV GLOBALS_PREFERRED_MASTER="yes"
ENV GLOBALS_OS_LEVEL="33"
ENV GLOBALS_PASSDB_BACKEND="tdbsam"
ENV GLOBALS_ENCRYPT_PASSWORDS="yes"
ENV GLOBALS_SERVER_MIN_PROTOCOL="NT1"
ENV GLOBALS_CLIENT_MIN_PROTOCOL="NT1"
ENV GLOBALS_NTLM_AUTH="yes"
ENV GLOBALS_LOG_LEVEL="3"

ENV SHARE_COMMENT="simple-smb folder sharing"
ENV SHARE_PATH="/srv/samba/share"
ENV SHARE_BROWSEABLE="yes"
ENV SHARE_READ_ONLY="no"
ENV SHARE_WRITABLE="yes"

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

RUN apk update && \
    apk add --no-cache samba shadow

RUN rm -rf /etc/samba/smb.conf
RUN mkdir /srv/samba && mkdir /srv/samba/share && mkdir -p /var/lib/samba

EXPOSE 445 139 137/udp 138/udp

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]