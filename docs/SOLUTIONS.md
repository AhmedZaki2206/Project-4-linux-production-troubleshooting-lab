# Solutions — افتح بعد المحاولة

> حاول كل incident بنفسك أولًا. الحل المفيد يشرح causal chain، وليس command للحفظ.

| ID | Root cause and manual remediation |
|---|---|
| 01 | Python busy loop يستهلك CPU داخل limit. حدده بـ`ps/docker stats` ثم `pkill -f cpu-burn` أو أعد backend. |
| 02 | process حجز 90 MiB تحت 128 MiB limit. أوقف `memory-pressure` وراقب memory. |
| 03 | `/tmp/disk-full` ملأ tmpfs المحدود. احذفه فقط بعد إثباته بـ`du`; لا تحذف مسارات عامة. |
| 04 | 4000 files في `/tmp/inodes`. احذف directory المحددة ثم قارن `df -i`. |
| 05 | backend متوقف. افحص logs ثم `docker compose start backend` وانتظر healthy. |
| 06 | access log mode `000`. افحصه ثم أعد mode مناسبًا داخل lab أو reset. |
| 07 | project-owned Nginx مؤقت يحتل 8080. حدده ثم `docker rm -f linux-troubleshooting-lab-port-owner` وشغّل proxy. |
| 08 | `APP_MESSAGE` فارغ في override فيرجع app 500. أزل override وأعد baseline. |
| 09 | toolbox يستخدم resolver `127.0.0.1` الخطأ. أعده إلى Docker DNS عبر reset. |
| 10 | **VM-only:** default route خاطئ. من VM console أعد `ip route replace default via EXPECTED_GW`; القيم تعتمد على VM network. |
| 11 | **VM-only:** firewall rule تمنع application port. أثبت أن service تستمع محليًا ثم افحص rules، واحذف rule المحددة داخل VM فقط. |
| 12 | DNS موجود لكن backend stopped، لذلك TCP refused. شغّل backend وتحقق من listening/health. |
| 13 | Nginx يرسل إلى 9999 بدل 8000 فينتج 502. صحح upstream، نفذ `nginx -t` ثم أعد proxy. |
| 14 | active config يرجع 503 عمدًا. أعد config الأساسية واختبر status/body. |
| 15 | Nginx syntax غير صالح. شغّل `nginx -t`، قارن config الأساسية ثم reset/recreate. |
| 16 | backend command يخرج code 42 مع restart policy. أزل override وأعد container؛ تحقق أن RestartCount لا يزيد. |
| 17 | نفس resolver fault لكن الهدف container service discovery. أعد Docker DNS وتحقق بـ`nslookup backend`. |
| 18 | host publish على 8081 بدل 8080. اكتشفه بـ`docker compose port`; أعد `HOST_PORT=8080`. |
| 19 | **VM-only:** private key permissive أو public key غير صحيح. استخدم `chmod 700 ~/.ssh`, `chmod 600 key`, وافحص `ssh -vvv`; لا تعرض key. |
| 20 | log directory mode يمنع rotation/write. أعد ownership/mode المقصود داخل lab ثم نفذ write/rotation test. |

في كل الحالات شغّل health check، راجع logs الجديدة، ثم `./lab.sh reset ID`. الـreset هو recovery path مؤكد للمختبر، أما manual fix فهو المطلوب للتعلم.
