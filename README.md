# Simple-SMB
 Fast and simple samba server compatible with SMBv1

 This image uses Alpine Linux as the base OS to be as light as possible(i believe it can be enhanced). Only uses 10-30MB of RAM in plain usage(Different environments and usages may vary it's memory consumption).

 Used to deploy as fast as possible a samba sharing for public/private sharing purposes. Originally designed to share a folder to PS2's OPL, but can be used to share anything with a quick deploy time with no complications.

 <h5>PS: as you'll see in the next sessions, it's not the best solution to pass the users passwords as an env variable, but this project is meant to development/controlled environemnts only to avoid password leaks or any kind of problem.<h5>

<br><br>

## Examples
 Share a folder publicly: <code>docker run -d -it -e SHARE="share_name_here" -v </path/to/local/folder>:/srv/samba/share -p 445:445 -p 139:139 -p 138:138 -p 137:137 --name <container_name> mayconjung/simple-smb:rev1</code>

 Share a folder private users: <code>docker run -d -it -e SHARE="share_name_here" -e USER="user" -e USER_PASSWORD="password" -v </path/to/local/folder>:/srv/samba/share -p 445:445 -p 139:139 -p 138:138 -p 137:137 --name <container_name> mayconjung/simple-smb:rev1</code>

 Share a folder a list of users: <code>docker run -d -it -e SHARE="share_name_here" -e USER="user1,user2,user3" -e USER_PASSWORD="pass1,pass2,pass3" -v </path/to/local/folder>:/srv/samba/share -p 445:445 -p 139:139 -p 138:138 -p 137:137 --name <container_name> mayconjung/simple-smb:rev1</code>

<br><br>

## Available volume mounts
<h3>/srv/samba/share</h3>
<code>Default share folder, can be changed by setting SHARE_PATH env variable. - REQUIRED -</code>
<br>

<h3>/etc/samba OR /etc/samba/smb.conf</h3>
<code>Mount this folder/file if you want to use a custom config.</code>
<br>
<h3>/var/log/samba</h3>
<code>Samba logs folder, can me set by GLOBALS_LOG_FILE env variable.</code>
<br>
<h3>/srv/lib/samba</h3>
<code>tdbsam's database folder, not tested.</code>

<br><br>

## Ports
The used ports are the default ports for samba and netbios, which are: <strong>445, 137, 138</strong> and strong>139</strong>. Only the 445 and 139 are strictly needed for correct use.

<br><br>

## Environment variables
<h2>Container's scope specific variables</h2>
<h4>SHARE</h4> 
<code>share's desired name</code>

<h4>USER</h4>
<code>a user OR a list of users separated by comma to authenticate(if blank, defaults to a public share, allowing guests to see and manipulate files the files)</code>

<h4>USER_PASSWORD</h4>
<code>if the above variable is set, it need to have the exact same amount of passwords to each user, throwing an error if the length does not match.</code>

<h2>SAMBA VARIABLES</h2>
!!! MARKDOWN TO BE IMPLEMENTED !!!
<h3>GLOBALS</h3>
GLOBALS_WORKGROUP<br>
GLOBALS_SERVER_STRING<br>
GLOBALS_NETBIOS_NAME<br>
GLOBALS_SECURITY<br>
GLOBALS_MAP_TO_GUEST<br>
GLOBALS_LOG_FILE<br>
GLOBALS_MAX_LOG_SIZE<br>
GLOBALS_LOAD_PRINTERS<br>
GLOBALS_DNS_PROXY<br>
GLOBALS_SMB_PORT<br>
GLOBALS_LOCAL_MASTER<br>
GLOBALS_PREFERRED_MASTER<br>
GLOBALS_OS_LEVEL<br>
GLOBALS_PASSDB_BACKEND<br>
GLOBALS_ENCRYPT_PASSWORDS<br>
GLOBALS_SERVER_MIN_PROTOCOL<br>
GLOBALS_NTLM_AUTH<br>
GLOBALS_LOG_LEVEL<br>

<h3>SHARE VARIABLES</h3>
SHARE_COMMENT<br>
SHARE_PATH<br>
SHARE_BROWSEABLE<br>
SHARE_READ_ONLY<br>
SHARE_WRITABLE<br>