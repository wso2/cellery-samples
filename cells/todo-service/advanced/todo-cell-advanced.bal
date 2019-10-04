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
import ballerina/io;
import ballerina/config;

public function build(cellery:ImageName iName) returns error? {
    int mysqlPort = 3306;
    string mysqlPassword = "root";
    string mysqlScript = readFile("./mysql/init.sql");
    //Mysql database service which stores the todos that were added via the todos service
    cellery:Component mysqlComponent = {
        name: "mysql-db",
        source: {
            image: "library/mysql:8.0"
        },
        ingresses: {
            orders:  <cellery:TCPIngress>{
                    backendPort: mysqlPort
                }
        },
        envVars: {
            MYSQL_ROOT_PASSWORD: {
                value: "root"
            }
        },
        volumes: {
            sqlconfig: {
                path: "/docker-entrypoint-initdb.d",
                readOnly: false,
                volume:<cellery:NonSharedConfiguration>{
                     name:"init-sql",
                     data:{
                        "init.sql":mysqlScript
                     }
                }
            },
            volumeClaim: {
                path: "/var/lib/mysql",
                readOnly: false,
                volume:<cellery:K8sNonSharedPersistence>{
                     name:"data-vol",
                     storageClass:"local-storage",
                     accessMode: ["ReadWriteOnce"],
                     request:"1G"
                }
            }
        }
    };

    // This is the todos service which receives the to-do requests and connects
    // to database to persists the information.
    cellery:Component todoServiceComponent = {
        name: "todos",
        source: {
            image: "docker.io/wso2cellery/samples-todoapp-todos:latest-dev"
        },
        ingresses: {
            todo:  <cellery:HttpApiIngress>{
                   port: 8080,
                   context: "/todos",
                   definition:{
                       resources: [
                          {
                              path: "/",
                              method: "GET"
                          },
                          {   path: "/",
                              method: "POST"
                          },
                          {
                              path: "/*",
                              method: "GET"
                          },
                          {
                              path: "/*",
                              method: "PUT"
                          }
                       ]
                   },
                   expose:"global",
                   authenticate:false
               }
        },
        envVars: {
            PORT: {
                value: "8080"
            },
            DATABASE_HOST: {
                value: cellery:getHost(mysqlComponent)
            },
            DATABASE_PORT: {
                value: mysqlPort
            },
            DATABASE_NAME: {
                value: "todos_db"
            },
            DATABASE_CREDENTIALS_PATH: {
                value: "/credentials"
            }
        },
        volumes: {
            secret: {
                path: "/credentials",
                readOnly: false,
                volume:<cellery:SharedSecret>{
                    name:"db-credentials"
                }
            }
        },
        dependencies: {
            components: [mysqlComponent]
        }
    };

    // Composite Initialization
    cellery:CellImage cellImage = {
        components: {
            mysql: mysqlComponent,
            todoService: todoServiceComponent
        }
    };
    return cellery:createImage(cellImage, untaint iName);
}

public function run(cellery:ImageName iName, map<cellery:ImageName> instances, boolean startDependencies, boolean shareDependencies)
returns (cellery:InstanceState[] | error?) {
    string db_user = config:getAsString("MYSQL_USERNAME");
    string db_pwd = config:getAsString("MYSQL_PASSWORD");
    if (db_user == "" || db_pwd == "") {
            panic error("MYSQL_USERNAME or MYSQL_PASSWORD not found in environment");
    }
    cellery:NonSharedSecret mysqlCreds = {
        name: "db-credentials",
        data: {
            username: db_user,
            password: db_pwd
        }
    };
    error? e = cellery:createSecret(mysqlCreds);
    cellery:CellImage todoCell = check cellery:constructImage(untaint iName);
    return cellery:createInstance(todoCell, iName, instances, startDependencies, shareDependencies);
}


function readFile(string filePath) returns (string) {
    io:ReadableByteChannel bchannel = io:openReadableFile(filePath);
    io:ReadableCharacterChannel cChannel = new io:ReadableCharacterChannel(bchannel, "UTF-8");

    var readOutput = cChannel.read(5000);
    if (readOutput is string) {
        return readOutput;
    } else {
        return "Error: Unable to read file " + filePath;
    }
}
