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
package io.cellery.test.petstore.be.utils;

import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpUriRequest;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;
import org.testng.Assert;

import java.io.IOException;
import java.nio.charset.Charset;

/**
 * HTTPClient util class to execute http requests.
 */
public class HTTPClient {

    /**
     * Executes a provided http request.
     *
     * @param request GET/POST request
     * @return response
     */
    public static String doSend(HttpUriRequest request) {
        int statusCode = 0;
        CloseableHttpResponse response;
        try (CloseableHttpClient httpclient = HttpClients.createDefault()
        ) {
            System.out.println("Request executed: " + request.toString());
            response = httpclient.execute(request);
            statusCode = response.getStatusLine().getStatusCode();
            System.out.println("Response received: " + response.toString());
            Assert.assertEquals(statusCode, 200);
            return EntityUtils.toString(response.getEntity(), Charset.defaultCharset());
        } catch (IOException e) {
            e.printStackTrace();
        }
        return null;
    }

}
