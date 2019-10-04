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
    cellery:NonSharedSecret mysqlCreds = {
        name: "db-credentials",
        data: {
            username: "@encrypted:AgCTLJ0bOw4p3v3xmkwPKvqHL6RdEFqfYwN0m3mh1XaTiWdf5P/cq/plQl9Kfhm6A//xjabLcKaUTvOtYKzp5o9B007hMeL4n3Bn7UoU3fhVcaFD0Hemj4k9MYSTh7UrnSgd2orKtRC7JzPPfWNdIYiIPkERfVwCID9m3rNOxl/p5FSCLLqtOqjBzedf9c+wUstDiSmrWdazp3AJAibpX85Ra3Z5mZya4Ar8uSWVTcfGWjumd1Kc++4vIK2n71ICxE1jBzOOMi98TGaBMHWr8lA+2LRnnQQQUt+4X8v/WTLMbDNCiaeRpXp6VAVeTLMMuQFG1ImI5bc7/V3tOMflIhMLqRNTL9aXwoCKP1TNVDytXXWN/jCjySbwsZRyEn7HMt2zFykMpzGT2t46ka3lV7mNowWR5FqlxRzpGpCtrS+tGE1nW3G9ZJsZMRN+qKFDla4XStxifd+XHKriqbp3U+TI3gp6cFOAgGs4F3NxFe2/YKYHoCFCbP7dTIbY7yGSFCf8nETUjFLUe8xfbJodvcWtEhHlR6AsWaHIt/Z7bdAHaJiXIH6khxXXlAjqYdNETtgvGFohTR8FKSq+6s4CcD6HhxOlQqccIwomKlLmM3c3lgAjaPvvImoIE9dYsYL9PjrKefDV/FVOKf42r8p1pcGW/9C+qW2GTBjY6HOb/dMTydQKna+f+bJGDEjlVSErwNwjrSivaw==",
            password: "@encrypted:AgCcLoxoq507i7V0WuRX6Pprgtsea0qf1HCscHD8XDWVr6NVFjHrblejhWIyHXjF+u+e2L6cWKnECqZfyrChYlK7Yf4df7nCdRo4ZYM0XcGUOkIoV4nY+9R6DHyJ87vi9qWGZcDyTiGnPAE2rsN7oAfN5TT59gAVsdXWuyBtd2LCuQtZAyDzGxIB3DbdLbnOOAwRqqlcpa+epe18Fq9Zj/+mnnuQ96o6Nj3Xpj90oJfYqFkTndZsXZqEfbQ0V4BMOjxQa/+3btA+be/qbl/Ukp1RFL2d+QAbUMz65YbKR8d5EqT9KElHB59n6xAB+kGcHwC2rbVED2u/hz6f5f9Gaq9fWq49z5MmSceyXNaLWolrLs0GIo0oKFtNPatvpf7MdBYuw7vJoquliC2f1JV6My9G2pHdyqztC5kw4ztv8Fe9bCCpTxDQvikDNE1J1tTJ12PHmwuP4FWDCMcHbnB0nN1EI1oI76kMTXaVdo1SrARcHPkMxQOCg2HXtPbzaJDGpDteGBBtJ3ebkBEFAsp/ojz7Izuh/rW4cZNtgn+DctVLNqVn37wh51+3a/3Q0sPVmstjjsP0RYy0nLoW1T8CWCvRs36WMzUTdtXLV4AgWEZh4yDtehxlkPadogZW+wLyrh94w3N3VZNldZ8gXtGXHNM+ts2A/NWURrMfZf2P/eV/jVyBAr+qhqzYaQya4LEeRV+NQ1Gt/g=="
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
