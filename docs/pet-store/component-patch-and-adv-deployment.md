# Component Patching and Advanced Deployemt Patterns
This readme explains the steps to patch the components of the running cell pet-be and how to try out advanced deployments such as Blue-Green and Canary with pet-be.
- [Component Patching](#component-patching)
- [Blue-Green deployment](#blue-green-and-canary-deployment)
- [Canary deployment](#blue-green-and-canary-deployment)

### Pre Requisites
- You should have the pet-store application running as explained [here](../../cells/pet-store/README.md).

## Component Patching
Selected components within a cell can be patched via rolling update. This will terminate the intended component of the cell and apply 
the changes. With this you can patch the component's docker image and environmental variables by passing those information as inline parameters.

Follow the below mentioned steps to patch the controller component of the running cell pet-be.  

Let us assume the pet-be instance's controller component should be updated with docker image `wso2cellery/samples-pet-store-controller:latestv2`. 

1) Patch the currently running `pet-be` instance's controller component with below command.
```
$ cellery patch pet-be controller --container-image wso2cellery/samples-pet-store-controller:latestv2
```
3) Now execute `kubectl get pods` and you can see the pods of the `pet-be` are getting initialized. And finally, older pods are getting terminated.
```
$ kubectl get pods
NAME                                             READY   STATUS            RESTARTS   AGE
pet-be--catalog-deployment-67b8565469-fq86w      2/2     Running           0          26m
pet-be--controller-deployment-6f89fdb47c-rn4mn   2/2     Running           0          24m
pet-be--controller-deployment-75f5db95f4-2dt96   0/2     PodInitializing   0          4s
pet-be--customers-deployment-7997974649-22hft    2/2     Running           0          26m
pet-be--gateway-deployment-7f787575c6-vmg4p      2/2     Running           0          26m
pet-be--orders-deployment-7d9fd8f5ff-4czdx       2/2     Running           0          26m
pet-be--sts-deployment-7f4f56b5d5-bjhww          3/3     Running           0          26m
pet-fe--gateway-deployment-67ccf688fb-dnhhw      2/2     Running           0          4h6m
pet-fe--portal-deployment-69bb57c466-25nqd       2/2     Running           0          4h6m
pet-fe--sts-deployment-59dbb995c7-g7tc7          3/3     Running           0          4h6m
```

4) Now you can check the pet-store application is up and running by following the instructions [here](../../cells/pet-store/README.md#view-application).

Refer to [CLI docs](https://github.com/wso2-cellery/sdk/blob/master/docs/cli-reference.md#cellery-patch) for a complete guide on performing updates on cell instances.

## Blue-Green and Canary deployment
Blue-Green and Canary are advanced deployment patterns which can used to perform updates to running cell instances. 
However, in contrast to the component update method described above, this update does not happen in place and a new cell instance needs to be used to re-route traffic explicitly. 
The traffic can be either switched 100% (Blue-Green method) or partially (Canary method) to a cell instance created with a new cell image.

Inorder to test this, let us assume that the pet-be cell should be updated with autoscaling policy as defined in 
[pet-be-auto-scale.bal](../../cells/pet-store/advanced/pet-be-auto-scale/pet-be-auto-scale.bal). And we will be starting 
a new pet-be cell instance, and having a canary deployment by having 50% traffic routed to the new and old cell instances. 
Then, we completely switch 100% traffic to new deployment and still have the both cell instances running as per the blue-green deployment pattern. 
Finally, terminate old instance.

Please start the cell pet-store cell if it is not running already as mentioned [here](../../cells/pet-store#quick-run). 

1) You can optionally build cell with `wso2cellery/pet-be-auto-scale-cell:latest` from cell file [pet-be-auto-scale.bal](../../cells/pet-store/advanced/pet-be-auto-scale/pet-be-auto-scale.bal) 
as explained [here](build-and-run.md). Or you can simply run directly which will pull the hosted cell from [cellery hub](https://hub.cellery.io/orgs/wso2cellery) via below command. 
```
$ cellery run wso2cellery/pet-be-auto-scale-cell:latest -n pet-be-as
```
2) Make sure the `pet-be-as` cell is in `Ready` status with `cellery list instances` command.

3) Cell `pet-fe` was linked to `pet-be` instance as pet store application was started as shown [here](../../cells/pet-store/README.md#quick-run).
 Let us route the 50% of the traffic to the new `pet-be-as` cell instance as shown below. 
```
$ cellery route-traffic -d pet-be -t pet-be-as -p 50
```

4) Now you can check the pet-store application is up and running by following the instructions [here](../../cells/pet-store/README.md#view-application).

5) This is the canary deployment, and you can see both instances are in operation. You can get tail the logs of the 
gateway component in each cell instances to validate this. 

```
// Logs from pet-be cell gateway. Note the timestamp of last logs.
$ kubectl logs pet-be--gateway-deployment-7f787575c6-pwvw7 envoy-gateway
2019-07-05 13:24:22,270 DEBUG [wso2/gateway:0.0.0] - [ThrottleFilter] [3561fa90-06c2-4589-ab0d-5b0b4a51fb51] Throttling latency: 2ms
2019-07-05 13:24:22,273 DEBUG [wso2/gateway:0.0.0] - [ThrottleFilter] [3561fa90-06c2-4589-ab0d-5b0b4a51fb51] Throttling latency: 0ms
2019-07-05 13:24:22,273 DEBUG [ballerina/http] - Cached response not found for: 'GET /orders'
2019-07-05 13:24:22,274 DEBUG [ballerina/http] - Sending new request to: /orders
2019-07-05 13:24:22,375 DEBUG [wso2/gateway:0.0.0] - [ThrottleFilter] [3561fa90-06c2-4589-ab0d-5b0b4a51fb51] Throttling latency: 0ms
2019-07-05 13:24:22,375 DEBUG [wso2/gateway:0.0.0] - [ThrottleFilter] [3561fa90-06c2-4589-ab0d-5b0b4a51fb51] Throttling latency: 0ms
```

```
// Logs from pet-be-as cell gateway. Note the timestamp of last logs.
$ kubectl logs pet-be-as--gateway-deployment-7f787575c6-pwvw7 envoy-gateway
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
$ cellery route-traffic -d pet-be -t pet-be-as -p 100
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
$ kubectl logs pet-be-as--gateway-deployment-7f787575c6-pwvw7 cell-gateway
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

Refer to [CLI docs](https://github.com/wso2-cellery/sdk/blob/master/docs/cli-reference.md#cellery-route-traffic) for a complete guide on route-traffic for cell instances.


# What's Next?
- [Scale pet-be cell](scale-cell.md) - walks through the steps to scale pet-be cell with horizontal pod autoscaler, and zero scaling with Knative. 
- [Observe the pet-store](observability.md) - This shows how you can observe and understand the runtime operations to the pet-store application.
- [Pet store sample](../../cells/pet-store/README.md) - provides the instructions to work with pet-store sample.

