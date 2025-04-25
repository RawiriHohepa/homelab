# homelab

## Deployment process
Commented lines are actions to take outside of terminal
```bash
cd talos/prod/ # or talos/test/
# uncomment lines for first run
./setup.sh
# wait for nodes to be ready
kubectl taint nodes tane-mahuta node-role.kubernetes.io/control-plane:NoSchedule-
kubectl taint nodes tangaroa node-role.kubernetes.io/control-plane:NoSchedule-
kubectl taint nodes tawhirimatea node-role.kubernetes.io/control-plane:NoSchedule-

cd ../../infra/

helmfile apply -f metrics-server/helmfile.yaml

kubectl apply -f kube-vip/namespace.yaml
helmfile apply -f kube-vip/helmfile.yaml # or helmfile-test.yaml

helmfile apply -f traefik/helmfile.yaml # or helmfile-test.yaml
kubectl apply -f traefik/dashboard/ingress.yaml # or ingress-test.yaml

helmfile apply -f cert-manager/helmfile.yaml
# populate cloudflare token
kubectl apply -f cert-manager/issuers/secret-cf-token.yaml
kubectl apply -f cert-manager/issuers/letsencrypt-staging.yaml
kubectl apply -f cert-manager/issuers/letsencrypt-production.yaml
kubectl apply -f cert-manager/certificates/local-hohepa-dev-staging.yaml # or test-local-hohepa-dev-staging.yaml
# edit nginx to use local-hohepa-dev-staging-tls
kubectl apply -f ../services/nginx/
kubectl apply -f ../services/nginx/ingress.yaml # or ingress-test.yaml
# wait until nginx uses the staging cert
kubectl apply -f cert-manager/certificates/local-hohepa-dev-production.yaml # or test-local-hohepa-dev-production.yaml
# edit nginx to use local-hohepa-dev-tls
kubectl apply -f ../services/nginx/ingress.yaml # or ingress-test.yaml
# wait until nginx uses the production cert
# kubectl delete -f ../services/nginx/

kubectl apply -f longhorn/namespace.yaml
helmfile apply -f longhorn/helmfile.yaml
kubectl apply -f longhorn/ingress.yaml # or ingress-test.yaml
# restore volumes from backup or create manually
# prod:
# - calibre-web-config-volume       5Gi
# - heimdall-config-volume          1Gi
# - jellyfin-config-volume          5Gi
# - jellyfin-media-volume           5Gi
# - uptime-kuma-data-volume         1Gi
# - rundeck-minio-storage-volume    5Gi
# - rundeck-mysql-storage-volume    5Gi
# - qbittorrent-config-volume       512Mi
# - radarr-config-volume            1Gi
# - sonarr-config-volume            1Gi
# - prowlarr-config-volume          512Mi
# - bazarr-config-volume            512Mi

cd ../services/
kubectl apply -f namespace.yaml

kubectl apply -f external/

kubectl apply -f uptime-kuma/claim.yaml
kubectl apply -f uptime-kuma/deployment.yaml
kubectl apply -f uptime-kuma/service.yaml
kubectl apply -f uptime-kuma/ingress.yaml # or ingress-test.yaml

kubectl apply -f calibre-web/
kubectl apply -f calibre-web/ingress.yaml # or ingress-test.yaml

kubectl apply -f heimdall/claim.yaml
kubectl apply -f heimdall/ingress.yaml # or ingress-test.yaml
helmfile apply -f heimdall/helmfile.yaml

kubectl apply -f jellyfin/claim.yaml
kubectl apply -f jellyfin/ingress.yaml # or ingress-test.yaml
helmfile apply -f jellyfin/helmfile.yaml

kubectl create secret generic rundeck-admin-acl  -n services --from-file=rundeck/admin-role.aclpolicy
# populate secrets.yaml with desired passwords
kubectl apply -f rundeck/secrets.yaml
kubectl apply -f rundeck/claim.yaml
kubectl apply -f rundeck/service.yaml
kubectl apply -f rundeck/deployment-minio.yaml
kubectl apply -f rundeck/deployment-mysql.yaml
kubectl apply -f rundeck/deployment-rundeck.yaml # or deployment-rundeck-test.yaml
kubectl apply -f rundeck/ingress.yaml # or ingress-test.yaml

kubectl apply -f servarr/qbittorrent/claim.yaml
kubectl apply -f servarr/qbittorrent/deployment.yaml
kubectl apply -f servarr/qbittorrent/service.yaml
kubectl apply -f servarr/qbittorrent/ingress.yaml # or ingress-test.yaml

kubectl apply -f servarr/radarr/claim.yaml
kubectl apply -f servarr/radarr/deployment.yaml
kubectl apply -f servarr/radarr/service.yaml
kubectl apply -f servarr/radarr/ingress.yaml # or ingress-test.yaml

kubectl apply -f servarr/sonarr/claim.yaml
kubectl apply -f servarr/sonarr/deployment.yaml
kubectl apply -f servarr/sonarr/service.yaml
kubectl apply -f servarr/sonarr/ingress.yaml # or ingress-test.yaml

kubectl apply -f servarr/prowlarr/claim.yaml
kubectl apply -f servarr/prowlarr/deployment.yaml
kubectl apply -f servarr/prowlarr/service.yaml
kubectl apply -f servarr/prowlarr/ingress.yaml # or ingress-test.yaml

kubectl apply -f servarr/bazarr/claim.yaml
kubectl apply -f servarr/bazarr/deployment.yaml
kubectl apply -f servarr/bazarr/service.yaml
kubectl apply -f servarr/bazarr/ingress.yaml # or ingress-test.yaml
```
