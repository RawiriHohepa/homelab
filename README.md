# homelab

## Deployment process
Commented lines are actions to take outside of terminal
```bash
cd talos
# uncomment lines for first run
./setup.sh
# wait for nodes to be ready
kubectl taint nodes tane-mahuta node-role.kubernetes.io/control-plane:NoSchedule-
kubectl taint nodes tangaroa node-role.kubernetes.io/control-plane:NoSchedule-
kubectl taint nodes tawhirimatea node-role.kubernetes.io/control-plane:NoSchedule-

cd ../infra

kubectl apply -f kube-vip/namespace.yaml
helmfile apply -f kube-vip/helmfile.yaml

helmfile apply -f traefik/helmfile.yaml
kubectl apply -f traefik/dashboard/ingress.yaml

helmfile apply -f cert-manager/helmfile.yaml
# populate cloudflare token
kubectl apply -f cert-manager/issuers/secret-cf-token.yaml
kubectl apply -f cert-manager/issuers/letsencrypt-staging.yaml
kubectl apply -f cert-manager/issuers/letsencrypt-production.yaml
kubectl apply -f cert-manager/certificates/local-hohepa-dev-staging.yaml
# edit nginx to use local-hohepa-dev-staging-tls
kubectl apply -f ../services/nginx/
# wait until nginx uses the staging cert
kubectl apply -f cert-manager/certificates/local-hohepa-dev-production.yaml
# edit nginx to use local-hohepa-dev-tls
kubectl apply -f ../services/nginx/
# wait until nginx uses the production cert
kubectl delete -f ../services/nginx/

kubectl apply -f longhorn/namespace.yaml
helmfile apply -f longhorn/helmfile.yaml
kubectl apply -f longhorn/ingress.yaml
# restore volumes from backup or create manually
# prod:
# - calibre-web-config-volume   5Gi
# - heimdall-config-volume      1Gi
# - jellyfin-config-volume      5Gi
# - jellyfin-media-volume       5Gi

cd ../services
kubectl apply -f namespace.yaml

kubectl apply -f external/
kubectl apply -f calibre-web/

kubectl apply -f heimdall/claim.yaml
kubectl apply -f heimdall/ingress.yaml
helmfile apply -f heimdall/helmfile.yaml

kubectl apply -f jellyfin/claim.yaml
kubectl apply -f jellyfin/ingress.yaml
helmfile apply -f jellyfin/helmfile.yaml
```
