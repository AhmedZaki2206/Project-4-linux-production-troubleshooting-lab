# Step-by-Step Guide — من جهاز Windows نظيف إلى Lab شغال

## 1. تثبيت WSL2

**الهدف:** تشغيل Bash وLinux tools على Windows 11 بدون تعديل نظامك الأساسي.

افتح PowerShell كـAdministrator:

```powershell
wsl --install -d Ubuntu
wsl --update
wsl --status
```

**Expected:** يظهر WSL version 2 وUbuntu. لو virtualization مقفولة، فعّلها من BIOS وWindows Features ثم restart.

## 2. Git وDocker Desktop

ثبت Git for Windows وDocker Desktop، ثم من Docker Desktop فعّل `Use WSL 2 based engine` وWSL integration لـUbuntu. داخل Ubuntu:

```bash
git --version
docker version
docker compose version
```

لو ظهر `permission denied` أو daemon غير متاح، افتح Docker Desktop وانتظر Engine. لا تستخدم `sudo chmod` على Docker socket.

## 3. تنزيل المشروع

```bash
cd ~
git clone https://github.com/AhmedZaki2206/Project-4-linux-production-troubleshooting-lab.git
cd Project-4-linux-production-troubleshooting-lab
cp .env.example .env
```

`compose.yaml` يبني FastAPI وtoolbox ويشغّل Nginx. `.env` إعداد محلي وممنوع من Git.

## 4. تشغيل baseline

```bash
docker compose config
docker compose up -d --build
docker compose ps
curl -i http://127.0.0.1:8080/health/ready
```

**Expected:** HTTP `200` و`{"status":"ready"}`. لو port مستخدم: `ss -lntp | grep 8080` ثم أوقف التطبيق المالك أو استخدم `HOST_PORT=8081 docker compose up -d`.

## 5. فهم الملفات

- `app/main.py`: endpoints وstructured stdout logging.
- `app/Dockerfile`: multi-stage, non-root image وhealthcheck.
- `nginx/nginx.conf`: reverse proxy إلى `backend:8000`.
- `toolbox/Dockerfile`: أدوات DNS/network diagnostics.
- `compose.yaml`: network, limits, volumes, security boundaries.
- `lab.sh`: واجهة آمنة وحالة incident واحدة.
- `scripts/incident-action.sh`: fault injection وverification وreset.
- `faults/`: Compose overrides وNginx configs المعطوبة المقصودة.
- `tests/`: syntax, lint, config وsafe smoke tests.

## 6. تنفيذ incident كاملة

```bash
./lab.sh list
./lab.sh start 13
docker compose ps
curl -i http://127.0.0.1:8080/
docker compose logs --tail=50 proxy
docker compose exec toolbox nc -vz backend 8000
./lab.sh hint 13
./lab.sh verify 13
```

الـgoal هو تمييز **symptom** (`502`) عن **root cause** (upstream port خطأ). نفّذ الحل يدويًا حسب استنتاجك، اختبر recovery، اكتب report، ثم:

```bash
./lab.sh reset 13
curl -fsS http://127.0.0.1:8080/health/ready
```

## 7. تفسير الأدوات

- `top` و`ps aux --sort=-%cpu`: process CPU/memory؛ `ps` snapshot بينما `top` live.
- `free -m`: RAM وavailable memory؛ لا تعتبر cache وحده مشكلة.
- `df -h`: filesystem blocks؛ `du -sh PATH`: الملفات المرئية داخل path.
- `df -i`: inode consumption؛ disk قد يفشل رغم وجود bytes.
- `ss -lntp`: listening TCP sockets؛ `-l` listening، `-n` numeric، `-t` TCP، `-p` process.
- `ip addr` و`ip route`: interfaces وroutes؛ لا تعدل host route لهذا المشروع.
- `curl -v`: DNS/connect/request/response evidence.
- `dig` و`nslookup`: DNS query، بينما `getent hosts` يستخدم system resolver path.
- `chmod` يغير mode و`chown` يغير ownership؛ افحص بـ`stat` أولًا.
- `docker compose logs` stdout/stderr، و`docker inspect` runtime state/config.
- `nginx -t` يتحقق من syntax قبل reload.
- `systemctl` و`journalctl` فقط داخل VM حقيقية تعمل بـsystemd، وليسا بديلًا صحيحًا داخل containers هنا.

## 8. Rebuild من الصفر وcleanup

```bash
./lab.sh reset-all
docker compose down --remove-orphans
docker compose build --no-cache
docker compose up -d
./tests/run-safe-tests.sh
```

لحذف log volume اختياريًا: `docker volume rm linux-troubleshooting-lab-logs`. الأمر يحذف evidence؛ صدّر المطلوب أولًا.

## 9. Final practical assessment

اختار خمسة IDs عشوائيًا بدون فتح `SOLUTIONS.md`:

```bash
shuf -n 5 <(cut -f1 incidents/catalog.tsv)
mkdir -p evidence/assessment
```

لكل ID: start، سجل start time، symptoms، 3 commands على الأقل، hypothesis، manual fix، recovery evidence، reset. استخدم `INCIDENT_REPORT_TEMPLATE.md`. تعتبر Junior-ready عندما تشرح causal chain، تختار command مناسب، لا تغيّر host، وتستطيع إعادة baseline خمس مرات.
