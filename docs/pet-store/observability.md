# Observability with Pet-store Application

This readme provides the overview of the features that are available with observability when using pet-store application. 
Please follow the instructions below to work with [Cellery Dashboard](https://github.com/wso2/cellery/blob/master/docs/cellery-observability.md#use-cellery-dashboard).

If you have installed complete setup or basic setup with observability enabled, you can follow below steps to view the cellery observability.

1) Go to [http://cellery-dashboard](http://cellery-dashboard) and you will land in the over view page of the cellery dashboard. 
This will show the overall health of the cells and the system, and the dependencies between the cells.

![cellery overview](../images/pet-store/cellery-observabiltiy-overview.png)

2) You can click on a cell, and inspect the components of cell. For example, the pet-be cell's components and metrics overview is shown below.

![cellery components overview](../images/pet-store/observe-overview-comp.png)

3) Now go you can go into the details of a component `gateway` within the pet-be cell, and it will show the dependency diagram within cell, kubernetes pods, and metrics of the component.

![cellery gateway component overview](../images/pet-store/gateway-comp-overview.png)

![cellery kubernetes pods](../images/pet-store/kubernetes-pods.png)

![cellery component metrics](../images/pet-store/comp-metrics.png)

4) You can also trace the each requests that come into the system. 

![cellery distributed tracing](../images/pet-store/distributed-trace-search.png)

5) Each trace in the tracing view has timeline view, sequence diagram, and dependency digram view. 

![cellery timeline view](../images/pet-store/timeline-trace.png)

![cellery sequence diagram view](../images/pet-store/sequence-diagram-1.png)

![cellery sequence diagram view](../images/pet-store/sequence-diagram-2.png)

![cellery dependency graph view](../images/pet-store/dependency-diagram-tarce.png)

## What's Next?
- [Update pet-be cell](component-patch-and-adv-deployment.md#cell-component-update) - provides the steps to update the components of the pet-be cell.
- [Advanced deployments with pet-be cell](component-patch-and-adv-deployment.md#blue-green-and-canary-deployment) - perform advanced deployments with pet-be cell.
- [Scale pet-be cell](scale-cell.md) - walks through the steps to scale pet-be cell with horizontal pod autoscaler, and zero scaling with Knative. 
- [Pet store sample](../../cells/pet-store/README.md) - provides the instructions to work with pet-store sample.
