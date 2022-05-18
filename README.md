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
kubectl logs -f clogger
```
Logs will now show up. To change log level:
```
kubectl exec clogger -- ./setlevel.sh -l ERROR
kubectl exec clogger -- ./setlevel.sh -l INFO
kubectl exec clogger -- ./setlevel.sh -l DEBUG
```
To gracefully exit application:
```
kubectl exec clogger -- killall -s SIGINT clogger
kubectl delete -f clogger.yaml
```
