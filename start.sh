#!/usr/bin/env /bin/bash

BUILDKITE_AGENT_NAME=${BUILDKITE_AGENT_NAME:-`hostname -a`}
BUILDKITE_AGENT_CONFIG=${BUILDKITE_AGENT_CONFIG:-"/etc/buildkite-agent/buildkite-agent.cfg"}
BUILDKITE_AGENT_BIN=${BUILDKITE_AGENT_BIN:-"/usr/bin/buildkite-agent"}
BUILDKITE_AGENT_DEBUG=true
BUILDKITE_AGENT_BUILD_PATH=/build
BUILDKITE_AGENT_DATA_PATH=/data
BUILDKITE_AGENT_SSHKEY_SRC=/data/.ssh
BUILDKITE_AGENT_SSHKEY_DST=${BUILDKITE_AGENT_SSHKEY_DST:-"$HOME/.ssh"}
ETCD_START=${ETCD_START:-"true"}

if [ "$BUILDKITE_AGENT_DEBUG" = "true" ]; then
        echo "---"
        env
        echo "---"
fi

if [ "$BUILDKITE_AGENT_TOKEN" = "" ]; then
        echo "Missing BUILDKITE_AGENT_TOKEN"
        exit 1
fi

if [ "$BUILDKITE_AGENT_NAME" = "" ]; then
        echo "Missing BUILDKITE_AGENT_NAME"
        exit 1
fi

if [ ! -e "$BUILDKITE_AGENT_BIN" ]; then
	echo "Missing $BUILDKITE_AGENT_BIN"
	exit 1
fi

function run
{
        echo "$0 $*"
        eval $*
}

run ls -la $BUILDKITE_AGENT_DATA_PATH
run mkdir -p $BUILDKITE_AGENT_SSHKEY_DST
if [ -e "$BUILDKITE_AGENT_SSHKEY_SRC/id_rsa" ]; then
        run rm -rf $BUILDKITE_AGENT_SSHKEY_DST
        run cp -R $BUILDKITE_AGENT_SSHKEY_SRC $BUILDKITE_AGENT_SSHKEY_DST
        run chmod 700 $BUILDKITE_AGENT_SSHKEY_DST
        run chmod 600 $BUILDKITE_AGENT_SSHKEY_DST/id_rsa
        run chmod 644 $BUILDKITE_AGENT_SSHKEY_DST/id_rsa.pub
else
        echo "generate ssh-key"
        ssh-keygen -t rsa -b 4096 -C "$BUILDKITE_AGENT_NAME" -f $BUILDKITE_AGENT_SSHKEY_DST/id_rsa -N ''
	run cp -R $BUILDKITE_AGENT_SSHKEY_DST $BUILDKITE_AGENT_SSHKEY_SRC
fi

if [ ! -e "$BUILDKITE_AGENT_SSHKEY_DST/id_rsa" ]; then
        echo "$BUILDKITE_AGENT_SSHKEY_DST/id_rsa does not exists"
        exit 1
fi

echo "---"
run cat $BUILDKITE_AGENT_SSHKEY_DST/id_rsa
echo "---"

if [ "$ETCD_START" = "true" ]; then
	run etcd --data-dir=$BUILDKITE_AGENT_DATA_PATH/etcd &
fi

run $BUILDKITE_AGENT_BIN start
