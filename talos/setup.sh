INSTALL_IMAGE=factory.talos.dev/installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.9.5
CLUSTER_NAME=talos-prod
CLUSTER_ENDPOINT=192.168.70.1 # should match the virtual ip in patches/network.patch
TANE_MAHUTA=192.168.70.11
TANGAROA=192.168.70.21
TAWHIRIMATEA=192.168.70.31

# Generate base config
talosctl gen secrets -o secrets.yaml
talosctl gen config $CLUSTER_NAME https://$CLUSTER_ENDPOINT:6443 --with-secrets secrets.yaml --install-image $INSTALL_IMAGE --force
talosctl machineconfig patch controlplane.yaml --patch @patches/network.patch --output controlplane-network.yaml

# Generate config for each node
talosctl machineconfig patch controlplane-network.yaml --patch @patches/tane-mahuta.patch --output controlplane-tane-mahuta.yaml
talosctl machineconfig patch controlplane-network.yaml --patch @patches/tangaroa.patch --output controlplane-tangaroa.yaml
talosctl machineconfig patch controlplane-network.yaml --patch @patches/tawhirimatea.patch --output controlplane-tawhirimatea.yaml

# Configure talosconfig
talosctl --talosconfig talosconfig config endpoint $TANE_MAHUTA $TANGAROA $TAWHIRIMATEA
talosctl config merge talosconfig

# Apply configs to nodes
# Add --insecure for initial run
talosctl apply-config --nodes $TANE_MAHUTA --file controlplane-tane-mahuta.yaml #--insecure
talosctl apply-config --nodes $TANGAROA --file controlplane-tangaroa.yaml #--insecure
talosctl apply-config --nodes $TAWHIRIMATEA --file controlplane-tawhirimatea.yaml #--insecure

# Bootstrap cluster
# Only run once
# talosctl bootstrap --nodes $TANE_MAHUTA

# Retrieve kubeconfig
talosctl kubeconfig . --nodes $TANE_MAHUTA --force
talosctl kubeconfig --nodes $TANE_MAHUTA
