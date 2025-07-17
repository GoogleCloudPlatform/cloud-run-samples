# syntax=docker/dockerfile:1
# Best practices: https://docs.docker.com/build/building/best-practices/


# [START run_github_worker_pool_dockerfile]
FROM ghcr.io/actions/actions-runner:2.322.0

# Add scripts with right permissions.
USER root
ADD start.sh start.sh
RUN chmod +x start.sh

# Add start entrypoint with right permissions.
USER runner
ENTRYPOINT ["./start.sh"]
# [END run_github_worker_pool_dockerfile]
