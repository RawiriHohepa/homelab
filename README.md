# homelab

## Deployment process
Commented lines are actions to take outside of terminal
```
cd infra/k3s-ansible
# populate inventory/<playbook-name>/hosts.ini
# populate inventory/<playbook-name>/group_vars/all.yml
# populate ansible.cfg
# add the following to the end of site.yml
# - name: apt
#   hosts: all
#   become: true
#   tasks:
#     - name: Upgrade packages
#       apt:
#         upgrade: true
#     - name: Install nfs-common
#       apt:
#         name: nfs-common
./deploy.sh

cd ../traefik
helmfile apply
kubectl apply -f dashboard/

cd ../cert-manager
helmfile apply
# populate cloudflare token
kubectl apply -f issuers/secret-cf-token.yaml
kubectl apply -f issuers/letsencrypt-staging.yaml
kubectl apply -f issuers/letsencrypt-production.yaml
kubectl apply -f certificates/local-hohepa-dev-staging.yaml
# edit nginx to use staging cert
kubectl apply -f ../../services/nginx
# wait until nginx uses the staging cert
kubectl apply -f certificates/local-hohepa-dev-production.yaml
# edit nginx to use production cert
kubectl apply -f ../../services/nginx
# wait until nginx uses the production cert

cd ../longhorn
kubectl apply -f .
helmfile apply
# restore volumes from backup or create manually

cd ../services

kubectl apply -f calibre-web
kubectl apply -f uptime-kuma
kubectl apply -f external

cd heimdall
kubectl apply -f .
helmfile apply

cd ../jellyfin
kubectl apply -f .
helmfile apply
```