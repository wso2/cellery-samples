Hello world web application
=========

The hello-world webapp is written in Node.js and it is a simple webapp. Try out this sample as cell as explained [here.](../../cells/hello-world)

## Building the Components from Source

You do not need to build the components if you just wish to deploy the cells. This should only be done if you wish to change the Hello World sample and play around with it.

### Prerequisites
* Docker
* GNU Make 4.1+

### Building the Components

If you wish to change the Hello World Sample and play around with Cellery, you can follow this section to rebuild the Components.

1. Clone the [wso2/cellery-samples](https://github.com/wso2/cellery-samples) repository
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
6. Update the `<SAMPLES_ROOT>/cell/hello-world/hello-world-web.bal` file and set the newly created image names for the Component source.
7. [Build and run](../../cells/hello-world#2-build-run-and-push-hello-world-cell) the Cells.
