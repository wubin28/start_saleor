# Running Saleor Locally

[https://docs.saleor.io/quickstart/running-locally](https://docs.saleor.io/quickstart/running-locally)


```bash
# Install and open Docker Desktop on PC

# Build Docker images by cloning the repository and running the following commands:
git clone https://github.com/saleor/saleor-platform.git
cd saleor-platform
docker compose pull

# update the database schema to the latest version
docker compose run --rm api python3 manage.py migrate

# populate the database with sample data
docker compose run --rm api python3 manage.py populatedb

# add admin user name and password
docker compose run --rm api python3 manage.py createsuperuser

# email: admin@example.com
# password: admin

# email: admin1@example.com
# password: admin1

# Run all Saleor containers (from within the saleor-platform directory)
docker compose up

# The dashboard will now be available at localhost:9000.

# Optional: Add live reloading
# This step is optional for those who want to contribute to Saleor.
# Saleor uses shared folders to enable live code reloading. If you're using Windows or MacOS you will need to:
# - Add the cloned saleor-platform directory to the list of shared directories in Docker (Settings -> Shared Drives or Preferences -> Resources -> File sharing).
# - Make sure that in Docker preferences, you have dedicated at least 5 GB of memory (Settings -> Advanced or Preferences -> Resources -> Advanced).
```

- **GraphQL Playground**: [http://localhost:8000/graphql/](http://localhost:8000/graphql/)
- **Saleor Dashboard**: [http://localhost:9000/](http://localhost:9000/)
- **Mailpit邮件工具**: [http://localhost:8025/](http://localhost:8025/)
- **Jaeger追踪**: [http://localhost:16686/](http://localhost:16686/)