Pet Store
=========
Pet Store is a web portal which can be used by the customers for ordering accessories for their Pets.

This sample is a simple webapp which consists of 5 Docker images (4 microservices and a container to serve the web portal). 

* Catalog (Catalog of the accessories available in the pet store)
* Customers (Existing customers of the Pet Store)
* Orders (Orders placed at the Pet Store by Customers)
* Controller (Controller service which fetches data from the above 3 microservices and processes them to provide useful functionality)
* Portal (A simple Node JS container serving a React App with Server Side Rendering)

All 4 micro services are implemented in [node.js](https://nodejs.org/en/) and portal web application is a [React](https://reactjs.org/) application. 
 
## Building the Components from Source

You do not need to build the Components if you just wish to deploy the Cells. This should only be done if you wish to change the Pet Store sample and play around with it.

### Prerequisites

* Docker
* Node & NPM
* GNU Make 4.1+

### Building the Components

If you wish to change the Pet Store Sample and play around with Cellery, you can follow this section to rebuild the Components.

1. Clone the [wso2-cellery/samples](https://github.com/wso2-cellery/samples) repository
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
6. Update the `<SAMPLES_ROOT>/cells/pet-store/pet-be/pet-be.bal` and `<SAMPLES_ROOT>/cells/pet-store/pet-fe/pet-fe.bal` files and set the newly created image names for the Component source.
7. [Build and run](../../cells/pet-store#2-build-pet-be-cell) the Cells.

## Did you try? 
1. [Hello world](../hello-world)
2. [Hello world Api](../hello-world-api)
