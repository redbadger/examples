COLOR ?= always # Valid COLOR options: {always, auto, never}
CARGO = cargo --color $(COLOR)
TARGET = target/wasm32-unknown-unknown
DEBUG = $(TARGET)/debug
RELEASE = $(TARGET)/release
KEYDIR ?= .keys
VERSION = $(shell cargo metadata --no-deps --format-version 1 | jq -r '.packages[].version')
CAPABILITIES = -c wasmcloud:keyvalue -c wasmcloud:logging -c wasmcloud:httpserver

.PHONY: all
all: setup-redis setup-nats build

.PHONY: setup-redis
setup-redis: 
	# exit code 0 if redis is already running on the assigned port
	docker run --rm --detach -p 6379:6379 --name todo-backend-store redis; exit 0

.PHONY: setup-nats
setup-nats: 
	# exit code 0 if nats is already running on the assigned ports
	docker run --rm --detach --name nats -p 4222:4222 -p 8222:8222 nats; exit 0

.PHONY: run
run: front middle back links

.PHONY: back
back:
	RUST_LOG=1 KVCACHE_NATS_URL="127.0.0.1" wasmcloud -m manifest_back.yaml &

.PHONY: middle
middle:
	RUST_LOG=1 KVCACHE_NATS_URL="127.0.0.1" wasmcloud -m manifest_middle.yaml &

.PHONY: front
front:
	RUST_LOG=1 KVCACHE_NATS_URL="127.0.0.1" wasmcloud -m manifest_front.yaml &

.PHONY: links
links:
	sleep 10 && TODO_ACTOR=$(shell wash claims inspect $(DEBUG)/todo_backend_s.wasm --output json | jq .module -r) \
	RUST_LOG=1 KVCACHE_NATS_URL="127.0.0.1" wasmcloud -m manifest_links.yaml &

.PHONY: build
build:
	@$(CARGO) build
	wash claims sign $(DEBUG)/todo_backend.wasm ${CAPABILITIES} --name "todo-backend" --ver $(VERSION) --rev 0
	
.PHONY: check
check:
	@$(CARGO) check

.PHONY: clean
clean: down
	@$(CARGO) clean

.PHONY: down
down:
	killall wasmcloud

.PHONY: doc
doc:
	@$(CARGO) doc

.PHONY: test
test: build
	@$(CARGO) test

.PHONY: update
update:
	@$(CARGO) update

.PHONY: release
release:
	@$(CARGO) build --release	
	wash claims sign $(RELEASE)/todo_backend.wasm ${CAPABILITIES} --name "todo-backend" --ver $(VERSION) --rev 0
