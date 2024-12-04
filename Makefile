.PHONY: build create start root update restart

CONTAINER_NAME=hubtest
CONTAINER_CONFIG='./\#container'
CONTAINER_BRIDGE=incusbr0
CONTAINER_IP=10.10.1.33
HOST_IP=10.10.1.1

build:
	nixos-rebuild build --flake .#container

create:
	sudo nixos-container create ${CONTAINER_NAME} \
		--flake ${CONTAINER_CONFIG} \
		--bridge ${CONTAINER_BRIDGE} \
		--local ${CONTAINER_IP} --host-address ${HOST_IP}

start:
	sudo nixos-container start ${CONTAINER_NAME}

root:
	sudo nixos-container root-login ${CONTAINER_NAME}

update:
	sudo nixos-container update ${CONTAINER_NAME} --flake ${CONTAINER_CONFIG}

restart:
	sudo nixos-container restart ${CONTAINER_NAME}
