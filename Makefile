.PHONY: build build-and-push

build:
	docker buildx build --platform linux/amd64,linux/arm64 -t neoshrew/golang_sts_get_caller_identity:latest .

build-and-push:
	$(eval TIMESTAMP := $(shell date +%Y-%m-%d-%H%M%S))
	docker buildx build --platform linux/amd64,linux/arm64 \
		-t neoshrew/golang_sts_get_caller_identity:latest \
		-t neoshrew/golang_sts_get_caller_identity:$(TIMESTAMP) \
		--push .
	@echo "Pushed neoshrew/golang_sts_get_caller_identity:latest"
	@echo "Pushed neoshrew/golang_sts_get_caller_identity:$(TIMESTAMP)"
