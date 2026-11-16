.PHONY: up down status test reset shellcheck
up:
	docker compose up -d --build
down:
	docker compose down --remove-orphans
status:
	./lab.sh status
test:
	./tests/run-safe-tests.sh
reset:
	./lab.sh reset-all
shellcheck:
	shellcheck lab.sh scripts/*.sh tests/*.sh
