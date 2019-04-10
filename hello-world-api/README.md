Hello world API cell
===============

Hello World API sample is a simple rest API that returns the text 'Hello World!' as a response to a GET request.

![Hello World API Cell Architecture Diagram](../docs/images/hello-world-api/hello-world-api-architecture.jpg)

##### Note: To run this sample, a cellery deployment which includes API Manager component is required (complete cellery deployment or basic celley deployment with APIM is required).

## Try hello world api sample

### 1. Checkout the Sample

1. Clone the [wso2-cellery/samples](https://github.com/wso2-cellery/samples) repository
2. Navigate to the hello-world-api Sample.
   ```
   cd <SAMPLES_ROOT>/hello-world-api
   ```
### 2. Build and run hello world web cell
In this section let's focus on build, run and push a [hello world api cell](hello-world-api.bal). 

The cell `helloCell` consists of one component defined as `helloComponent` and it has one http api ingress which is 
exposed as `global` API.

```
import ballerina/io;
import celleryio/cellery;

//Hello World Component
cellery:Component helloComponent = {
    name: "hello-api",
    source: {
        image: "docker.io/wso2cellery/samples-hello-world-api"
    },
    ingresses: {
        helloApi: <cellery:HttpApiIngress>{ port: 9090,
            context: "hello",
            definition: {
                resources: [
                    {
                        path: "/",
                        method: "GET"
                    }
                ]
            },
            expose: "global"
        }
    }
};

cellery:CellImage helloCell = {
    components: {
        helloComp: helloComponent
    }
};

public function build(cellery:ImageName iName) returns error? {
    //Build Hello Cell
    io:println("Building Hello World Cell ...");
    return cellery:createImage(helloCell, iName);
}
```

#### Follow below instructions to build and run the hello world api cell.

1. Build the cellery image for hello world project by executing the cellery build command as shown below. Note `DOCKER_HUB_ORG` is your organization name in docker hub.
    ```
    $ cellery build hello-world-api.bal <DOCKER_HUB_ORG>/hello-world-api-cell:1.0.0
    Hello World Cell Built successfully.
    
    ✔ Building image <DOCKER_HUB_ORG>/hello-world-api-cell:1.0.0
    ✔ Saving new Image to the Local Repository
    
    
    ✔ Successfully built cell image: <DOCKER_HUB_ORG>/hello-world-api-cell:1.0.0
    
    What's next?
    --------------------------------------------------------
    Execute the following command to run the image:
      $ cellery run <DOCKER_HUB_ORG>/helloworld:1.0.0
    --------------------------------------------------------
    ```

2. Run the cell image by executing `cellery run` command as shown below.
    ```
    $ cellery run <DOCKER_HUB_ORG>/hello-world-api-cell:1.0.0 -n hello-world-api-cell
       ✔ Extracting Cell Image  <DOCKER_HUB_ORG/hello-world-api-cell:1.0.0
       
       Main Instance: my-hello-world
       
       ✔ Reading Cell Image  <DOCKER_HUB_ORG/hello-world-api-cell:1.0.0
       ✔ Validating environment variables
       ✔ Validating dependencies
       
       Instances to be Used:
       
         INSTANCE NAME                     CELL IMAGE                         USED INSTANCE   SHARED
       ---------------------- --------------------------------------------- --------------- --------
        hello-world-api-cell    <DOCKER_HUB_ORG>/hello-world-api-cell:1.0.0   To be Created    -
       
       Dependency Tree to be Used:
       
        No Dependencies
       
       ? Do you wish to continue with starting above Cell instances (Y/n)?
       
       ✔ Starting main instance my-hello-world
       
       
       ✔ Successfully deployed cell image:  <DOCKER_HUB_ORG>/hello-world-api-cell:1.0.0
       
       What's next?
       --------------------------------------------------------
       Execute the following command to list running cells:
         $ cellery list instances
       --------------------------------------------------------
    ```
    
3. Now your hello world cell is deployed, you can run the cellery list instances command to see the status of the deployed cell.
    ```
    $ cellery list instances
                        INSTANCE                                   CELL IMAGE                   STATUS                            GATEWAY                               COMPONENTS           AGE
       ------------------------------------------ -------------------------------------------- -------- -------------------------------------------------------------- ------------ ----------------------
        hello-world-api-cell-1-0-0-676b2131           sinthuja/hello-world-api-cell:1.0.0       Ready    sinthuja-hello-world-api-cell-1-0-0-676b2131--gateway-service   1            10 minutes 1 seconds
    ```
4. Execute `cellery view` to see the components of your cell. This will open a HTML page in a browser and you can visualize the components and dependent cells of the cell image.
    ```
    $ cellery view <DOCKER_HUB_ORG>/hello-world-api-cell:1.0.0
    ```
    ![hello world api cell view](../docs/images/hello-world-api/hello-world-cell-api-docs-view.png)
    
### 3. Obtain access token and invoke API

Since the hello-world-api is exposed via the global gateway, the request can go through the global API gateway to the hello world service. 
And, by default all the APIs are secured, therefore we need to obtain a token to invoke the API. The below provided steps explains the process to obtain the token and invoke the API.
       
1. Login to the [API Store](https://wso2-apim/store/) as admin user (username: admin, password: admin).
    
2. Click on ‘my_hello_api_global_1_0_0_hello’ to create a subscription and generate a token. 
(See  [Subscribing to an API](https://docs.wso2.com/display/AM260/Subscribe+to+an+API))
       
3. Once you have subscribed to the API and generated a token, invoke the API passing the same as a Bearer token:
   ```
   $ curl -H "Authorization: Bearer <token>" https://wso2-apim-gateway/hello-world-api-cell/hello/ -k
   Hello World!
   ```

Congratulations! You have successfully tried out the hello world api sample! 

## Building the Components from Source

You do not need to build the Components if you just wish to deploy the Cells. This should only be done if you wish to change the Hello World API sample and play around with it.

### Prerequisites

* Docker
* GNU Make 4.1+

### Building the Components

If you wish to change the Hello World API Sample and play around with Cellery, you can follow this section to rebuild the Components.

1. Clone the [wso2-cellery/samples](https://github.com/wso2-cellery/samples) repository to your `GO_PATH/src/github.com/wso2cellery` directory. 
2. Set the following environment variables for customizing the build.

   | Environment Variable  |                                                                       |
   |-----------------------|-----------------------------------------------------------------------|
   | DOCKER_REPO           | The name of the repository of the Docker images (Your Docker Hub ID)  |
   | DOCKER_IMAGE_TAG      | The tag of the Docker images                                          |

3. Run the make target for building docker images.
   ```
   make docker
   ```
   This would build the components from source and build the docker images using the environment variables you have provided.
4. Login to Docker Hub
   ```
   docker login
   ```
5. Run the target for pushing the docker images.
   ```
   make docker-push
   ```
6. Update the `<SAMPLES_ROOT>/hello-world-api/hello-world-api.bal` file and set the newly created image names for the component source.
7. [Build and run](#2.-build-and-run-hello-world-web-cell) the Cells.
