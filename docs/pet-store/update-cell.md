# Update pet store cell
This readme explains the steps to update the running cell pet-be. Cellery supports cell updates via,
- [Rolling update](#rolling-update)
- [Blue/Green update](#blue-green-and-canary-update)
- [Canary update](#blue-green-and-canary-update)

In this section, we focus on updating the pet-be cell with all three above mentioned update methods. 

### Pre Requisites
- You should have the pet-store application running as explained [here](../../cells/pet-store/README.md).

## Rolling update
A components within the cell can updated via rolling update. This will terminate the components one-by-one and applying 
the changes, eventually the whole cell will be updated with new version. Follow below mentioned steps to rolling update the current running cell pet-be.  

Let's assume the pet-be components should be updated with resource requests and limits as per advanced 
[pet-be.bal](../../cells/pet-store/advanced/pet-be/pet-be.bal). And now we require to update the current running pet-be bal with this new cell. 

1) You can optionally build the updated pet-be cell `wso2cellery/pet-be-cell:latestv2` as explained [here](build-and-run.md). 
Or you can simply pull the hosted cell from [cellery hub](https://hub.cellery.io/orgs/wso2cellery) via below command. 
```
$ cellery pull wso2cellery/pet-be-cell:latestv2
```

2) Update the currently running `pet-be` instance with below command.
```
cellery update pet-be wso2cellery/pet-be-cell:latestv2
```
3) Now execute `kubectl get pods` and you can see the pods of the `pet-be` are getting initialized. And finally, older pods are getting terminated.
```
$ kubectl get pods
NAME                                             READY   STATUS            RESTARTS   AGE
pet-be--catalog-deployment-54b8cd64-knhnc        0/2     PodInitializing   0          4s
pet-be--catalog-deployment-67b8565469-fq86w      2/2     Running           0          26m
pet-be--controller-deployment-6f89fdb47c-rn4mn   2/2     Running           0          24m
pet-be--controller-deployment-75f5db95f4-2dt96   0/2     PodInitializing   0          4s
pet-be--customers-deployment-7997974649-22hft    2/2     Running           0          26m
pet-be--customers-deployment-7d8df7fb84-h48xs    0/2     PodInitializing   0          4s
pet-be--gateway-deployment-7f787575c6-vmg4p      2/2     Running           0          26m
pet-be--orders-deployment-7d874dfd98-vnhdw       0/2     PodInitializing   0          4s
pet-be--orders-deployment-7d9fd8f5ff-4czdx       2/2     Running           0          26m
pet-be--sts-deployment-7f4f56b5d5-bjhww          3/3     Running           0          26m
pet-fe--gateway-deployment-67ccf688fb-dnhhw      2/2     Running           0          4h6m
pet-fe--portal-deployment-69bb57c466-25nqd       2/2     Running           0          4h6m
pet-fe--sts-deployment-59dbb995c7-g7tc7          3/3     Running           0          4h6m
```

4) Now you can check the pet-store application is up and running by following the instructions [here](../../cells/pet-store/README.md#view-application).

## Blue-Green and Canary update
To update a cell using Blue-Green/ Canary patterns, you should first create a cell instance using the cellery run command. 
Then, the traffic for the specific instance can be switch 100% (Blue-Green) or partially to a new version (canary). 

Inorder to test this, let us assume that the pet-be cell should be updated with autoscaling policy as defined in 
[pet-be-auto-scale.bal](../../cells/pet-store/advanced/pet-be-auto-scale/pet-be-auto-scale.bal). And we will be starting 
a new pet-be cell instance, and having a canary deployment by having 50% traffic routed to the new and old cell instances. 
Then, we completely switch 100% traffic to new deployment and still have the both cell instances running as per the blue-green deployment pattern. 
Finally, terminate old instance.

1) You can optionally build the updated pet-be cell `wso2cellery/pet-be-auto-scale-cell:latest` as explained [here](build-and-run.md). 
Or you can simply run directly which will pull the hosted cell from [cellery hub](https://hub.cellery.io/orgs/wso2cellery) via below command. 
```
$ cellery run wso2cellery/pet-be-auto-scale-cell:latest -n pet-be-as
```

2) Make sure the `pet-be-as` cell is in `Ready` status with `cellery list instances` command.

3) Route the 50% of the traffic to the new `pet-be-as` cell instance. 
```
$ cellery route-traffic pet-be -p pet-be-as=50
```
4) Now you can check the pet-store application is up and running by following the instructions [here](../../cells/pet-store/README.md#view-application).

5) This is the canary deployment, and you can see both instances are in operation. You can get tail the logs of the 
gateway component in each cell instances to validate this. 

```
// Logs from pet-be cell gateway. Note the timestamp of last logs.
$ kubectl logs pet-be--gateway-deployment-7f787575c6-pwvw7 cell-gateway
2019-07-05 13:24:22,270 DEBUG [wso2/gateway:0.0.0] - [ThrottleFilter] [3561fa90-06c2-4589-ab0d-5b0b4a51fb51] Throttling latency: 2ms
2019-07-05 13:24:22,273 DEBUG [wso2/gateway:0.0.0] - [ThrottleFilter] [3561fa90-06c2-4589-ab0d-5b0b4a51fb51] Throttling latency: 0ms
2019-07-05 13:24:22,273 DEBUG [ballerina/http] - Cached response not found for: 'GET /orders'
2019-07-05 13:24:22,274 DEBUG [ballerina/http] - Sending new request to: /orders
2019-07-05 13:24:22,375 DEBUG [wso2/gateway:0.0.0] - [ThrottleFilter] [3561fa90-06c2-4589-ab0d-5b0b4a51fb51] Throttling latency: 0ms
2019-07-05 13:24:22,375 DEBUG [wso2/gateway:0.0.0] - [ThrottleFilter] [3561fa90-06c2-4589-ab0d-5b0b4a51fb51] Throttling latency: 0ms
```

```
// Logs from pet-be-as cell gateway. Note the timestamp of last logs.
$ kubectl logs pet-be--gateway-deployment-7f787575c6-pwvw7 cell-gateway
2019-07-05 13:24:24,764 DEBUG [wso2/gateway:0.0.0] - [ThrottleFilter] [33801ec3-1be0-46b8-9559-e6b74ae7c929] Request is not throttled
2019-07-05 13:24:24,764 DEBUG [wso2/gateway:0.0.0] - [ThrottleFilter] [33801ec3-1be0-46b8-9559-e6b74ae7c929] Throttling latency: 5ms
2019-07-05 13:24:24,765 DEBUG [wso2/gateway:0.0.0] - [ThrottleFilter] [33801ec3-1be0-46b8-9559-e6b74ae7c929] Throttling latency: 1ms
2019-07-05 13:24:24,765 DEBUG [ballerina/http] - Cached response not found for: 'GET /orders'
2019-07-05 13:24:24,765 DEBUG [ballerina/http] - Sending new request to: /orders
2019-07-05 13:24:24,878 DEBUG [wso2/gateway:0.0.0] - [ThrottleFilter] [33801ec3-1be0-46b8-9559-e6b74ae7c929] Throttling latency: 0ms
2019-07-05 13:24:24,879 DEBUG [wso2/gateway:0.0.0] - [ThrottleFilter] [33801ec3-1be0-46b8-9559-e6b74ae7c929] Throttling latency: 0ms
```

6) You can completely switch the traffic to 100% to the `pet-be-as` as shown below. 
```
$ cellery route-traffic pet-be -p pet-be-as=100
```

7) Again you can access the pet-store application as mentioned in step-4, and get the logs as setp-5. Now you can see 
pet-be cell gateway's logs will not have been updated, where as `pet-be-as` cell gateway's log would have got updated as shown below.

```
// Logs from pet-be cell gateway. Note the timestamp of last logs, and it is not updated from step-5.
$ kubectl logs pet-be--gateway-deployment-7f787575c6-pwvw7 cell-gateway
2019-07-05 13:24:22,270 DEBUG [wso2/gateway:0.0.0] - [ThrottleFilter] [3561fa90-06c2-4589-ab0d-5b0b4a51fb51] Throttling latency: 2ms
2019-07-05 13:24:22,273 DEBUG [wso2/gateway:0.0.0] - [ThrottleFilter] [3561fa90-06c2-4589-ab0d-5b0b4a51fb51] Throttling latency: 0ms
2019-07-05 13:24:22,273 DEBUG [ballerina/http] - Cached response not found for: 'GET /orders'
2019-07-05 13:24:22,274 DEBUG [ballerina/http] - Sending new request to: /orders
2019-07-05 13:24:22,375 DEBUG [wso2/gateway:0.0.0] - [ThrottleFilter] [3561fa90-06c2-4589-ab0d-5b0b4a51fb51] Throttling latency: 0ms
2019-07-05 13:24:22,375 DEBUG [wso2/gateway:0.0.0] - [ThrottleFilter] [3561fa90-06c2-4589-ab0d-5b0b4a51fb51] Throttling latency: 0ms
```

```
// Logs from pet-be-as cell gateway. Note the timestamp of last logs, and it has been updated from step-5.
$ kubectl logs pet-be--gateway-deployment-7f787575c6-pwvw7 cell-gateway
2019-07-05 13:30:37,450 DEBUG [wso2/gateway:0.0.0] - [ThrottleUtil] [26d9f835-2269-46fb-b09f-e60a72fea52f] Throttle out event is sent to the queue.
2019-07-05 13:30:37,450 DEBUG [wso2/gateway:0.0.0] - [ThrottleFilter] [26d9f835-2269-46fb-b09f-e60a72fea52f] Request is not throttled
2019-07-05 13:30:37,450 DEBUG [wso2/gateway:0.0.0] - [ThrottleFilter] [26d9f835-2269-46fb-b09f-e60a72fea52f] Throttling latency: 2ms
2019-07-05 13:30:37,450 DEBUG [wso2/gateway:0.0.0] - [ThrottleFilter] [26d9f835-2269-46fb-b09f-e60a72fea52f] Throttling latency: 0ms
2019-07-05 13:30:37,451 DEBUG [ballerina/http] - Cached response not found for: 'GET /orders'
2019-07-05 13:30:37,451 DEBUG [ballerina/http] - Sending new request to: /orders
2019-07-05 13:30:37,557 DEBUG [wso2/gateway:0.0.0] - [ThrottleFilter] [26d9f835-2269-46fb-b09f-e60a72fea52f] Throttling latency: 0ms
2019-07-05 13:30:37,557 DEBUG [wso2/gateway:0.0.0] - [ThrottleFilter] [26d9f835-2269-46fb-b09f-e60a72fea52f] Throttling latency: 0ms
```

8) Now you can terminate the `pet-be` cell instance, and only have the `pet-be-as` cell running. 
```
cellery terminate pet-be
```

# What's Next?
- [Scale pet-be cell](scale-cell.md) - walks through the steps to scale pet-be cell with horizontal pod autoscaler, and zero scaling with Knative. 
- [Observe the pet-store](observability.md) - This shows how you can observe and understand the runtime operations to the pet-store application.
- [Pet store sample](../../cells/pet-store/README.md) - provides the instructions to work with pet-store sample.

