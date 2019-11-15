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
package io.cellery.test.petstore.be;

import io.cellery.test.petstore.be.utils.HTTPClient;
import org.apache.http.HttpHeaders;
import org.apache.http.client.methods.HttpUriRequest;
import org.apache.http.client.methods.RequestBuilder;
import org.apache.http.entity.StringEntity;
import org.testng.Assert;
import org.testng.annotations.Test;

import java.util.regex.Pattern;

public class PetBeTest {

    private static String PET_BE_GATEWAY_ENDPOINT = System.getenv("PET_BE_CELL_URL");

    @Test(description = "Test inserting and retrieving orders")
    public void testOrder() throws Exception {
        String ordersEndpoint = PET_BE_GATEWAY_ENDPOINT + "/orders";
        String payload = "{\"order\":[{\"id\":1,\"amount\":1}]}";
        String expectedPostResponseRegex = "\\{\"status\":\"SUCCESS\",\"data\":\\{\"id\":[0-9]*\\}\\}";
//        String expectedGetResponse = "{\"status\":\"SUCCESS\",\"data\":{\"orders\":[{\"order\":[{\"item\":{\"id\":1," +
//                "\"name\":\"Pet Travel Carrier Cage\",\"description\":\"Ideal for airline travel, the carry cage has " +
//                "a sturdy handle grip and tie down strapping points for safe and secure travel\"";

        StringEntity entity = new StringEntity(payload);
        HttpUriRequest request = RequestBuilder.post()
                .setUri(ordersEndpoint)
                .setHeader(HttpHeaders.CONTENT_TYPE, "application/json")
                .setEntity(entity)
                .build();
        String actualResponse = HTTPClient.doSend(request);
        assert actualResponse != null;
        System.out.println("Response: " + actualResponse);
        Assert.assertTrue(Pattern.matches(expectedPostResponseRegex, actualResponse));

//        request = RequestBuilder.get()
//                .setUri(ordersEndpoint)
//                .build();
//        String actualGetResponse = HTTPClient.doSend(request);
//        assert actualGetResponse != null;
//        System.out.println("Response: " + actualGetResponse);
//        Assert.assertTrue(actualGetResponse.startsWith(expectedGetResponse));
    }
}
