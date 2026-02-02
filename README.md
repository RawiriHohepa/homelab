# homelab

## Deployment process
Commented lines are actions to take outside of terminal
```bash
# cd talos/prod/ # or talos/test/
# # uncomment lines for first run
# ./setup.sh
# # wait for nodes to be ready
# kubectl taint nodes tane-mahuta node-role.kubernetes.io/control-plane:NoSchedule-
# kubectl taint nodes tangaroa node-role.kubernetes.io/control-plane:NoSchedule-
# kubectl taint nodes tawhirimatea node-role.kubernetes.io/control-plane:NoSchedule-

# cd ../../infra/

# helmfile apply -f metrics-server/helmfile.yaml

# kubectl apply -f kube-vip/namespace.yaml
# helmfile apply -f kube-vip/helmfile.yaml # or helmfile-test.yaml

cd infra/

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

# create tailscale oauth client - https://tailscale.com/kb/1236/kubernetes-operator#prerequisites
# populate oauth.clientId and oauth.clientSecret in tailscale/values.yaml
kubectl apply -f tailscale/namespace.yaml
helmfile apply -f tailscale/helmfile.yaml # or helmfile-test.yaml
kubectl apply -f tailscale/connector.yaml # or connector-test.yaml

kubectl apply -f longhorn/namespace.yaml
helmfile apply -f longhorn/helmfile.yaml
kubectl apply -f longhorn/ingress.yaml # or ingress-test.yaml
# restore volumes from backup or create manually
# prod:
# - minio-data-volume               5Gi
# - calibre-web-config-volume       5Gi
# - jellyfin-config-volume          10Gi
# - jellyfin-media-volume           5Gi
# - uptime-kuma-data-volume         5Gi
# - rundeck-minio-storage-volume    5Gi
# - rundeck-mysql-storage-volume    5Gi
# - home-assistant-config-volume    2Gi
# - qbittorrent-config-volume       1Gi
# - radarr-config-volume            10Gi
# - sonarr-config-volume            10Gi
# - readarr-config-volume           10Gi
# - prowlarr-config-volume          5Gi
# - bazarr-config-volume            1Gi
# - audiobookshelf-config-volume    512Mi
# - audiobookshelf-metadata-volume  512Mi
# - apprise-config-volume           512Mi
# - price-buddy-storage-volume      512Mi
# - price-buddy-database-volume     10Gi

helmfile apply -f multus/helmfile.yaml
kubectl apply -f multus/network-attachment-definition.yaml
# wait for multus & network-attachment-definition
kubectl apply -f multus/sample-pod.yaml
ping 192.168.50.200
kubectl delete -f multus/sample-pod.yaml

kubectl apply -f cloudnative-pg/namespace.yaml
helmfile apply -f cloudnative-pg/helmfile.yaml
# kubectl apply -f cloudnative-pg/cluster-example.yaml
# kubectl get pods -l cnpg.io/cluster=cluster-example
# kubectl delete -f cloudnative-pg/cluster-example.yaml

kubectl apply -f minio/namespace.yaml
kubectl apply -f minio/claim.yaml
helmfile apply -f minio/helmfile.yaml
kubectl apply -f minio/ingress.yaml # or ingress-test.yaml

cd ../services/
kubectl apply -f namespace.yaml

kubectl apply -f external/

kubectl apply -f homepage/ingress.yaml
kubectl apply -f homepage/ingress-test.yaml
helmfile apply -f homepage/helmfile.yaml

kubectl apply -f uptime-kuma/claim.yaml
kubectl apply -f uptime-kuma/deployment.yaml
kubectl apply -f uptime-kuma/service.yaml
kubectl apply -f uptime-kuma/ingress.yaml # or ingress-test.yaml

kubectl apply -f calibre-web/claim.yaml
kubectl apply -f calibre-web/deployment.yaml
kubectl apply -f calibre-web/service.yaml
kubectl apply -f calibre-web/ingress.yaml # or ingress-test.yaml

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

kubectl apply -f home-assistant/claim.yaml
kubectl apply -f home-assistant/configuration.yaml
# If first time using volume, comment out home-assistant-config-yaml volume & mount
kubectl apply -f home-assistant/deployment.yaml # or deployment-test.yaml
kubectl apply -f home-assistant/service.yaml
kubectl apply -f home-assistant/ingress.yaml # or ingress-test.yaml
# If first time using volume:
# - Complete setup at 192.168.50.(2|3)4:8123
# - Uncomment home-assistant-config-yaml volume & mount
# - Delete and recreate deployment or deployment-test

kubectl apply -f apprise/claim.yaml
kubectl apply -f apprise/deployment.yaml
kubectl apply -f apprise/service.yaml
kubectl apply -f apprise/ingress.yaml # or ingress-test.yaml

kubectl create secret generic price-buddy-env  -n services --from-file=price-buddy/.env
kubectl apply -f price-buddy/claim.yaml
kubectl apply -f price-buddy/deployment.yaml # or deployment-test.yaml
kubectl apply -f price-buddy/service.yaml
kubectl apply -f price-buddy/ingress.yaml # or ingress-test.yaml

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

kubectl apply -f servarr/readarr/claim.yaml
kubectl apply -f servarr/readarr/deployment.yaml
kubectl apply -f servarr/readarr/service.yaml
kubectl apply -f servarr/readarr/ingress.yaml # or ingress-test.yaml

kubectl apply -f servarr/prowlarr/claim.yaml
kubectl apply -f servarr/prowlarr/deployment.yaml
kubectl apply -f servarr/prowlarr/service.yaml
kubectl apply -f servarr/prowlarr/ingress.yaml # or ingress-test.yaml

kubectl apply -f servarr/bazarr/claim.yaml
kubectl apply -f servarr/bazarr/deployment.yaml
kubectl apply -f servarr/bazarr/service.yaml
kubectl apply -f servarr/bazarr/ingress.yaml # or ingress-test.yaml

kubectl apply -f audiobookshelf/claim.yaml
kubectl apply -f audiobookshelf/deployment.yaml
kubectl apply -f audiobookshelf/service.yaml
kubectl apply -f audiobookshelf/ingress.yaml # or ingress-test.yaml

./sponsor-block-tv/generate-config.sh # if needed
# copy config.json into config.yaml
kubectl apply -f sponsor-block-tv/config.yaml
kubectl apply -f sponsor-block-tv/deployment.yaml
```
