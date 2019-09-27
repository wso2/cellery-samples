# Scaling up/down pet-store cell
Each component within the cells can be scaled up or down. Cellery supports auto scaling with [Horizontal pod autoscaler](#scale-with-hpa), 
and [Zero-scaling](#zero-scaling).

In this READE we focus on scaling up pet-be's `controller` component with,
1) [Horizontal Autoscaler](#horizontal-autoscaler)
2) [Zero Scaling](#zero-scaling)

## Horizontal Autoscaler
An updated controller component in the pet-be cell is attached with autoscaling policy as explained [here](../../cells/pet-store/advanced/pet-be-auto-scale/pet-be-auto-scale.bal).
Therefore, inorder to validate the behaviour we require to run the cell with the updated controller component. 

### Pre-requisites
1) Execute below command and confirm the autoscaling with HPA is enabled.
```
$ cellery setup status 

cluster name: cellery-admin@cellery

       SYSTEM COMPONENT         STATUS
 ---------------------------- ----------
  ApiManager                   Enabled
  Observability                Enabled
  Scale to zero                Disabled
  Horizontal pod auto scalar   Enabled
```

2) If that is not enabled, you have to enable as explained [here](https://github.com/wso2-cellery/sdk/blob/master/docs/cell-scaling.md#enable-hpa).
  
### Run auto scaling enabled pet-be
1) Run `pet-be` cell instance with cell image `wso2cellery/pet-be-auto-scale-cell:latest`. You can optionally build the [pet-be-auto-scale.bal](../../cells/pet-store/advanced/pet-be-auto-scale/pet-be-auto-scale.bal) as mentioned [here](build-and-run.md).
```
$ cellery run  wso2cellery/pet-be-auto-scale-cell:latest -n pet-be
```

2) Now execute `kubectl get hpa` and you see the resource utilization.
```
$ kubectl get hpa

NAME                                     REFERENCE                                  TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
istio-pilot                              Deployment/istio-pilot                     <unknown>/80%   1         5         0          2d14h
pet-be--controller-autoscalepolicy-hpa   Deployment/pet-be--controller-deployment   9%/40%          1         3         1          6m36s
```
3) Execute the `export-policy` command and view the current autoscaling configuration. This will create a file where you execute the command. 
You can also optionally pass the `-f` flag to point to the file location to be used to store the policy as explained 
[here](https://github.com/wso2-cellery/sdk/blob/master/docs/cli-reference.md#cellery-export-policy). 
```
 $ cellery export-policy autoscale cell pet-be 
```
4) Run a [load generator cell](../../cells/pet-store/advanced/load-gen/load-gen.bal) which invokes the pet-be's 
`catalog` component in a high concurrency. There are optional environmental variables can be passed to the load-gen 
cell to configure the duration (default 5minutes), concurrency (default 40) of the load test, and pet-store instance name (default pet-be). 
```
$ cellery run wso2cellery/load-gen-cell:latest -n load-gen 
```
 OR
```
$ cellery run wso2cellery/load-gen-cell:latest -e DURATION=10m -e CONCURRENCY=20 -e PET_STORE_INST=pet-be
```
5) Execute `kubectl get hpa` to see the current load for pet-be's controller component once the `load-gen` cell instance is running. 
```
$ kubectl get hpa
NAME                                     REFERENCE                                  TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
istio-pilot                              Deployment/istio-pilot                     <unknown>/80%   1         5         0          2d14h
pet-be--controller-autoscalepolicy-hpa   Deployment/pet-be--controller-deployment   151%/40%        1         3         3          25m
```
6) Check the pods by executing `kubectl get pods`, and you can see 3 replica's of `controller` components are started.
```
$ kubectl get pods
NAME                                             READY   STATUS    RESTARTS   AGE
load-gen--gateway-deployment-68dcfb5699-p5jr7    1/1     Running   0          93s
load-gen--load-gen-deployment-7fdbfbdc8b-8w2l6   2/2     Running   0          93s
load-gen--sts-deployment-5c9cdf4dd5-8lc5m        3/3     Running   0          93s
pet-be--catalog-deployment-67b8565469-q24bk      2/2     Running   0          25m
pet-be--controller-deployment-7ffbd8bfdc-7bvfc   1/2     Running   0          16s
pet-be--controller-deployment-7ffbd8bfdc-j5glt   1/2     Running   0          16s
pet-be--controller-deployment-7ffbd8bfdc-z6mdq   2/2     Running   0          25m
pet-be--customers-deployment-7997974649-lctk4    2/2     Running   0          25m
pet-be--gateway-deployment-7f787575c6-c4fjm      2/2     Running   0          19m
pet-be--orders-deployment-7d9fd8f5ff-qlllk       2/2     Running   0          25m
pet-be--sts-deployment-7f4f56b5d5-d425x          3/3     Running   0          25m
```
7) Now terminate the load-gen cell to stop the load by below command.
```
$ cellery terminate load-gen
```
8) Check for HPA and pods, and you can see the system can return back to the original state. 
```
$ kubectl get hpa
NAME                                     REFERENCE                                  TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
istio-pilot                              Deployment/istio-pilot                     <unknown>/80%   1         5         0          2d14h
pet-be--controller-autoscalepolicy-hpa   Deployment/pet-be--controller-deployment   4%/40%          1         3         3          31m
```
9) Wait for some time for the components to scale down. It will eventually come to 1 from 3. 
```
$ kubectl get pods
NAME                                             READY   STATUS    RESTARTS   AGE
pet-be--catalog-deployment-67b8565469-q24bk      2/2     Running   0          72m
pet-be--controller-deployment-7ffbd8bfdc-z6mdq   2/2     Running   0          72m
pet-be--customers-deployment-7997974649-lctk4    2/2     Running   0          72m
pet-be--gateway-deployment-7f787575c6-c4fjm      2/2     Running   0          66m
pet-be--orders-deployment-7d9fd8f5ff-qlllk       2/2     Running   0          72m
pet-be--sts-deployment-7f4f56b5d5-d425x          3/3     Running   0          72m
```
10) You can terminate the instance by executing below command. 
```
$ cellery terminate pet-be
```

## Zero scaling
An update controller and catalog component is attached to zero scaling configurations as mentioned in 
[pet-be-zero-scale.bal](../../cells/pet-store/advanced/pet-be-zero-scale/pet-be-zero-scale.bal). Based on that configuration, 
both controller and catalogue components are configured with zero scaling. The zero scale configuration used in
the component is provided below.

```
...
scalingPolicy: <cellery:ZeroScalingPolicy> {
             maxReplicas: 3,
             concurrencyTarget: 10
        }
...
```

As per above configuration, if there is no request coming for the component, the component will scale down to zero replicas. The component will only deployed if it receives a request, and the component 
will be scaled up if there is more than `10` concurrent requests for one replica up to max of `3` replicas. 

In this sample, we will be deploying the same [load generator cell](../../cells/pet-store/advanced/load-gen/load-gen.bal) 
which invokes the pet-be's `catalog` component in a high concurrency, and evaluate the zero scaling behaviour.

### Pre-requisites
1) Execute below command and confirm the zero scaling is enabled.
```
$ cellery setup status 

cluster name: cellery-admin@cellery

       SYSTEM COMPONENT         STATUS
 ---------------------------- ----------
  ApiManager                   Enabled
  Observability                Enabled
  Scale to zero                Enabled
  Horizontal pod auto scalar   Disabled
```

2) If that is not enabled, you have to enable as explained [here](https://github.com/wso2-cellery/sdk/blob/master/docs/cell-scaling.md#enable-zero-scaling).

### Run auto scaling enabled pet-be
1) Run `pet-be` cell instance with cell image `wso2cellery/pet-be-zero-scale-cell:latest`. You can optionally build the [pet-be-zero-scale.bal](../../cells/pet-store/advanced/pet-be-zero-scale/pet-be-zero-scale.bal) 
as mentioned [here](build-and-run.md).
```
$ cellery run  wso2cellery/pet-be-zero-scale-cell:latest -n pet-be
```

2) Execute `kubectl get pods`. Approximately after two minutes the pods for `controller` and `catalog` will be terminated.
```
$ kubectl get pods
NAME                                                        READY   STATUS        RESTARTS   AGE
pet-be--catalog-service-rev-deployment-7ff685cf54-dr9q2     2/3     Terminating   0          109s
pet-be--controller-service-rev-deployment-f8b75d65d-pcx5j   2/3     Terminating   0          109s
pet-be--customers-deployment-7997974649-csx2x               2/2     Running       0          113s
pet-be--gateway-deployment-7f787575c6-fb8q6                 2/2     Running       0          113s
pet-be--orders-deployment-7d9fd8f5ff-pqwjl                  2/2     Running       0          113s
pet-be--sts-deployment-7f4f56b5d5-qwfzw                     3/3     Running       0          113s

$ kubectl get pods
NAME                                            READY   STATUS    RESTARTS   AGE
pet-be--customers-deployment-7997974649-csx2x   2/2     Running   0          7m27s
pet-be--gateway-deployment-7f787575c6-fb8q6     2/2     Running   0          7m27s
pet-be--orders-deployment-7d9fd8f5ff-pqwjl      2/2     Running   0          7m27s
pet-be--sts-deployment-7f4f56b5d5-qwfzw         3/3     Running   0          7m27s
```

3) Run a [load generator cell](../../cells/pet-store/advanced/load-gen/load-gen.bal) which invokes the pet-be's 
`catalog` component in a high concurrency. There are optional environmental variables can be passed to the load-gen 
cell to configure the duration (default 5minutes), concurrency (default 40) of the load test, and pet-store instance name (default pet-be). 
```
$ cellery run wso2cellery/load-gen-cell:latest -n load-gen -y 
```
  OR
```
$ cellery run wso2cellery/load-gen-cell:latest -e DURATION=10m -e CONCURRENCY=20 -e PET_STORE_INST=pet-be
```
4) Once the load-gen cell is started, the `controller` and `catalog` components will be running as shown below.
```
 kubectl get pods                                                                                                                                    

NAME                                                        READY   STATUS     RESTARTS   AGE
load-gen--gateway-deployment-68dcfb5699-2hfsj               1/1     Running    0          48s
load-gen--load-gen-deployment-7fdbfbdc8b-snq5q              2/2     Running    0          48s
load-gen--sts-deployment-5c9cdf4dd5-7vr49                   3/3     Running    0          48s
pet-be--catalog-service-rev-deployment-7ff685cf54-697hl     2/3     Running    0          6s
pet-be--catalog-service-rev-deployment-7ff685cf54-8bgrh     0/3     Init:0/1   0          2s
pet-be--catalog-service-rev-deployment-7ff685cf54-tth8z     2/3     Running    0          7s
pet-be--controller-service-rev-deployment-f8b75d65d-8wd29   3/3     Running    0          14s
pet-be--controller-service-rev-deployment-f8b75d65d-m6qgj   3/3     Running    0          12s
pet-be--controller-service-rev-deployment-f8b75d65d-xhlrg   3/3     Running    0          12s
pet-be--customers-deployment-7997974649-csx2x               2/2     Running    0          8m54s
pet-be--gateway-deployment-7f787575c6-fb8q6                 2/2     Running    0          8m54s
pet-be--orders-deployment-7d9fd8f5ff-pqwjl                  2/2     Running    0          8m54s
pet-be--sts-deployment-7f4f56b5d5-qwfzw                     3/3     Running    0          8m54s
``` 
5) Terminate the load cell to stop the traffic to the pet-be cell.
```
$ cellery terminate load-gen
```

6) After approximately two minutes, `controller` and `catalog` components will be terminating again as there are no requests.
```
$ kubectl get pods                                                             

NAME                                                        READY   STATUS        RESTARTS   AGE
pet-be--catalog-service-rev-deployment-7ff685cf54-697hl     2/3     Terminating   0          4m51s
pet-be--catalog-service-rev-deployment-7ff685cf54-8bgrh     2/3     Terminating   0          4m47s
pet-be--catalog-service-rev-deployment-7ff685cf54-tth8z     2/3     Terminating   0          4m52s
pet-be--controller-service-rev-deployment-f8b75d65d-8wd29   2/3     Terminating   0          4m59s
pet-be--controller-service-rev-deployment-f8b75d65d-m6qgj   2/3     Terminating   0          4m57s
pet-be--controller-service-rev-deployment-f8b75d65d-xhlrg   2/3     Terminating   0          4m57s
pet-be--customers-deployment-7997974649-csx2x               2/2     Running       0          13m
pet-be--gateway-deployment-7f787575c6-fb8q6                 2/2     Running       0          13m
pet-be--orders-deployment-7d9fd8f5ff-pqwjl                  2/2     Running       0          13m
pet-be--sts-deployment-7f4f56b5d5-qwfzw                     3/3     Running       0          13m

```

7) You can now clean up the pet-be instance as well.
```
$ cellery terminate pet-be
```

# What's Next?
- [Observe the pet-store](observability.md) - shows how you can observe and understand the runtime operations to the pet-store application.
- [Update pet-be cell](cell-component-update-and-adv-deployment.md#cell-component-update) - provides the steps to update the components of the pet-be cell.
- [Advanced deployments with pet-be cell](cell-component-update-and-adv-deployment.md#blue-green-and-canary-deployment) - perform advanced deployments with pet-be cell.
- [Pet store sample](../../cells/pet-store/README.md) - provides the instructions to work with pet-store sample.
- [Hipster shop sample](../../cells/hipster-shop/README.md) - is a sample that shows the cellery usage with the original 
micro services demo [here](https://github.com/GoogleCloudPlatform/microservices-demo).
