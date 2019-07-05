# Sample cell integration test for PetStore Backend


1. Download and extract apache-maven-3* to resources directory
2. Download and extract java1.8* to resources directory
3. Build the docker image

`docker build -t wso2cellery/pet-be-tests:0.3.0 --build-arg MODULE=io.cellery.test.petstore.be .`

4. Push docker image to dockerhub

`docker push wso2cellery/pet-be-tests:latest`
