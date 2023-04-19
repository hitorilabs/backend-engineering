# Backend Engineering Concepts

Manage Digital Ocean Resources w/ Terraform
```sh
doppler run --name-transformer tf-var -- terraform plan

doppler run --name-transformer tf-var -- terraform apply
```

Build and push to Digital Ocean Container Registry
```sh
docker build --platform linux/amd64 -t registry.digitalocean.com/hitorilabs/fastapi-server .

docker push registry.digitalocean.com/hitorilabs/fastapi-server
```

I'm 90% sure that DigitalOcean Terraform provider implementation is busted.