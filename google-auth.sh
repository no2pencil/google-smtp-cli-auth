#!/bin/bash

# https://stackoverflow.com/questions/11046135/how-to-send-email-using-simple-smtp-commands-via-gmail

# Asks for a username and password, then spits out the encoded value for
# use with authentication against SMTP servers.

email=$(cat user.txt)
password=$(cat pass.txt)

if [ $1 ]; then
  email=$(echo $1)
fi

if [ $2 ]; then
  password=$(echo $2)
fi

TEXT="\0$email\0$password"
BASE64=$(echo -ne $TEXT | base64)

#sleep 5
# Username and Password not accepted

fp_expect=$(which expect)

output=$(${fp_expect} -c '
log_user 0
spawn openssl s_client -connect smtp.gmail.com:465 -crlf -ign_eof
expect "220"
send "EHLO localhost\n"
expect "250-AUTH LOGIN PLAIN"
send "AUTH PLAIN\n"
expect "334"
send '"${BASE64}\n"'
expect "ccepted"
send "QUIT\n"
puts $expect_out(buffer)
')

echo ${output} | grep Accepted > /dev/null
if [ $? -eq 0 ]; then
  echo "OK"
else
  echo "CRIT"
fi
