# clogger
This is a simple app to demonstrate a c application logger that can run in a kubernetes environment and dynamically change the log level.

I used a minikube environment for development & testing.

How to use:

```
# Clone repository
cd clogger
sudo ./build.sh
# The application can be tested by running ./build/clogger, and changing the log levels with ./setlevel.sh -l $LEVEL
# Binary MUST BE run from the clogger directory, NOT the build dir
# Getting it to run on your kubernetes cluster:
# IF ON MINIKUBE RUN: eval $(minikube docker-env)
docker build -t clogger .
kubectl apply -f clogger.yaml
kubectl get pods
```
Logs will now show up. To change log level:
```
kubectl exec clogger -- ./setlevel.sh -l OFF
kubectl exec clogger -- ./setlevel.sh -l ERROR
kubectl exec clogger -- ./setlevel.sh -l INFO
kubectl exec clogger -- ./setlevel.sh -l DEBUG
```
To collect (dummy) metrics:
```
kubectl exec clogger -- ./setlevel.sh -l METRICS -m ON
kubectl exec clogger -- ./setlevel.sh -l METRICS -m OFF
# The following will turn on metrics for 1 minute
kubectl exec clogger -- ./setlevel.sh -l METRICS -m 1
```
To view metrics & logs on grafana, you must also deploy prometheus, fluent bit, loki and grafana to the cluster
```
# Deploy prometheus, fluent bit, loki and grafana (HELM REQUIRED)
helm repo add stable https://charts.helm.sh/stable
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add fluent https://fluent.github.io/helm-charts
helm repo update
kubectl create namespace prometheus
helm upgrade --namespace prometheus --install kube-stack-prometheus prometheus-community/kube-prometheus-stack --set prometheus-node-exporter.hostRootFsMount.enabled=false
helm upgrade -i grafana grafana/loki-stack --set fluent-bit.enabled=true,promtail.enabled=false
kubectl port-forward --namespace prometheus svc/kube-stack-prometheus-grafana 8080:80
```
You can now access grafana through your browser at localhost:8080
The default credentials are:
**Username**: admin
**Password**: prom-operator

But you can also check these with the following commands:
```
kubectl get secret --namespace prometheus kube-stack-prometheus-grafana -o jsonpath='{.data.admin-user}' | base64 -d
kubectl get secret --namespace prometheus kube-stack-prometheus-grafana -o jsonpath='{.data.admin-password}' | base64 -d
```

You can already view various metrics in the explore section. To see the logs, loki must be added as a data source. 
Go to configuration > data sources > add data source. Select loki.
If Grafana and Loki are in the same namespace, set the Loki URL as http://$LOKI_SERVICE_NAME:$LOKI_PORT
Otherwise, set the Loki URL as http://$LOKI_SERVICE_NAME.$LOKI_NAMESPACE:$LOKI_PORT
In my case, this is **grafana-loki.default:3100**

After clicking save and test, you should see: **Data source connected and labels found.**

Now, go to explore, and at the top choose Loki as the data source. 
For me, logst contained the message twice, so I had to set the **Merge_Log** option in the fluent bit ConfigMap to **off**.
Here's how to do it:
```
kubectl edit cm grafana-fluent-bit-loki
# Set Merge_Log option to off and save changes
# Re-deploy fluent bit daemon set
kubectl get ds grafana-fluent-bit-loki -o yaml > fluent-bit.yaml
kubectl delete -f fluent-bit.yaml
kubectl apply -f fluent-bit.yaml
```

After these changes, log messages should show up perfectly.

To gracefully exit clogger application:
```
kubectl exec clogger -- killall -s SIGINT clogger
kubectl delete -f clogger.yaml
```

