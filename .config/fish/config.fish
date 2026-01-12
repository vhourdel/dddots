if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Load direnv hook
direnv hook fish | source

# Point GOPATH to our go sources
set -gx GOPATH "$HOME/go"

# Point DATADOG_ROOT to ~/dd symlink
set -gx DATADOG_ROOT "$HOME/dd"

# Tell the devenv vm to mount $GOPATH/src rather than just dd-go
set -gx MOUNT_ALL_GO_SRC 1

# store key in the login keychain instead of aws-vault managing a hidden keychain
set -gx AWS_VAULT_KEYCHAIN_NAME login

# tweak session times so you don't have to re-enter passwords every 5min
set -gx AWS_SESSION_TTL 24h
set -gx AWS_ASSUME_ROLE_TTL 1h

# Helm switch from storing objects in kubernetes configmaps to
# secrets by default, but we still use the old default.
set -gx HELM_DRIVER configmap

# Go 1.16+ sets GO111MODULE to off by default with the intention to
# remove it in Go 1.18, which breaks projects using the dep tool.
# https://blog.golang.org/go116-module-changes
set -gx GO111MODULE auto
# Configure Go to pull go.ddbuild.io packages.
set -gx GONOSUMDB "github.com/DataDog,go.ddbuild.io"
set -gx GOPRIVATE
set -gx GOPROXY "https://depot-read-api-go.us1.ddbuild.io/magicmirror/magicmirror/@current/|https://depot-read-api-go.us1.ddbuild.io/magicmirror/magicmirror/@current/|https://depot-read-api-go.us1.ddbuild.io/magicmirror/testing/@current/"

mise activate fish | source
