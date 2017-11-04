docker network ls -qf driver=overlay | xargs -n1 docker network inspect | jq -r '.[0] | [.IPAM.Config[0].Subnet,.Name] | join(" ")'
