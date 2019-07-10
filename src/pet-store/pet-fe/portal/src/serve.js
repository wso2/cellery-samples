/*
 * Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

/* eslint-env node */
/* eslint "no-process-env": "off" */

import createServer from "./server/app";

const webPortalPort = process.env.PORTAL_PORT || 3000;
const server = createServer(webPortalPort);

// Listening for os Signals to gracefully shutdown
const shutdownServer = () => {
    // eslint-disable-next-line no-console
    console.log("[INFO] Shutting down Pet Store Portal");
    server.close(() => {
        // eslint-disable-next-line no-console
        console.log("[INFO] Pet Store Portal shutdown complete");
        // eslint-disable-next-line no-process-exit
        process.exit(0);
    });
};
process.on("SIGTERM", shutdownServer);
process.on("SIGINT", shutdownServer);
