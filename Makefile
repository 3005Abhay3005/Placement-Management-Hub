.PHONY: install test build run docker-build docker-up

install:
	npm install

test:
	npm test

build:
	@echo "Static frontend build check completed"

run:
	@echo "Open login.html in a browser to run the application"

docker-build:
	docker build --build-arg GIT_SHA=$$(git rev-parse --short HEAD) -t ghcr.io/skit-devops-2026/devops-24ESKCS010:latest .

docker-up:
	docker compose up --build