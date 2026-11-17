# Hands-on Labs — 20 Incidents

القاعدة لكل Lab: `./lab.sh start ID` ثم اجمع evidence قبل `hint`. `./lab.sh verify ID` يثبت وجود fault وليس أن الحل تم. بعد manual repair اختبر endpoint ثم `./lab.sh reset ID`.

| ID | Learning objective | Evidence and diagnosis | Recovery validation |
|---|---|---|---|
| 01 | ربط latency/process بـCPU | `docker stats`, `ps`, `top` | CPU يعود طبيعي وhealth 200 |
| 02 | فهم memory pressure وlimit | `free -m`, `ps`, `docker inspect` | process المسبب غير موجود وhealth 200 |
| 03 | التفرقة بين `df` و`du` | `df -h /tmp`, `du -sh /tmp/*` | مساحة `/tmp` متاحة |
| 04 | تشخيص inode exhaustion | `df -i`, `find /tmp/inodes -type f` | inode usage يعود baseline |
| 05 | تشخيص process متوقف | `compose ps`, backend logs | backend Running/healthy |
| 06 | قراءة mode/owner | `ls -l`, `stat` على access log | Nginx يستطيع كتابة log |
| 07 | تحديد مالك port | `ss -lntp`, `docker ps` | proxy يملك localhost:8080 |
| 08 | ربط config بـHTTP 500 | `inspect`, `curl -v`, logs | `/` يرجع 200 وmessage |
| 09 | DNS resolver evidence | `cat /etc/resolv.conf`, `nslookup` | `backend` resolves |
| 10 | فهم default gateway | **VM-only:** `ip route`, `ping gateway` | route صحيح وping يعمل |
| 11 | تمييز filtered/closed | **VM-only:** firewall rule داخل VM و`nc`/`ss` | restore VM firewall ثم الاتصال يعمل |
| 12 | DNS يعمل لكن TCP refused | `nslookup`, `nc`, `compose ps` | backend يستقبل 8000 |
| 13 | تحليل 502 upstream | Nginx error log، `nc backend 8000` | proxy يرجع 200 |
| 14 | تفسير 503 المقصود | `curl -i`, `nginx -T` | 503 يختفي و200 يعود |
| 15 | config validation أولًا | `nginx -t`, proxy logs | `nginx -t` success |
| 16 | crash loop/restart count | `ps`, `inspect`, logs | restart count ثابت وhealthy |
| 17 | container service discovery | `getent`, `nslookup backend` | Docker DNS يعمل |
| 18 | published vs container port | `docker compose port proxy 8080` | localhost:8080 يعمل |
| 19 | SSH permissions/auth | **VM-only:** `stat ~/.ssh`, `ssh -vvv` | key auth داخل VM فقط |
| 20 | log rotation permissions | `stat /var/log/nginx`, write test | directory writable للمالك الصحيح |

## VM-only safety

أنشئ Ubuntu VM disposable على private/NAT network. خذ snapshot قبل lab. في 10 غيّر route داخل VM فقط. في 11 أضف firewall rule محددة للـVM فقط مع console access. في 19 استخدم user/key تجريبيين داخل VM فقط. لا تعدّل Windows/WSL route/firewall/SSH، ولا تستخدم production key.

## Evidence checklist

احفظ command، relevant output، timestamp، container/VM name، hypothesis، manual fix، recovery check وreset check. لا تحفظ token أو private key.
