apiVersion: crema/v1
kind: CremaConfig
metadata:
  name: github-runner-autoscaler
spec:
  pollingInterval: ${polling_interval}
  scaledObjects:
    - spec:
        scaleTargetRef:
          name: projects/${project_id}/locations/${region}/workerPools/${worker_pool_name}
        minReplicaCount: ${min_replicas}
        maxReplicaCount: ${max_replicas}
        advanced:
          horizontalPodAutoscalerConfig:
            behavior:
              scaleDown:
                stabilizationWindowSeconds: ${cooldown_period}
                policies:
                  - type: Percent
                    value: 100
                    periodSeconds: 15
        triggers:
          - type: github-runner
            metadata:
              owner: "${github_org}"
              runnerScope: "org"
              applicationID: "${github_app_id}"
              installationID: "${github_app_installation_id}"
              targetWorkflowQueueLength: "${target_workflow_queue_length}"
              labels: "${runner_labels}"
            authenticationRef:
              name: github-app-auth
  triggerAuthentications:
    - metadata:
        name: github-app-auth
      spec:
        gcpSecretManager:
          secrets:
            - parameter: appKey
              id: ${github_app_private_key_secret_name}
              version: latest
