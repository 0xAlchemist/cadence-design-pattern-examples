all: deploy

.PHONY: setup
setup:
	go run ./demo/setup/main.go

.PHONY: deploy
deploy: setup
	flow project deploy