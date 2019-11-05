Hello world cell
=========

The hello-world cell contains one component hello. The hello component is defined by a container image which is written in Node.js and it is a simple webapp. 

![Hello World Cell Architecture Diagram](../../docs/images/hello-world/hello-world-architecture.jpg)

Now let's look at the steps required to try this hello-world cell.

## Try hello world sample

### 1. Checkout the Sample

1. Clone the [wso2-cellery/samples](https://github.com/wso2-cellery/samples) repository
2. Navigate to the hello-world Sample.
   ```
   cd <SAMPLES_ROOT>/cells/hello-world
   ```

### 2. Build, run and push hello world cell
In this section let's focus on build, run and push a [hello-world cell](hello-world.bal). 

The `helloCell` contains one component `hello`. The hello component is defined by a container image `wso2cellery/samples-hello-world-webapp:latest` 
which is written in Node.js and it is a simple webapp. This component has a web ingress with default vhost `hello-world.com`.
An input variable `HELLO_NAME` is expected by the hello component with default value `Cellery` to render the webpage. 
These input parameters can be supplied when starting up the cell to modify the runtime behaviour. 

```ballerina
// Cell file for Hello world Sample
import ballerina/config;
import celleryio/cellery;

public function build(cellery:ImageName iName) returns error? {
    // Hello Component
    // This Components exposes the HTML hello world page
    cellery:Component helloComponent = {
        name: "hello",
        src: {
            image: "wso2cellery/samples-hello-world-webapp:latest-dev"
        },
        ingresses: {
            webUI: <cellery:WebIngress>{ // Web ingress will be always exposed globally.
                port: 80,
                gatewayConfig: {
                    vhost: "hello-world.com",
                    context: "/"
                }
            }
        },
        envVars: {
            HELLO_NAME: { value: "Cellery" }
        }
    };

    // Cell Initialization
    cellery:CellImage helloCell = {
        components: {
            helloComp: helloComponent
        }
    };
    return <@untainted> cellery:createImage(helloCell, iName);
}

public function run(cellery:ImageName iName, map<cellery:ImageName> instances, boolean startDependencies, boolean shareDependencies) returns (cellery:InstanceState[]|error?) {
    cellery:CellImage helloCell = check cellery:constructCellImage(iName);
    string vhostName = config:getAsString("VHOST_NAME");
    if (vhostName !== "") {
        cellery:WebIngress web = <cellery:WebIngress>helloCell.components["helloComp"]["ingresses"]["webUI"];
        web.gatewayConfig.vhost = vhostName;
    }

    string helloName = config:getAsString("HELLO_NAME");
    if (helloName !== "") {
        helloCell.components["helloComp"]["envVars"]["HELLO_NAME"].value = helloName;
    }
    return <@untainted> cellery:createInstance(helloCell, iName, instances, startDependencies, shareDependencies);
}
```
---

Follow below instructions to build, run and push the hello world cell.

1. Build the cell image for hello-world project by executing the `cellery build` command as shown below. Note `CELLERY_HUB_ORG` is your organization name in [cellery hub](https://hub.cellery.io/).
    ```
    $ cellery build hello-world.bal <CELLERY_HUB_ORG>/hello-world-cell:latest
    Hello World Cell Built successfully.
    
    ✔ Building image <CELLERY_HUB_ORG>/hello-world-cell:latest
    ✔ Saving new Image to the Local Repository
    
    
    ✔ Successfully built cell image: <CELLERY_HUB_ORG>/hello-world-cell:latest
    
    What's next?
    --------------------------------------------------------
    Execute the following command to run the image:
      $ cellery run <CELLERY_HUB_ORG>/helloworld:latest
    --------------------------------------------------------
    ```

2. As mentioned above in the [hello-world.bal](hello-world.bal), `VHOST_NAME` and `HELLO_NAME` are used as input parameters to the `hello` component. 
Therefore, run the hello-world cell image with ‘cellery run’ command with input parameters `my-hello-world.com` for `VHOST_NAME`, and your name for `HELLO_NAME` 
as shown below to change the hello-world cell's default behaviour. 
    ```
    $ cellery run <CELLERY_HUB_ORG/hello-world-cell:latest -e VHOST_NAME=my-hello-world.com -e HELLO_NAME=WSO2 -n my-hello-world
       ✔ Extracting Cell Image  <CELLERY_HUB_ORG/hello-world-cell:latest
       
       Main Instance: my-hello-world
       
       ✔ Reading Cell Image  <CELLERY_HUB_ORG/hello-world-cell:latest
       ✔ Validating environment variables
       ✔ Validating dependencies
       
       Instances to be Used:
       
         INSTANCE NAME              CELL IMAGE                        USED INSTANCE   SHARED
        ---------------- ------------------------------------------- --------------- --------
         my-hello-world    <CELLERY_HUB_ORG>/hello-world-cell:latest   To be Created    -
       
       Dependency Tree to be Used:
       
        No Dependencies
       
       ? Do you wish to continue with starting above Cell instances (Y/n)?
       
       ✔ Starting main instance my-hello-world
       
       
       ✔ Successfully deployed cell image:  <CELLERY_HUB_ORG>/hello-world-cell:latest
       
       What's next?
       --------------------------------------------------------
       Execute the following command to list running cells:
         $ cellery list instances
       --------------------------------------------------------
    ```
    
3. Now hello-world cell is deployed, execute `cellery list instances` to see the status of the deployed cell.
    ```
    $ cellery list instances
                        INSTANCE                                   CELL IMAGE                   STATUS                            GATEWAY                            COMPONENTS           AGE
       ------------------------------------------ -------------------------------------------- -------- ----------------------------------------------------------- ------------ ----------------------
        hello-world-cell-1-0-0-676b2131           <CELLERY_HUB_ORG>/hello-world-cell:latest      Ready       hello-world-cell-1-0-0-676b2131--gateway-service             1        10 minutes 1 seconds
    ```
4. Execute `cellery view` to see the components of the cell. This will open a webpage in a browser that allows to visualize the components and dependent cells of the cell image.
    ```
    $ cellery view <CELLERY_HUB_ORG>/hello-world-cell:latest
    ```
    ![hello world cell view](../../docs/images/hello-world/hello-web-cell.png)
    
5. Access url [http://my-hello-world.com/](http://my-hello-world.com/) from browser. You will see updated web page with greeting param you passed for HELLO_NAME in step-2.
Make sure you have configured the host entries correctly as mentioned in [local](https://github.com/wso2-cellery/sdk/blob/v0.3.0/docs/setup/local-setup.md), 
[gcp](https://github.com/wso2-cellery/sdk/blob/v0.3.0/docs/setup/gcp-setup.md#configure-host-entries) and [existing cluster](https://github.com/wso2-cellery/sdk/blob/v0.3.0/docs/setup/existing-cluster.md#configure-host-entries).

6. As a final step, let's push your first cell project to your [cellery hub](https://hub.cellery.io/) account as shown below.
    ```
    $ cellery push <CELLERY_HUB_ORG>/hello-world-cell:latest
    ✔ Connecting to registry-1.docker.io
    ✔ Reading image <CELLERY_HUB_ORG>/hello-world-cell:latest from the Local Repository
    ✔ Checking if the image <CELLERY_HUB_ORG>/hello-world-cell:latest already exists in the Registry
    ✔ Pushing image <CELLERY_HUB_ORG>/hello-world-cell:latest
    
    Image Digest : sha256:8935b3495a6c1cbc466ac28f4120c3836894e8ea1563fb5da7ecbd17e4b80df5
    
    ✔ Successfully pushed cell image: <CELLERY_HUB_ORG>/hello-world-cell:latest
    
    What's next?
    --------------------------------------------------------
    Execute the following command to pull the image:
      $ cellery pull <CELLERY_HUB_ORG>/hello-world-cell:latest
    --------------------------------------------------------
    ```
Congratulations! You have successfully created your own cell!
 
Please feel free to checkout this repository and play around with the sample as explained [here](../../src/hello-world)

## What's Next? 
1. [Try hello world Api](../hello-world-api)
2. [Try pet store](../pet-store)
