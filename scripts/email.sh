#!/bin/bash

SENDGRID_API_KEY="SG.Aptvib0kRtWvtB2cOGKt2Q.DhAUStpwDbsOtUvZaUlj5ikAqFb541lic11HnWsT0ic"
EMAIL_TO="ryanpeter110@gmail.com"
FROM_EMAIL="no-reply@calcottech.com"
FROM_NAME="calcot"
SUBJECT="Hi"

bodyHTML="<p>Email body goes here</p>"

maildata='{"personalizations": [{"to": [{"email": "'${EMAIL_TO}'"}]}],"from": {"email": "'${FROM_EMAIL}'",
	"name": "'${FROM_NAME}'"},"subject": "'${SUBJECT}'","content": [{"type": "text/html", "value": "'${bodyHTML}'"}]}'

curl --request POST \
  --url https://api.sendgrid.com/v3/mail/send \
  --header 'Authorization: Bearer '$SENDGRID_API_KEY \
  --header 'Content-Type: application/json' \
  --data "'$maildata'"