# homelab

## Deployment process
Commented lines are actions to take outside of terminal
```bash
# export ENVIRONMENT=test
export ENVIRONMENT=production

cd infra/

# helmfile apply -f metrics-server/helmfile.yaml

# kubectl apply -f kube-vip/namespace.yaml
# helmfile apply -f kube-vip/helmfile.yaml # or helmfile-test.yaml

helmfile apply -f cert-manager/helmfile.yaml --environment $ENVIRONMENT

kubectl apply -f external-secrets/certs.yaml
helmfile apply -f external-secrets/helmfile.yaml
kubectl apply -k external-secrets/overlays/$ENVIRONMENT/ # creates base/store.yaml with overlays/$ENVIRONMENT/store.yaml patch
kubectl apply -f external-secrets/example.yaml

helmfile apply -f traefik/helmfile.yaml --environment $ENVIRONMENT
kubectl apply -k traefik/overlays/$ENVIRONMENT/

kubectl apply -f cert-manager/secret.yaml
kubectl apply -f cert-manager/acme-staging/issuer.yaml
kubectl apply -k cert-manager/acme-staging/overlays/$ENVIRONMENT/
# verify staging cert was issued successfully
kubectl delete -k cert-manager/acme-staging/overlays/$ENVIRONMENT/

kubectl apply -f cert-manager/acme-production/issuer.yaml
kubectl apply -k cert-manager/acme-production/overlays/$ENVIRONMENT/

kubectl apply -f tailscale/namespace.yaml
kubectl apply -f tailscale/secret.yaml
helmfile apply -f tailscale/helmfile.yaml --environment $ENVIRONMENT
kubectl apply -k tailscale/overlays/$ENVIRONMENT/

kubectl apply -f longhorn/namespace.yaml
helmfile apply -f longhorn/helmfile.yaml
kubectl apply -k longhorn/overlays/$ENVIRONMENT/
# restore volumes from backup or create manually
# prod:
# - actual-budget-data-volume       2Gi
# - apprise-config-volume           512Mi
# - audiobookshelf-config-volume    512Mi
# - audiobookshelf-metadata-volume  512Mi
# - bazarr-config-volume            1Gi
# - calibre-web-config-volume       5Gi
# - home-assistant-config-volume    10Gi
# - homebox-data-volume             512Mi
# - jellyfin-config-volume          10Gi
# - jellyfin-media-volume           2.5Gi
# - minio-data-volume               5Gi
# - pgadmin-config-volume           512Mi
# - price-buddy-storage-volume      512Mi
# - price-buddy-database-volume     10Gi
# - prowlarr-config-volume          5Gi
# - qbittorrent-config-volume       1Gi
# - radarr-config-volume            1Gi
# - readarr-config-volume           10Gi
# - rundeck-minio-storage-volume    5Gi
# - rundeck-mysql-storage-volume    5Gi
# - sonarr-config-volume            1Gi
# - uptime-kuma-data-volume         5Gi


kubectl apply -f cloudnative-pg/namespace.yaml
helmfile apply -f cloudnative-pg/helmfile.yaml
# kubectl apply -f cloudnative-pg/cluster-example.yaml
# kubectl get pods -l cnpg.io/cluster=cluster-example
# kubectl delete -f cloudnative-pg/cluster-example.yaml

kubectl apply -f pgadmin/claim.yaml
kubectl apply -f pgadmin/deployment.yaml
kubectl apply -f pgadmin/service.yaml
kubectl apply -f pgadmin/ingress.yaml # or ingress-test.yaml

kubectl apply -f minio/namespace.yaml
kubectl apply -f minio/claim.yaml
helmfile apply -f minio/helmfile.yaml
kubectl apply -f minio/ingress.yaml # or ingress-test.yaml
kubectl apply -f minio/secret.yaml
# If first time, manually create cloudnative-pg-backups bucket through dashboard

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
# If no minio backup exists: comment recovery section and uncomment initdb section of cluster.yaml
kubectl apply -f jellyfin/cluster.yaml
# Wait for cluster to be created
kubectl apply -f jellyfin/backup.yaml
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
# After starting, delete and uncomment volume & mount
kubectl apply -f home-assistant/deployment.yaml # or deployment-test.yaml
kubectl apply -f home-assistant/service.yaml
kubectl apply -f home-assistant/ingress.yaml # or ingress-test.yaml
# If first time using volume:
# - Complete setup at 192.168.50.(2|3)4:8123
# - Uncomment home-assistant-config-yaml volume & mount
# - Delete and recreate deployment or deployment-test

kubectl apply -f actual-budget/claim.yaml
kubectl apply -f actual-budget/deployment.yaml
kubectl apply -f actual-budget/service.yaml
kubectl apply -f actual-budget/ingress.yaml # or ingress-test.yaml

kubectl apply -f apprise/claim.yaml
kubectl apply -f apprise/deployment.yaml
kubectl apply -f apprise/service.yaml
kubectl apply -f apprise/ingress.yaml # or ingress-test.yaml

kubectl create secret generic price-buddy-env  -n services --from-file=price-buddy/.env
kubectl apply -f price-buddy/claim.yaml
kubectl apply -f price-buddy/deployment.yaml # or deployment-test.yaml
kubectl apply -f price-buddy/service.yaml
kubectl apply -f price-buddy/ingress.yaml # or ingress-test.yaml

kubectl apply -f homebox/claim.yaml
# If no minio backup exists: comment recovery section and uncomment initdb section of cluster.yaml
kubectl apply -f homebox/cluster.yaml
# Wait for cluster to be created
kubectl apply -f homebox/backup.yaml
kubectl apply -f homebox/deployment.yaml
kubectl apply -f homebox/service.yaml
kubectl apply -f homebox/ingress.yaml # or ingress-test.yaml

kubectl apply -f servarr/qbittorrent/claim.yaml
kubectl apply -f servarr/qbittorrent/deployment.yaml
kubectl apply -f servarr/qbittorrent/service.yaml
kubectl apply -f servarr/qbittorrent/ingress.yaml # or ingress-test.yaml

kubectl apply -f servarr/radarr/claim.yaml
# If no minio backup exists: comment recovery section and uncomment initdb section of cluster.yaml
kubectl apply -f servarr/radarr/cluster.yaml
# Wait for cluster to be created
kubectl apply -f servarr/radarr/backup.yaml
kubectl apply -f servarr/radarr/deployment.yaml
kubectl apply -f servarr/radarr/service.yaml
kubectl apply -f servarr/radarr/ingress.yaml # or ingress-test.yaml

kubectl apply -f servarr/sonarr/claim.yaml
# If no minio backup exists: comment recovery section and uncomment initdb section of cluster.yaml
kubectl apply -f servarr/sonarr/cluster.yaml
# Wait for cluster to be created
kubectl apply -f servarr/sonarr/backup.yaml
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
