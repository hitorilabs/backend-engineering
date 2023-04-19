# backend-engineering
overview of backend engineering concepts

Manage Digital Ocean Resources w/ Terraform
```sh
terraform plan \
  -var "do_token=${DO_PAT}"

terraform apply \
  -var "do_token=${DO_PAT}"
```

Build and push to Digital Ocean Container Registry
```sh
docker build --platform linux/amd64 -t registry.digitalocean.com/hitorilabs/fastapi-server .

docker push registry.digitalocean.com/hitorilabs/fastapi-server
```
