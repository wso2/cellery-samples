Hello World API
===============

Hello World API sample is a simple rest API that returns the text 'Hello World!' as a response to a GET request.

## Getting Started

##### Note: To run this sample, a full Cellery deployment which includes API Manager component is required.

### Checkout the Sample

1. Clone the [wso2-cellery/samples](https://github.com/wso2-cellery/samples) repository.

2. Navigate to the hello-world-api Sample.
   ```
   cd <SAMPLES_ROOT>/hello-world-api
   ```

### Running the Hello World API Cell

1. Build the hello-world-api Cell.
   ```
   cellery build hello-world-api.bal wso2cellery/hello-world-api:0.1.0
   ```
2. Deploy the hello-world Cell
   ```
   cellery run wso2cellery/hello-world-api:0.1.0 -n my-hello-api
   ```
3. Check the running Cell. 
   ```
   cellery status my-hello-api
   ```
   Once the status becomes 'Ready' you can go ahead and invoke it. 
   
4. Invoking the Hello World API

    By default, the Cellery installation will be using the following domain names for the relevant components in Cellery: 
    * cellery-dashboard
    * wso2-apim-gateway
    * cellery-k8s-metrics
    * wso2-apim
    * idp.cellery-system
    * wso2sp-observability-api
    
    These domains should be mapped to the IP of Kubernetes Ingress Controller in the Cellery installation.   
    
    To invoke the API, an oauth2 token should be obtained from the API store, as described in the following steps:
    
    1. Login to the [API Store](https://wso2-apim/store/) using admin:admin credentials.
    
    2. Click on ‘my_hello_api_global_1_0_0_hello’ to create a subscription and generate a token. 
       (See  [Subscribing to an API](https://docs.wso2.com/display/AM260/Subscribe+to+an+API))
       
    Once you have subscribed to the API and generated a token, invoke the API passing the same as a Bearer token:
    ```
    curl -H "Authorization: Bearer <token>" https://wso2-apim-gateway/my-hello-api/hello/ -kv
    ```

## Building the Components from Source

You do not need to build the Components if you just wish to deploy the Cells. This should only be done if you wish to change the Hello World API sample and play around with it.

### Prerequisites

* Docker
* GNU Make 4.1+

### Building the Components

If you wish to change the Hello World API Sample and play around with Cellery, you can follow this section to rebuild the Components.

1. [Checkout](#checkout-the-sample) the Sample
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
7. [Build and run](#getting-started) the Cells.
