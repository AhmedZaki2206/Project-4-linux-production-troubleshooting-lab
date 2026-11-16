# Junior DevOps Interview Preparation

## Project summary — 60 seconds

**Arabic:** بنيت personal incident-response lab آمن باستخدام Docker Compose وNginx وFastAPI وnetwork toolbox. فيه 20 scenario: 17 داخل containers وثلاثة VM-only لأن routing وfirewall وSSH يحتاجون host-like environment. `lab.sh` يشغّل fault واحدة، يقدم hint، يتحقق من ظهور المشكلة ويعيد baseline. أضفت resource limits وCI للـShellCheck وBash وCompose وsafe smoke tests، بدون privileged containers أو destructive CI.

**English:** “I built a disposable Linux troubleshooting lab with Docker Compose, Nginx, FastAPI, and a diagnostic toolbox. It covers twenty incidents, with routing and SSH clearly separated as VM-only. A Bash controller safely injects one fault at a time, validates symptoms, and resets the environment. CI performs static and lightweight smoke validation without running resource-exhaustion tests.”

## Project summary — 5 minutes

ابدأ بالمشكلة: Junior يحتاج method وليس commands محفوظة. اشرح traffic من localhost إلى Nginx ثم Docker DNS ثم FastAPI. وضّح fault overrides، `.lab-state`، limits وsecurity boundaries. اختر مثال 502: symptom، logs، upstream test، root cause، config validation، recovery. ثم اشرح لماذا 10 و11 و19 VM-only، وما الذي لا تدعي أنه production. اختم بـCI وincident report.

## 40 Q&A

1. **ما الفرق بين symptom وroot cause؟** مختصر: 502 symptom؛ upstream port الخطأ root cause. تفصيل: اجمع evidence واربط causal chain قبل التغيير. **EN:** “A symptom is observable impact; the root cause is the condition that created it.”
2. **تبدأ incident إزاي؟** مختصر: impact ثم scope ثم evidence. تفصيل: لا تعمل restart فورًا لأنه قد يمسح evidence. **EN:** “I confirm impact, bound the scope, collect evidence, then form a hypothesis.”
3. **ليه Docker Compose؟** مختصر: reproducible disposable lab. تفصيل: services/network/limits في ملف versioned. **EN:** “Compose gives me a repeatable multi-service environment with controlled cleanup.”
4. **ليه مش production؟** مختصر: containers تشارك kernel والtraffic محلي. تفصيل: لا يوجد HA أو real users/SLOs. **EN:** “It is a learning simulation, not a production deployment.”
5. **وظيفة Nginx؟** مختصر: reverse proxy. تفصيل: يستقبل client ويوجه إلى backend service name. **EN:** “Nginx terminates the client connection and proxies requests to FastAPI.”
6. **502 معناه إيه؟** مختصر: gateway لم يحصل على upstream response صحيح. تفصيل: DNS/port/process/protocol محتمل. **EN:** “A 502 means the proxy could not obtain a valid upstream response.”
7. **503؟** مختصر: service unavailable. تفصيل: قد يكون intentional config أو no healthy capacity. **EN:** “A 503 indicates temporary unavailability, not necessarily a network failure.”
8. **Connection refused؟** مختصر: host reachable لكن لا listener أو reject. تفصيل: يختلف عن timeout. **EN:** “Refused usually means the TCP target is reachable but nothing accepts that port.”
9. **Timeout؟** مختصر: لم يصل رد في المهلة. تفصيل: filtering/routing/congestion ممكن. **EN:** “A timeout requires checking routing, filtering, and service latency.”
10. **تفحص port إزاي؟** مختصر: `ss -lntp` و`nc -vz`. تفصيل: افحص server listener ثم client path. **EN:** “I verify the listener locally and test the path from the caller.”
11. **`df` vs `du`؟** مختصر: filesystem allocation مقابل visible files. تفصيل: deleted-open files قد تفسر الفرق. **EN:** “df reports filesystem usage; du sums reachable directory entries.”
12. **inode exhaustion؟** مختصر: عدد files انتهى رغم وجود bytes. تفصيل: `df -i` ثم locate small-file explosion. **EN:** “Free space can remain while inode allocation is exhausted.”
13. **Memory pressure؟** مختصر: قارن working set بالlimit. تفصيل: available, OOM state, process RSS. **EN:** “I check limits, available memory, process RSS, and OOM evidence.”
14. **High CPU؟** مختصر: حدد process ومدة الاستهلاك. تفصيل: distinguish sustained load from short spike. **EN:** “I correlate process CPU with latency and container limits.”
15. **ليه limits؟** مختصر: bounded blast radius. تفصيل: تمنع exercise من استنزاف laptop/CI. **EN:** “Resource limits keep fault injection bounded.”
16. **Healthcheck؟** مختصر: machine-readable service health. تفصيل: liveness لا يساوي readiness دائمًا. **EN:** “A health check provides repeatable evidence, but its semantics must be defined.”
17. **Docker DNS؟** مختصر: service name resolves داخل network. تفصيل: caller وtarget يجب أن يشتركا في network. **EN:** “Compose service discovery resolves service names on the shared Docker network.”
18. **تتحقق من DNS؟** مختصر: `getent`, `dig`, `nslookup`. تفصيل: قارن resolver config وquery result. **EN:** “I test both the system resolver path and direct DNS queries.”
19. **ليه `curl -v`؟** مختصر: يعرض مراحل الاتصال وheaders. تفصيل: يفرق DNS/connect/TLS/HTTP. **EN:** “Verbose curl separates connection setup from the HTTP response.”
20. **ليه `nginx -t`؟** مختصر: validate قبل reload. تفصيل: يمنع outage من syntax خاطئ. **EN:** “I validate configuration before applying it.”
21. **CrashLoop؟** مختصر: process يخرج وpolicy تعيده. تفصيل: افحص exit code وprevious logs وrestart count. **EN:** “I inspect the exit reason before changing the restart policy.”
22. **Logs ولا inspect؟** مختصر: logs application output؛ inspect runtime config/state. **EN:** “Logs explain behavior; inspect explains configured and runtime state.”
23. **Port mapping؟** مختصر: host port مختلف عن container port. تفصيل: inspect published mapping بدل assumption. **EN:** “I distinguish the published host port from the internal container port.”
24. **Permissions؟** مختصر: owner/group/mode. تفصيل: افحص `namei`, `stat` وكل parent. **EN:** “I verify ownership and every path component before chmod.”
25. **ليه مش `chmod 777`؟** مختصر: excessive access ويخفي التصميم الخطأ. **EN:** “777 violates least privilege and often masks the actual ownership issue.”
26. **Log rotation failure؟** مختصر: permission/path/config/disk. تفصيل: dry run ثم forced test في lab. **EN:** “I validate configuration, permissions, destination, and disk capacity.”
27. **Backup validation؟** مختصر: restore test أهم من archive existence. **EN:** “A backup is credible only after a successful restore test.”
28. **Idempotent reset؟** مختصر: تكراره يعطي baseline نفسه. **EN:** “An idempotent reset is safe to repeat and converges on the same baseline.”
29. **ليه incident واحدة؟** مختصر: يقلل confounding variables. **EN:** “One active fault keeps diagnosis attributable and reproducible.”
30. **ليه internal network؟** مختصر: يقلل exposure/Internet egress. **EN:** “The internal network limits accidental external connectivity.”
31. **`no-new-privileges`؟** مختصر: يمنع اكتساب privileges عبر exec. **EN:** “It prevents processes from gaining additional privileges.”
32. **`cap_drop: ALL`؟** مختصر: إزالة Linux capabilities غير المطلوبة. **EN:** “The services receive no ambient Linux capabilities they do not need.”
33. **ليه no Docker socket؟** مختصر: socket يعادل host-level control غالبًا. **EN:** “Mounting the Docker socket would dramatically expand the blast radius.”
34. **ليه routing VM-only؟** مختصر: يحتاج NET_ADMIN وhost-like stack. **EN:** “A VM models routing safely without granting containers dangerous capabilities.”
35. **ليه SSH VM-only؟** مختصر: lab containers ليست SSH hosts ولا systemd machines. **EN:** “A disposable VM gives an accurate SSH and systemd environment.”
36. **CI يشغل إيه؟** مختصر: syntax/lint/config/safe smoke. تفصيل: لا exhaustion. **EN:** “CI validates safe properties and excludes disruptive fault injection.”
37. **ShellCheck يفيد بإيه؟** مختصر: يجد quoting/control-flow bugs. **EN:** “ShellCheck catches common shell correctness and portability problems.”
38. **Least privilege في workflow؟** مختصر: `contents: read`. **EN:** “The validation workflow only receives read access to repository contents.”
39. **Incident report يحتوي إيه؟** مختصر: impact/timeline/evidence/root cause/fix/verification/prevention. **EN:** “I document evidence and causal reasoning, not only the final command.”
40. **إيه اللي هتحسنه؟** مختصر: أكثر automated recovery checks وVM provisioning آمن. **EN:** “I would add isolated VM automation and broader recovery assertions while preserving safety.”

## Readiness checklist

- أشرح request path بدون README.
- أشخّص 5 incidents متتالية وأعيد baseline.
- أفرق refusal/timeout/502/503.
- أشرح `df/du/df -i`, CPU وmemory evidence.
- أشرح security boundaries وسبب VM-only.
- لا أدعي production results أو tests لم تُشغل.
