
#!/bin/bash

#Praktisches Skript für alle mydealerz. Am besten diese Codezeilen mit crontab -e jede Minute ausführen lassen (siehe: https://www.linuxwiki.de/crontab)
#Die folgenden Zeilen prüfen dann jede Minute (oder von mir aus Sekunde) ob es einen neuen Preisfehler-Deal gibt und schickt dann eine Telegram-Nachricht mit dem Link raus
#So ist es nun möglich tatsächlich auch _rechtzeitig_ über Preisfehler informiert zu werden und nicht erst ~10 Minuten später (beim ersten ausführen wird eine Preisfehler-Nachricht verschickt da eine Referenz fehlt, ist aber völlig normal)

touch .tmp_file_lastknowndeal
last_deal=$(cat .tmp_file_lastknowndeal)
sleep 1
#wellp, thats a long pipe
wget -qO- https://www.mydealz.de/search?q=Preisfehler -O - | grep -Eo "(http|https)://[a-zA-Z0-9./?=_-]*" | awk '!seen[$0]++' | grep '/deals/' |  head -2 | tail -1 > .tmp_file_lastknowndeal
new_deal=$(cat .tmp_file_lastknowndeal)
sleep 1
if [ "$last_deal" != "$new_deal" ]; then
        #new deal! telegram action in 3...2...1...
        #https://core.telegram.org/bots/api
        TOKEN=<TOKEN<
        CHAT_ID=<CHAT_ID>
        URL="https://api.telegram.org/bot$TOKEN/sendMessage"
        curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="Preisfehler! $new_deal"
fi