## Capstone project

[![mAbdelFattah99](https://circleci.com/gh/mAbdelFattah99/proj5-capstone.svg?style=svg)](https://app.circleci.com/pipelines/github/mAbdelFattah99/proj5-capstone)

## Project Overview

In this project, I will apply CI/CD skills acquired during the DevOps learning journey at Udacity.

To get things done in this project, it requires a few steps:
-   Linting codebase and Dockerfile
-   Build and test a Docker file to containerize the application.
-   build the image and push it to dockerhub.
-   Create a kubernetes deployment and test it locally with minikube.
-   Create our deployment file that is going to use the image that is in docker hub.
-   Create a service that makes the containers publicly accessible.
-   Create a cluster locally using minikube.
-   Deploy the service and the deployment to the cluster locally and test that the application works.
-   Project demonstrate implemnting docker image and kubernetes using Circleci pipeline.
-   In this project Circleci orbs has been used:
      - circleci/kubernetes@0.11.2
      - circleci/aws-eks@1.0.3
-  Create a Circleci pipeline to automate the processes:
      - linting.
      - building the docker image.
      - pushing the image to dockerhub.
      - deploying the containers to the kubernetes cluster.

-  Upload a complete Github repo with CircleCI to indicate that the code has been tested.  
---


### Required Files walkthrough

+ `requirements.txt`: all dependencies to be installed.
+ `app.py`: The *python* API starter source code.
+ `Makefile`: the defination of the helper commands.
+ `Dockerfile`: defination of the container content.
+ `deployment.yml`: deployment file that is going to use the image that is in docker hub, also contains a service that makes the containers publicly accessible.
+ `config.yml`: circleci configuration file that is going to automate everything in this project.


---

# Running service locally instructions

* Create a virtualenv and activate it: `python3 -m venv .devops-proj4 && source ~/.devops-proj4/bin/activate`
* Run `make install` to install the dependencies defined in requirements.txt file
* optional test app.py: `python app.py`
* run lint: `make lint`

* build and upload docker by completing the two files `./run_docker.sh` and `./upload_docker.sh`, then

    1. Setup requirements for docker such as Login credentials.
    2. Run app.py in Docker:  `./run_docker.sh`
    3. Upload it: `./upload_docker.sh` 

* Kubernetes instructions and steps as following:

    1. Setup requirements for kubernetes such as installing minikube and hypervisor.
    2. First start your *minikube* cluster: (`minikube start`) 
    3. run script `run_kubernetes.sh` 
    4. apply the `deployment.yml` locally that is going to make the containers publicly accessible


---

# Running service with circleci automation processes

### Setup the Environment and test the application.

   ```
    steps:
      - checkout
      - restore_cache:
          keys:
            - v1-dependencies-{{ checksum "requirements.txt" }}
            - v1-dependencies-
      - run:
          name: install dependencies
          command: |
            python3 -m venv venv
            . venv/bin/activate
            make install
            # Install hadolint
            sudo wget -O /bin/hadolint https://github.com/hadolint/hadolint/releases/download/v1.16.3/hadolint-Linux-x86_64 &&\
            sudo chmod +x /bin/hadolint
      - save_cache:
          paths:
            - ./venv
          key: v1-dependencies-{{ checksum "requirements.txt" }}
      - run:
          name: run lint
          command: |
            . venv/bin/activate
            make lint 
   ```

### Creating the infrastructure using orbs circleci/aws-eks@1.0.3

  ```
  aws-eks/create-cluster:
        cluster-name: gsvcapstone
  ```

### Creating the deployment steps with aws-eks/python3 executor

  ```
    parameters:
      cluster-name:
        description: |
          proj5-capstone1
        type: string
    steps:
      - checkout
      - kubernetes/install
      - aws-eks/update-kubeconfig-with-authenticator:
          cluster-name: << parameters.cluster-name >>
          install-kubectl: true
      - kubernetes/create-or-update-resource:
          get-rollout-status: true
          resource-file-path: deployment.yml
          resource-name: deployment/proj5-capstone1
  ```
  
### Update the container image using `aws-eks/update-container-image`

  ```
  aws-eks/update-container-image:
    cluster-name: gsvcapstone
    container-image-updates: gsvcapstone=proj4mlmicroservice/proj5-capstone
    post-steps:
        - kubernetes/delete-resource:
            resource-names: proj5-capstone
            resource-types: deployment
            wait: true
    record: true
    requires:
        - create-deployment
    resource-name: deployment/proj5-capstone
  ```

### Testing the cluster steps

  ```
    parameters:
      cluster-name:
        description: |
          proj5-capstone1
        type: string
    steps:
      - kubernetes/install
      - aws-eks/update-kubeconfig-with-authenticator:
          cluster-name: << parameters.cluster-name >>
      - run:
          name: Test cluster
          command: |
            kubectl get svc
            kubectl get nodes
            kubectl get deployment
  ```
  
 ### References
 - https://circleci.com/developer/orbs/orb/circleci/kubernetes
 - https://circleci.com/developer/orbs/orb/circleci/aws-eks

