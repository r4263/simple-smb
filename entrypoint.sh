#!/bin/sh

config_file="/etc/samba/smb.conf"

# Create shared folder
mkdir -p "$SHARE_PATH"

# Add default Samba user and group
useradd -m -s /sbin/nologin sambauser
groupadd sambagroup
usermod -aG sambagroup sambauser

# Verify required environment variables
if [ -z "$SHARE" ]; then
  echo "The SHARE environment variable is required to run this container!"
  exit 1
fi

# Helper function to add configurations to smb.conf
add_config() {
  local var_name=$1
  local var_value=$2

  var_value=$(echo "$var_value" | xargs)
  if [ -z "$var_value" ]; then
    echo "   # $var_name =" >> "$config_file"
  else
    echo "   $var_name = $var_value" >> "$config_file"
  fi
}

# Samba configuration function
configure_smb() {
    echo "[global]" > "$config_file"
    add_config "workgroup" "$GLOBALS_WORKGROUP"
    add_config "server string" "$GLOBALS_SERVER_STRING"
    add_config "netbios name" "$GLOBALS_NETBIOS_NAME"
    add_config "security" "$GLOBALS_SECURITY"
    add_config "log file" "$GLOBALS_LOG_FILE"
    add_config "max log size" "$GLOBALS_MAX_LOG_SIZE"
    add_config "load printers" "$GLOBALS_LOAD_PRINTERS"
    add_config "dns proxy" "$GLOBALS_DNS_PROXY"
    add_config "smb ports" "$GLOBALS_SMB_PORT"
    add_config "local master" "$GLOBALS_LOCAL_MASTER"
    add_config "preferred master" "$GLOBALS_PREFERRED_MASTER"
    add_config "os level" "$GLOBALS_OS_LEVEL"
    add_config "server min protocol" "$GLOBALS_SERVER_MIN_PROTOCOL"
    # add_config "client min protocol" "$GLOBALS_CLIENT_MIN_PROTOCOL"
    add_config "ntlm auth" "$GLOBALS_NTLM_AUTH"
    add_config "log level" "$GLOBALS_LOG_LEVEL"

    if [ -z "$USER" ]; then
        add_config "map to guest" "$GLOBALS_MAP_TO_GUEST"
    else
        add_config "passdb backend" "$GLOBALS_PASSDB_BACKEND"
    fi

    echo -e "\n[$SHARE]" >> "$config_file"

    add_config "comment" "$SHARE_COMMENT"
    add_config "path" "$SHARE_PATH"
    add_config "browseable" "$SHARE_BROWSEABLE"
    add_config "writable" "$SHARE_WRITABLE"
    add_config "read only" "$SHARE_READ_ONLY"

    if [ -z "$USER" ]; then
        add_config "public" "yes"
        add_config "guest ok" "yes"
        add_config "guest only" "yes"
        add_config "create mask" "0666"
        add_config "directory mask" "0777" 
        # add_config "force user" "nobody"
        # add_config "force group" "nogroup"
    else
        add_config "valid users" "@sambagroup"
        add_config "guest ok" "no"
        add_config "create mask" "0660"
        add_config "directory mask" "0770" 
        # add_config "force user" "sambauser"
        # add_config "force group" "sambagroup"
    fi

    # add_config "force create mode" "0660"
    # add_config "force directory mode" "0770"
}

# Use the external config file if provided, otherwise configure
if [ -f "$config_file" ]; then
    echo "Using existing config file..."
else
    echo "Generating Samba configuration..."
    configure_smb
    echo "Configuration complete."
fi

USERS=$(echo "$USER" | tr ',' ' ')
PASSWORDS=$(echo "$USER_PASSWORD" | tr ',' ' ')

USER_COUNT=$(echo "$USERS" | wc -w)
PASSWORD_COUNT=$(echo "$PASSWORDS" | wc -w)

if [ "$USER_COUNT" -ne "$PASSWORD_COUNT" ]; then
    echo "ERROR: The number of users and passwords does not match."
    exit 1
fi

if [ -z "$USER" ]; then
    chmod -R 0777 "$SHARE_PATH"
    chown -R nobody:nogroup "$SHARE_PATH"
else
    chmod -R 0770 "$SHARE_PATH"
    chown -R sambauser:sambagroup "$SHARE_PATH"
    (echo "sambauser"; echo "sambauser") | smbpasswd -s -a sambauser
fi

for user in $USERS; do
    echo -e "\n###############################"
    password=$(paste -d' ' <(echo "$USERS" | tr ' ' '\n') <(echo "$PASSWORDS" | tr ' ' '\n') | grep "^$user " | cut -d' ' -f2)

    if ! id "$user" &>/dev/null; then
        useradd -m -s /sbin/nologin "$user"
        echo "User $user created."
    else
        echo "User $user already exists."
    fi

    usermod -aG sambagroup "$user"
    echo "User $user added to samba group."

    (echo "$password"; echo "$password") | smbpasswd -s -a "$user"
    echo "User $user added to Samba."
    echo -e "###############################\n"
done

{
    smbd -F -d 10 &
    smbd_pid=$!
    nmbd -F -d 10 &
    nmbd_pid=$!
    wait "$smbd_pid" "$nmbd_pid"
} > /dev/stdout 2>&1