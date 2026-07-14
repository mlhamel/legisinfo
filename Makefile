.PHONY: help run docker-run

# Source for the legisinfo-server package.
# By default, points to the sibling directory. Can be overridden with a git URL:
# make run LEGISINFO_SERVER_SOURCE=git+https://github.com/mlhamel/legisinfo-server.git
LEGISINFO_SERVER_SOURCE ?= ../legisinfo-server
DOCKER_IMAGE ?= legisinfo-server:latest

help:
	@echo "Available commands:"
	@echo "  run        - Ephemerally fetch, install and run the API server using uv"
	@echo "  docker-run - Run the API server via Docker mounting current directory as data"

run:
	@if echo "$(LEGISINFO_SERVER_SOURCE)" | grep -q "git+"; then \
		echo "Fetching and running from remote: $(LEGISINFO_SERVER_SOURCE)..."; \
		LEGISINFO_DATA_PATH=$$(pwd) uv run --with "legisinfo-server @ $(LEGISINFO_SERVER_SOURCE)" -- uvicorn legisinfo_server.main:app --host 0.0.0.0 --port 8000; \
	else \
		LEGISINFO_DATA_PATH=$$(pwd) uv run --no-cache --with "legisinfo-server @ file://$$(realpath $(LEGISINFO_SERVER_SOURCE))" -- uvicorn legisinfo_server.main:app --host 0.0.0.0 --port 8000; \
	fi

docker-run:
	@echo "Running API server container mounting current directory..."
	docker run --rm -it -p 8000:8000 -v $$(pwd):/data -e LEGISINFO_DATA_PATH=/data $(DOCKER_IMAGE)
