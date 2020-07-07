# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-cloudbuild
  labels:
    app: hello-cloudbuild
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hello-cloudbuild
  template:
    metadata:
      labels:
        app: hello-cloudbuild
    spec:
      containers:
      - name: hello-cloudbuild
        #image: gcr.io/go-mysql-282504/hello-cloudbuild:641b6e8
        image: gcr.io/GOOGLE_CLOUD_PROJECT/hello-cloudbuild:COMMIT_SHA
        ports:
        - containerPort: 8080
      - name: cloudsql-proxy
        image: gcr.io/cloudsql-docker/gce-proxy:1.11
        command: ["/cloud_sql_proxy",
                  "-instances=go-mysql-282504:us-central1:mysql=tcp:3306",
                  # If running on a VPC, the Cloud SQL proxy can connect via Private IP. See:
                  # https://cloud.google.com/sql/docs/mysql/private-ip for more info.
                  # "-ip_address_types=PRIVATE",
                  "-credential_file=/secrets/cloudsql/key.json"]
        securityContext:
          runAsUser: 2  # non-root user
          allowPrivilegeEscalation: false
        volumeMounts:
          - name: cloudsql-instance-credentials
            mountPath: /secrets/cloudsql
            readOnly: true
      volumes:
        - name: go-mysql-persistent-storage
          persistentVolumeClaim:
            claimName: go-mysql-volumeclaim
        - name: cloudsql-instance-credentials
          secret:
            secretName: cloudsql-instance-credentials
---
kind: Service
apiVersion: v1
metadata:
  name: hello-cloudbuild
spec:
  selector:
    app: hello-cloudbuild
  ports:
  - protocol: TCP
    port: 8080
    targetPort: 8080
  type: LoadBalancer
