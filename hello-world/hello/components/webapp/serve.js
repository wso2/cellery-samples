/*
 * Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

const express = require("express");

const app = express();
const port = process.env.SERVICE_PORT || 3000;

const renderHelloWorldPage = (name) => "<!DOCTYPE html>" +
    "<html lang='en'>" +
    "<head>" +
    "<meta charset='utf-8'>" +
    "<title>Hello World</title>" +
    "</head>" +
    "<body>" +
    `<h1>Hello ${name}</h1>` +
    "</body>" +
    "</html";

app.use("/", function (req, res) {
    let helloName = process.env.HELLO_NAME || "Cellery";
    res.send(renderHelloWorldPage(helloName));
});

app.listen(port, () => console.log(`Hello World Web App is running on port ${port}!`));
