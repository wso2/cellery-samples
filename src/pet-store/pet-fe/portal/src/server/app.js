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
/* eslint no-process-env: "off" */
/* eslint no-console: "off" */

import App from "../components/App";
import {CssBaseline} from "@material-ui/core";
import {JssProvider} from "react-jss";
import React from "react";
import ReactDOMServer from "react-dom/server";
import {SheetsRegistry} from "jss";
import {StateProvider} from "../components/common/state";
import {StaticRouter} from "react-router-dom";
import {MuiThemeProvider, createGenerateClassName} from "@material-ui/core/styles";
import {generateTheme, renderFullPage} from "../utils";
import * as cookieParser from "cookie-parser";
import * as express from "express";
import * as morgan from "morgan";
import * as path from "path";
import * as petStoreApi from "../gen/petStoreApi";
import * as proxy from "express-http-proxy";
import * as rotatingFileStream from "rotating-file-stream";

const CELLERY_USER_HEADER = "x-cellery-auth-subject";
const PET_STORE_GUEST_HEADER = "x-pet-store-guest";
const PET_STORE_GUEST_COOKIE_NAME = "psgc";

const forwardedHeaders = [
    "Authorization",
    "x-request-id",
    "x-b3-traceid",
    "x-b3-spanid",
    "x-b3-parentspanid",
    "x-b3-sampled",
    "x-b3-flags",
    "x-ot-span-context"
];

/**
 * Get the username of the user who invoked the API.
 *
 * @param req The express request object received
 * @param isGuestModeEnabled True if guest mode is enabled
 * @return The username of the user who invoked the API
 */
const getUsername = (req, isGuestModeEnabled) => {
    let username = null;
    if (req) {
        if (isGuestModeEnabled) {
            username = req.cookies[PET_STORE_GUEST_COOKIE_NAME];
        } else {
            username = req.get(CELLERY_USER_HEADER);
        }
    }
    return username;
};

const renderApp = (req, res, initialState, basePath, isGuestModeEnabled) => {
    const sheetsRegistry = new SheetsRegistry();
    const sheetsManager = new Map();
    const context = {};
    const app = (
        <JssProvider registry={sheetsRegistry} generateClassName={createGenerateClassName()}>
            <MuiThemeProvider theme={generateTheme()} sheetsManager={sheetsManager}>
                <CssBaseline/>
                <StaticRouter context={context} location={req.url}>
                    <StateProvider catalog={initialState.catalog} user={initialState.user}
                        isGuestModeEnabled={isGuestModeEnabled}>
                        <App/>
                    </StateProvider>
                </StaticRouter>
            </MuiThemeProvider>
        </JssProvider>
    );
    const html = ReactDOMServer.renderToString(app);
    const css = sheetsRegistry.toString();
    res.send(renderFullPage(css, html, initialState, basePath, isGuestModeEnabled));
};

const createServer = (port, isGuestModeEnabled) => {
    const app = express();
    const petStoreCellUrl = process.env.PET_STORE_CELL_URL;

    app.use(express.json());
    app.use(cookieParser());

    app.use("/app", express.static(path.join(__dirname, "/app")));

    // Logger for access logs
    const accessLogStream = rotatingFileStream("access.log", {
        interval: "1d",
        path: path.join(__dirname, "log")
    });
    app.use(morgan("combined", {
        stream: accessLogStream
    }));

    // Logger for 4xx and 5xx responses
    morgan.token("log-level", (req, res) => {
        let logLevel = "INFO";
        if (res.statusCode >= 500) {
            logLevel = "ERROR";
        } else if (res.statusCode >= 400 && res.statusCode < 500) {
            logLevel = "WARN";
        }

        return logLevel;
    });
    app.use(morgan("[:log-level] :method :url :status :response-time ms - :res[content-length]", {
        skip: (req, res) => res.statusCode < 400
    }));

    // Proxy API requests to controller
    const parsedPetStoreCellUrl = new URL(petStoreCellUrl);
    const petStoreContext = parsedPetStoreCellUrl.pathname === "/" ? "" : parsedPetStoreCellUrl.pathname;
    app.use("/api", proxy(parsedPetStoreCellUrl.host, {
        proxyReqPathResolver: (req) => petStoreContext + req.url,
        filter: (req) => !/^\/guest.*/i.test(req.path),
        proxyReqOptDecorator: (proxyReqOpts, srcReq) => {
            if (isGuestModeEnabled) {
                const guestUser = srcReq.cookies[PET_STORE_GUEST_COOKIE_NAME];
                if (guestUser) {
                    proxyReqOpts.headers[PET_STORE_GUEST_HEADER] = guestUser;
                }
            }
            return proxyReqOpts;
        }
    }));

    /*
     * Serving the App
     */
    app.get(/^(?!(\/app|\/api)).*/i, (req, res) => {
        const initialState = {
            user: getUsername(req, isGuestModeEnabled)
        };
        const basePath = process.env.BASE_PATH;

        // Setting the Pet Store Cell URL for the Swagger Generated Client
        petStoreApi.setDomain(petStoreCellUrl);

        const petStoreApiHeaders = {};
        forwardedHeaders.forEach((header) => {
            const headerValue = req.get(header);
            if (headerValue) {
                petStoreApiHeaders[header] = headerValue;
            }
        });
        const petStoreApiParameters = {
            $config: {
                headers: petStoreApiHeaders
            }
        };

        petStoreApi.getCatalog(petStoreApiParameters)
            .then((response) => {
                const responseBody = response.data;
                initialState.catalog = {
                    accessories: responseBody.data.accessories
                };
                renderApp(req, res, initialState, basePath, isGuestModeEnabled);
            })
            .catch((e) => {
                console.log(`[ERROR] Failed to fetch the catalog due to ${e}`);
            });
    });

    if (isGuestModeEnabled) {
        app.post("/api/guest", (req, res) => {
            if (req.body && req.body.username) {
                res.cookie(PET_STORE_GUEST_COOKIE_NAME, req.body.username, {
                    httpOnly: true
                }).send(JSON.stringify({
                    status: "SUCCESS"
                }));
            } else {
                res.status(400).send(JSON.stringify({
                    status: "ERROR",
                    message: "User data not provided"
                }));
            }
        });

        app.delete("/api/guest", (req, res) => {
            res.clearCookie(PET_STORE_GUEST_COOKIE_NAME);
            res.send(JSON.stringify({
                status: "SUCCESS"
            }));
        });
    }

    /*
     * Binding to a port and listening for requests
     */
    const server = app.listen(port, () => {
        const host = server.address().address;
        const port = server.address().port;

        console.log("[INFO] Pet Store Portal listening at http://%s:%s", host, port);
    });

    return server;
};

export default createServer;
