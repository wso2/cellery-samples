Pet Store
=========

Pet Store is a web portal which can be used by the customers for ordering accessories for their Pets.

This sample is a simple Web App which consists of 5 Docker images (4 microservices and a container to serve the web portal). 

* Catalog (Catalog of the accessories available in the pet store)
* Customers (Existing customers of the Pet Store)
* Orders (Orders placed at the Pet Store by Customers)
* Controller (Controller service which fetches data from the above 3 microservices and processes them to provide useful functionality)
* Portal (A simple Node JS container serving a React App with Server Side Rendering)

All 4 micro services are implemented in [node.js](https://nodejs.org/en/) and portal web application is a [React](https://reactjs.org/) application. 

This sample is structured into two Cells.

* [pet-be Cell](#pet-be-cell)
* [pet-fe Cell](#pet-fe-cell)

![Pet Store Cell Architecture Diagram](../docs/images/pet-store/pet-store-architecture.jpg)

## [pet-be cell](pet-be-cell-description.md)
This contains the four components which involves with working with the Pet Store data and business logic. Catalog, customer, and order micro services
are not exposed outside the pet-be cell, and only catalog micro service exposed as cell API which is used by pet-fe cell. 

## [pet-fe Cell](pet-fe-cell-description.md)
This contains of a single component which serves the portal. The portal is exposed through a web cell which is able to provide SSO and web content delivery features.

## Getting Started

### Checkout the Sample

1. Clone the [wso2-cellery/samples](https://github.com/wso2-cellery/samples) repository
2. Navigate to the pet-store Sample.
   ```
   cd <SAMPLES_ROOT>/pet-store
   ```

### Build backed cell
1.  Build the pet-be Cell by executing `cellery build` command as shown below. 
   ```
   $ cd <SAMPLES_ROOT>/pet-store/backend
   $ cellery build pet-be.bal wso2cellery/pet-be:0.1.0
   Warning: Value is empty for environment variable "ORDER_HOST"
   Warning: Value is empty for environment variable "CATALOG_HOST"
   Warning: Value is empty for environment variable "CUSTOMER_HOST"
   true
   ✔ Building image wso2cellery/pet-be:0.1.0
   ✔ Removing old Image
   ✔ Saving new Image to the Local Repository
   
   
   ✔ Successfully built cell image: wso2cellery/pet-be:0.1.0
   
   What's next?
   --------------------------------------------------------
   Execute the following command to run the image:
     $ cellery run wso2cellery/pet-be:0.1.0
   --------------------------------------------------------
   ```
2. View the cell information by executing `cellery view` command. This will open up a new tab in the browser and shows 
the component and dependency details of the cell. 
    ```
    $ cellery view wso2cellery/pet-be:0.1.0
    ```
    ![pet fe view](../docs/images/pet-store/pet-be-view.png)
    
### Running the Frontend Cell
1. Build the pet-fe cell by executing the `cellery build` command.
   ```
   $ cd <SAMPLES_ROOT>/pet-store/frontend
   $ cellery build pet-fe.bal wso2cellery/pet-fe:0.1.0
   Warning: Value is empty for environment variable "PET_STORE_CELL_URL"
   true
   ✔ Building image wso2cellery/pet-fe:0.1.0
   ✔ Removing old Image
   ✔ Saving new Image to the Local Repository
   
   
   ✔ Successfully built cell image: wso2cellery/pet-fe:0.1.0
   
   What's next?
   --------------------------------------------------------
   Execute the following command to run the image:
     $ cellery run wso2cellery/pet-fe:0.1.0
   --------------------------------------------------------
   ```
2. View the inner components and cell dependency of cell wso2cellery/pet-fe:0.1.0.
    ```
    $ cellery view wso2cellery/pet-fe:0.1.0
    ```
    ![pet fe view](../docs/images/pet-store/pet-fe-view.png)

3. Run the pet-fe cell with instance name `pet-fe`, and provide the dependent pet-be cell instance as `pet-be`. 
As we haven't started the pet-be cell instance, we'll pass `-d` or `--start-dependencies` flag with run command to 
start dependent cell instance if it is not available in the runtime.
   ```
   $ cellery run wso2cellery/pet-fe:0.1.0 -n pet-fe -l petStoreBackend:pet-be -d
   ✔ Extracting Cell Image wso2cellery/pet-fe:0.1.0
   
   Main Instance: pet-fe
   
   ✔ Reading Cell Image wso2cellery/pet-fe:0.1.0
   ✔ Validating dependency links
   ✔ Generating dependency tree
   ✔ Validating dependency tree
   
   Instances to be Used:
   
     INSTANCE NAME          CELL IMAGE          USED INSTANCE   SHARED
    --------------- -------------------------- --------------- --------
     pet-be          wso2cellery/pet-be:0.1.0   To be Created    -
     pet-fe          wso2cellery/pet-fe:0.1.0   To be Created    -
   
   Dependency Tree to be Used:
   
    pet-fe
      └── petStoreBackend: pet-be
   
   ? Do you wish to continue with starting above Cell instances (Y/n)?
   
   ✔ Starting instance pet-be
   ✔ Starting dependencies
   ✔ Starting main instance pet-fe
   
   
   ✔ Successfully deployed cell image: wso2cellery/pet-fe:0.1.0
   
   What's next?
   --------------------------------------------------------
   Execute the following command to list running cells:
     $ cellery list instances
   --------------------------------------------------------
   ```
3. Optionally check the status of the running cell pet-fe.
   ```
   $ cellery status pet-fe
           CREATED         STATUS
    --------------------- --------
     5 minutes 3 seconds   Ready
   
   
     -COMPONENTS-
   
      NAME               STATUS
    --------- -----------------------------
     gateway   Up for 4 minutes 52 seconds
     portal    Up for 4 minutes 49 seconds
     sts       Up for 4 minutes 55 seconds
   ```
4. Access the petstore add via accessing [http://pet-store.com/](http://pet-store.com/), and this will redirect to 
login page at the default Identity Provider in the cellery runtime. 

5. You can sign into the pet-store as user alice (Username: alice, Password: alice123), check for orders, and logout. 
Alice will be having two orders placed in the pet-store by default. 

6. You can sign in to the pet-store application as user admin (Username: admin, Password:admin), and check for orders. 
In this case, Admin user will not have any orders. 

Please feel free to checkout this repository and play around with the sample.

## Observability 
If you have installed complete setup or basic setup with observability enabled, you can follow below steps to view the cellery observability.

1) Go to [http://cellery-dashboard](http://cellery-dashboard) 



## Building the Components from Source

You do not need to build the Components if you just wish to deploy the Cells. This should only be done if you wish to change the Pet Store sample and play around with it.

### Prerequisites

* Docker
* Node & NPM
* GNU Make 4.1+

### Building the Components

If you wish to change the Pet Store Sample and play around with Cellery, you can follow this section to rebuild the Components.

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
6. Update the `<SAMPLES_ROOT>/pet-store/backend/pet-be.bal` and `<SAMPLES_ROOT>/pet-store/frontend/pet-fe.bal` files and set the newly created image names for the Component source.
7. [Build and run](#getting-started) the Cells.
