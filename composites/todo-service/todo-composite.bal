//   Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.

// Composite file that wraps a todo micro service and mysql database.
import celleryio/cellery;

public function build(cellery:ImageName iName) returns error? {
    int mysqlPort = 3306;
    string mysqlPassword = "root";

    //Mysql database service which stores the todos that were added via the todos service
    cellery:Component mysqlComponent = {
            name: "mysql-db",
            src: {
                image: "docker.io/wso2cellery/samples-todoapp-mysql:latest"
            },
            ingresses: {
                orders:  <cellery:TCPIngress>{
                    backendPort: mysqlPort
                }
            },
            envVars: {
                MYSQL_ROOT_PASSWORD: {value: "root"}
            }
     };

    //This is the todos service which receieves the todo requests and connects
    // to database to persists the information.
    cellery:Component todoServiceComponent = {
        name: "todos",
        src: {
            image: "docker.io/wso2cellery/samples-todoapp-todos:latest"
        },
        ingresses: {
            todo:  <cellery:HttpPortIngress>{
                port: 8080
            }
        },
        envVars: {
            PORT: {value: "8080"},
            DATABASE_HOST: {value:  cellery:getHost(mysqlComponent)},
            DATABASE_PORT : {value: mysqlPort},
            DATABASE_USERNAME: {value: "root"},
            DATABASE_PASSWORD: {value: mysqlPassword},
            DATABASE_NAME: {value: "todos_db"}
        },
        dependencies: {
            components: [mysqlComponent]
         }
    };

    // Composite Initialization
    cellery:Composite composite = {
        components: {
            mysql: mysqlComponent,
            todoService: todoServiceComponent
        }
    };
    return <@untainted> cellery:createImage(composite,  iName);
}

public function run(cellery:ImageName iName, map<cellery:ImageName> instances, boolean startDependencies, boolean shareDependencies)
       returns (cellery:InstanceState[]|error?) {
    cellery:Composite composite = check cellery:constructImage( iName);
    return <@untainted> cellery:createInstance(composite, iName, instances, startDependencies, shareDependencies);
}
