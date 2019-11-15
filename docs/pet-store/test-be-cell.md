## Writing Integration Tests for Pet-Store

### Prerequisites:
 
 * [Telepresence 0.101](https://www.telepresence.io/reference/install) dependencies.
 
    Cellery testing uses Telepresence. Hence Telepresence dependencies have to be installed. In order to
     install, run below commands depending on your OS.
     
     **Mac OS**
     
     In order to run below commands you need to have brew installed
     ```bash
   brew cask install osxfuse
   brew install datawire/blackbird/telepresence --only-dependencies
     ```
   
   **Ubuntu**
   
     ```bash
     sudo apt-get install $(apt-cache depends telepresence | grep Depends | sed "s/.*ends:\ //" | tr '\n' ' ')
     ```
 * A Cellery runtime must be running. (Local, GCP, etc..)
 
 * Note : If you have set your DNS to ```8.8.8.8```, remove it before proceeding. (You can use any other DNS except
  ```8.8.8.8```). This is due to a bug in Telepresence which emerges since we set ```8.8.8.8``` as cluster DNS.

 
 ### Quick Test Run
 
 wso2cellery/pet-be-cell image is already built with tests and those tests can be started by executing the below
  command once you satisfy prerequisites. The image will be pulled automatically from Cellery-Hub and will start the
   execution of tests.
 
 ```bash
cellery test wso2cellery/pet-be-cell:latest -n pet-be
```
 
 If you keep observing the pods in your cluster, you will see there are pods which are related to pet-fe-cell are
  getting deployed while tests are running and tearing them up once the tests are completed. Once the test run is
   completed, the status of tests will be printed which contains two sections as ballerina tests and maven tests. 
 
### Writing Cellery tests
 
As outlined in [Cellery Testing](https://github.com/wso2-cellery/sdk/blob/master/docs/cell-testing.md), developer
 has the flexibility to write two separate types of integration tests along with a combination of those two. 
 
#### Writing Cellery tests involve below steps, 

1) [Initialize a ballerina project in the sample root directory (optional)](#initialize-a-ballerina-project-in-the-sample-root-directory)
2) [Write inline ballerina test file](#write-inline-ballerina-test-file)
3) [Build the cell image](#build-the-cell-image)
4) [Run Cellery test command](#run-cellery-test-command)
5) [Debugging tests](#debugging-tests)

##### 1) Initialize a ballerina project in the sample root directory

According to the Ballerina specifications, a Ballerina project is required to run tests. By making it a ballerina 
project, one can simply reuse functions in the cell bal file in the test bal file without having to rewrite the logic.

Eg: using ```run()``` function to create instances in the @BeforeSuite function.
Else, the logic written in the cell file has to be repeated in the test file.

```ballerina
$ cd <samples-root>/cells/pet-store
$ cellery init test pet-be/pet-be.bal
```

The above steps will convert the current sample directory structure to a ballerina project as shown below.

New project structure:
```bash
pet-store
└── pet-be_proj/
    ├── Ballerina.toml
    └── src
        └── pet-be
            ├── pet-be.bal
            └── tests
                └── pet-be_test.bal
```


[back to top](#writing-cellery-tests-involve-below-steps)

##### 2) Write ballerina test file

Modify the test file pet-be_test.bal generated from the previous step. You can rename the fie or add more test
file in the same directory.

Developer writes test file assuming the services which are exposed by the Cell gateway is running in the developer 
local machine. Final
  pet-be-test.bal would look like [this](https://github.com/wso2-cellery/samples/blob/master/cells/pet-store/pet-be/tests/pet-be-test.bal). Let's walk through each section and figure out what is taking place.
  

The below snippet of code is meant to run before the actual tests run and ```@test:BeforeSuite``` is used to
 denote it.  

 Image / Instance name is retrieved through the [```getCellImage``` helper function](https://github.com/wso2-cellery/sdk/blob/master/docs/cell-testing.md#functiongetcellimage)  and the [```run```](https://github.com/wso2-cellery/sdk/blob/master/docs/cell-testing.md#functionrun) method is executed in order to deploy / run the actual Cell in the
  cluster. Image name, dependencies (no dependencies in this case) are passed to the ```run``` method along with
   ```startDependencies=true``` and ```shareDependencies=true```. This returns the list of instances started or an
    error if it doesn't.
    
 Endpoints exposed by the cell are retrieved using the [```getCellEndpoints``` helper function](https://github.com/wso2-cellery/sdk/blob/master/docs/cell-testing.md#functiongetcellendpoints)
    
  ```ballerina
  
cellery:InstanceState[] instanceList = [];
string PET_BE_CONTROLLER_ENDPOINT = "";

# Handle creation of instances for running tests
@test:BeforeSuite
function setup() {
    cellery:ImageName iName = <cellery:ImageName>cellery:getCellImage();
    cellery:InstanceState[]|error? result = run(iName, {}, true, true);
    io:println(result);
    if (result is error) {
        cellery:InstanceState iNameState = {
            iName : iName, 
            isRunning: true
        };
        instanceList[instanceList.length()] = <@untainted> iNameState;
    } else {
        instanceList = <cellery:InstanceState[]>result;
    }

    cellery:Reference petBeUrls = <cellery:Reference>cellery:getCellEndpoints(<@untainted> instanceList);
    PET_BE_CONTROLLER_ENDPOINT= <string>petBeUrls["controller_ingress_api_url"];
}  
``` 
Below is the snippet of code where actual integration tests are executed. Endpoints which are exposed through above
 started instances are retrieved through the  [```getCellEndpoints``` helper function](https://github.com/wso2-cellery/sdk/blob/master/docs/cell-testing.md#functiongetcellendpoints).
 Out of returned endpoints, the pet-be controller URL is retrieved and used to send out the request. Refer [pet-be-test.bal](https://github.com/wso2-cellery/samples/blob/master/cells/pet-store/pet-be/tests/pet-be-test.bal) for the omitted part of the code. 
 
```ballerina
@test:Config
function testInsertOrder() {

    // Send the request to endpoint and retrieve response

    string responseStr = handleResponse(response);
    test:assertTrue(
        responseStr.hasPrefix(expectedPostResponsePrefix), 
        msg = "Order insertion failed.\n Expected: \n" + expectedPostResponsePrefix + "\n Actual: \n" + responseStr
    );
}
```
At the end, all instances which are started for the purpose of testing are teared down. ```@test:AfterSuite``` is
 used to denote this must be taken place upon the completion of test suite. 

```ballerina
@test:AfterSuite
public function cleanUp() {
    error? err = cellery:stopInstances(instanceList);
}
```
##### Writing docker image based Cellery tests

Cellery also supports running tests written in other languages by containerizing it in a docker image. Cellery 
facilitates the helper function [```runDockerTest``` helper function](https://github.com/wso2-cellery/sdk/blob/master/docs/cell-testing.md#functionrundockertest)

Below are the steps to be followed in order to implement docker based tests for your Cell files.

Writing docker image based Cellery tests involve below steps,

1) [Write tests, create a Dockerfile and push it to DockerHub](#write-tests-create-a-dockerfile-and-push-it-to-dockerhub)
2) [Define test function in the test bal file](#define-test-function-in-the-test-bal-file)
3) [Build the cell image](#build-the-cell-image)
3) [Run Cellery test command to test the cell](#run-cellery-test-command-to-test-the-cell)
5) [View logs](#view-logs)


##### i) Write tests, create a Dockerfile and push it to DockerHub

As highlighted previously developers can select any framework and language to develop the test. For pet-be we have
 used a set of [integration tests](https://github.com/wso2-cellery/samples/blob/master/tests/pet-store/pet-be/order/src/test/java/io/cellery/test/petstore/be/PetBeTest.java) written using Java and TestNG. This set of tests is built
  as a [docker image](https://github.com/wso2-cellery/samples/blob/master/tests/pet-store/pet-be/Dockerfile) and
   pushed into DockerHub. The name of the image is ```docker.io/wso2cellery/pet-be-tests```.

##### ii) Define test function in the test bal file


```ballerina
@test:Config {}
function testDocker() {
    map<cellery:Env> envVars = {PET_BE_CELL_URL: { value: PET_BE_CONTROLLER_ENDPOINT }};
    error? err = cellery:runDockerTest("docker.io/wso2cellery/pet-be-tests", envVars);
    test:assertFalse(err is error);
}
```

[back to top](#writing-cellery-tests-involve-below-steps)

##### 3) Build the cell image

Build the Cell image using below command. Building cell creates Cell image which consist of the tests implemented 
inside ```tests/pet-be_tests.bal``` as well. 
  
``` cellery build <BAL_FILE_NAME> <ORGANIZATION_NAME>/<IMAGE_NAME>:<VERSION> ```

[back to top](#writing-cellery-tests-involve-below-steps)

##### 4) Run ```cellery test``` command

All flags supported in ```cellery run``` command are applicable to ```cellery test``` command as well.

```bash
$ cellery test <ORGANIZATION_NAME>/<IMAGE_NAME>:<VERSION> [-n <CELL_INSTANCE_NAME-2>] [-l <ALIAS>:<CELL_INSTANCE_NAME-1>] [-v]

-n instance name
-l dependency cell instance name
-v verbose mode
```
[back to top](#writing-in-line-cellery-tests-involve-below-steps)
  
##### 5) View Logs

Ballerina currently does not generate any log files and therefore this command is only applicable to docker image
 based tests. A ```target``` folder is created in the place you run ```cellery test``` and you can find the log
  file inside it.

```bash
$ cat pet-be.log
```

##### 6) Debugging tests

##### In order to debug tests, debug mode must be enabled while starting tests using ```--debug -p <PROJECT_LOCATION>```.

```bash
$ cellery test <ORGANIZATION_NAME>/<IMAGE_NAME>:<VERSION> [-n <CELL_INSTANCE_NAME-2>] [-l <ALIAS>:<CELL_INSTANCE_NAME
-1>] [-v] --debug -p <BALLERINA_PROJECT_LOCATION>
```
The above command starts Telepresence and open the Telepresence shell allowing the user to debug the test using
 the IDE.

To exit debug mode, execute the command ```exit``` in the Telepresence shell.

```bash
@gke_vick-team_us-west1-b_cellery-cluster351|bash-4.3$ exit

```

Note: Ballerina does not support remote debugging for tests yet and therefore the VSCode debugger should be used. The
 aforementioned [```test``` command](#in-order-to-debug-tests-debug-mode-must-be-enabled-while-starting-tests-using---debug) creates a ballerina.conf or replaces existing with in order to
  debug. This is to pass cellery configurations to the debug process. If you are not familiar with VS code please refer 
  official documentation on [configuring launch.json](https://code.visualstudio.com/docs/editor/debugging#_launch-configurations)

# What's Next?
- [Observe the pet-store](observability.md) - This shows how you can observe and understand the runtime operations to the pet-store application.
- [Update pet-be cell](component-patch-and-adv-deployment.md#cell-component-update) - provides the steps to update the components of the pet-be cell.
- [Advanced deployments with pet-be cell](component-patch-and-adv-deployment.md#blue-green-and-canary-deployment) - perform advanced deployments with pet-be cell.
- [Scale pet-be cell](scale-cell.md) - walks through the steps to scale pet-be cell with horizontal pod autoscaler, and zero scaling with Knative. 
- [Pet store sample](../../cells/pet-store/README.md) - provides the instructions to work with pet-store sample.
