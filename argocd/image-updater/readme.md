# How to Use Argo CD Image Updater with Private registry (Step-by-Step Guide)
- [How to Use Argo CD Image Updater with Private registry (Step-by-Step Guide)](#how-to-use-argo-cd-image-updater-with-private-registry-step-by-step-guide)
  - [Deploy Argo CD Image Updater](#deploy-argo-cd-image-updater)
  - [Test Argo CD Image Updater](#test-argo-cd-image-updater)
    - [Create a Python Flask Docker Image](#create-a-python-flask-docker-image)
    - [Create an Application on Argo CD](#create-an-application-on-argo-cd)
  - [Upload New Image to registry](#upload-new-image-to-registry)
  - [Image Update Strategies](#image-update-strategies)
    - [semver](#semver)
    - [newest-build](#newest-build)
    - [name](#name)
    - [digest](#digest)
    - [Image Updater Annotations](#image-updater-annotations)
    - [image-list](#image-list)
    - [update-strategy](#update-strategy)
    - [allow-tags](#allow-tags)
    - [ignore-tags](#ignore-tags)
    - [pull-secret](#pull-secret)
    - [write-back-method](#write-back-method)
    - [Conclusion](#conclusion)
  - [Reference](#reference)
  - [🔗 Stay connected with DockerMe! 🚀](#-stay-connected-with-dockerme-)

## Deploy Argo CD Image Updater
We will be using the official argocd-image-updater helm chart for the installation.

You can download and modify the official Helm values file using the following command.
```bash
helm show values argo/argocd-image-updater > values.yaml
```
Or you can use the custom values file inside the manifest folder as `values.yaml`.

I am using the custom values file.

Open the values file and update your registry account ID in it.
```yaml
config:
  name: argocd-image-updater-config
  registries:
    - name: MeCan Registry
      api_url: https://registry.mecan.ir
      ping: no
      prefix: registry.mecan.ir
      credentials: pullsecret:argo-cd/mecan-secret
      credsexpire: 6h
```

In this, registries and authScripts are default configuration is available in the Image Updater, which we can use to specify the image registry it has to monitor and the authentication script.

Also, it refreshes the authentication token every 6 hours.

The best method for installing Image Updater is to install it on the same namespace as Argo CD, so the Image Updater can make use of the Argo CD ServiceAccount for permissions.

By installing it in the same namespace, you can simply use the Image Updater by using annotations on the manifest file.

Before install `argocd-image-updater` create secret for registry `registry.mecan.ir`
```bash
kubectl create -n argo-cd secret docker-registry mecan-secret \
  --docker-username <<USERNAME>> \
  --docker-password <<PASSWORD>> \
  --docker-server "https://registry.mecan.ir"
```

To deploy the Argo CD Image Updater, run the following Helm install command with the custom values file from the root directory.
```bash
helm install argocd-image-updater argo/argocd-image-updater -n argocd -f image-updater.helm.values.yaml
```

Then, run the following command to check if the Image Updater is installed.
```bash
kubectl get po -n argocd
kubectl logs -f deployments/argocd-image-updater
```

You can also install Image Updater on another namespace, but for that, you need to create a new account with the API key and ServiceAccount, which will be used to connect Image Updater with Argo CD.

You can check the official document for Image updater installation on other namespaces.

## Test Argo CD Image Updater

### Create a Python Flask Docker Image
You can find a Python file for a Flask application and a Dockerfile to dockerize it inside the `app` folder.

```bash
# docker build -t <registry-url>:1.0.0 .
docker build -t registry.mecan.ir/devops_certification/argocd/flask-app:1.0.0 .

# Once the build is completed, run the following command to push it to registry.
docker push registry.mecan.ir/devops_certification/argocd/flask-app:1.0.0
```

### Create an Application on Argo CD
To create an application, you can find the manifest file inside the manifest folder as `application.yaml`.


The application resource will be created on the Argo CD namespace, and the Flask application will be deployed on the default namespace.
```yaml
  annotations:
    argocd-image-updater.argoproj.io/image-list: registry.mecan.ir/devops_certification/argocd/flask-app:~1.0
    argocd-image-updater.argoproj.io/write-back-method: argocd
    argocd-image-updater.argoproj.io/update-strategy: newest-build
```

The annotations enable the Argo CD Image Updater to monitor the specified registry and update new images.

**What the annotations for:**

`argocd-image-updater.argoproj.io/image-list` - for specifying the registry URL Image Updater needs to monitor.

At the end, the tag is given as `~1.0` , which means it will update the images that are tagged as 1.0.1, 1.0.2, 1.0.3,....

For example, if we specify the allowed version as `~1.0` in the annotation, the Image Updater will automatically update the image that is pushed with tags like 1.0.1, 1.0.2,...

Image Updater will not update the images with tags other than the version specified in the configuration, in our case it is `~1.0`, so it will not update the images with tags 2.0.0, 1.2.0, etc.

`argocd-image-updater.argoproj.io/write-back-method` - specify the write-back method need to use.

We are going to use the argocd write-back method, and there is also a git method.

We will look into write-back methods in detail later in this blog.

`argocd-image-updater.argoproj.io/update-strategy` - specify how new images need to be updated.

We are going to use the `newest-build` update strategy. Apart from this, there are three more strategies that we will see about later in this blog.

Now, run the following command from the root directory to deploy the application.
```bash
kubectl apply -f manifest/application.yaml
```

Then run the following commands to check if your application resource and Flask application are created.
```bash
kubectl get applications -n argocd
kubectl get po  
```

## Upload New Image to registry

Now, we are going to check what the Argo CD Image updater does when a new image is pushed to registry.

To update the new image, just do the Create a Python Flask Docker Image step again.

The only thing you need to change is the tag in the Docker build and push command, as below.
```bash
docker build -t registry.mecan.ir/devops_certification/argocd/flask-app:1.0.2 .

docker push registry.mecan.ir/devops_certification/argocd/flask-app:1.0.2
```
Also, change the message inside the Flask application file `/app/app.py` as shown below.
```python
from flask import Flask

app = Flask(__name__)

@app.route('/')
def version():
    return "This is image version 1.0.2"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```
You can see I have changed the message from This is image version `1.0.0` to This is image version `1.0.2`

Then, build the new image from the same directory where the Dockerfile is and push it to registry.

**New image will be updated within 1 minute**

## Image Update Strategies
Image Updater has multiple update strategies, which are used to update the image. The available update strategies are listed below:

### semver 

This strategy updates the tag which has the highest allowed version according to the configuration.

For example, let's say you have configured to allow version 1.0, and your repository has image tags as 1.0.2, 1.0.3, and 1.0.4.

While using this strategy, it updates the tag 1.0.4 because it is the highest allowed version available on the registry.

### newest-build

This strategy updates the latest created image tag.

For example, you have pushed the image in the order 1.0.1, 1.0.4, 1.0.3.

While using this strategy, it updates the tag 1.0.3 because it is the latest pushed tag.

### name

This strategy is used when a tag is in alphabetical letters and it updates the tag with the highest letter.

For example, you have tags as dev, stage, and prod.

While using this strategy, it updates the tag stage because it has the highest alphabetical letter 'S'.

### digest

This strategy updates the latest mutable image tag.

For example, you have already pushed an image with tag 1.0.4 and again you pushed the image with the same tag it becomes a mutable image.

Your repo has tags such as 1.0.1, 1.0.4, and 1.0.6, in this 1.0.4 is a mutable image.

While using this strategy, it updates the tag 1.0.4 because it is the latest pushed mutable image tag.

### Image Updater Annotations

You need to use annotations of Image Updater on your application's manifest file to monitor and update by Image Updater.

Make sure to use the prefix `argocd-image-updater.argoproj.io/` before every annotation.
Some of the commonly used annotations are given below:

### image-list
This is the mandatory annotation, here you have to specify your image repository with your preferred tag version.

For example, if my image repository is image/dev and the preferred tag version is 1.0, then my annotation will be:

`argocd-image-updater.argoproj.io/image-list: image/dev:~1.0`
You can also use an alias for this annotation as given below.

`argocd-image-updater.argoproj.io/image-list: nginx=image/dev:~1.0`

### update-strategy
This annotation is used to specify the update strategy we see in the above feature.

For example, if you are using the newest-build update-strategy your annotation will be:

`argocd-image-updater.argoproj.io/update-strategy: newest-build`

### allow-tags
This annotation is used when you want to update images with two or more tag versions.

For example, if you want to update images within the tag range 1.1 and 2.1, then your annotation will be:

`argocd-image-updater.argoproj.io/allow-tags: 1\.1\.[0-9]+|2\.1\.[0-9]+`

### ignore-tags
This annotation is used when you don't want to update a specific tag version.

For example, if the ignored image tag is 1.0, then Image Updater will not update the tag version that comes under the 1.0 version such as 1.0.1, 1.0.2, 1.0.3, ... these tag versions will be ignored.

### pull-secret
With this annotation, you can specify the credentials of your private image repository stored as a secret in Kubernetes.

For example, I have stored the credentials of my private image repository as a secret in Kubernetes named docker-cred then my annotation will be:

`argocd-image-updater.argoproj.io/pull-secret: docker-cred`

### write-back-method
Image Updater has two types of write-back methods argocd and git

**argocd**

This method directly modifies the application resource on Argo CD. Once it's updated, Argo CD rolls out the application pod with the new image tag.

The annotation used to specify this method is:

`argocd-image-updater.argoproj.io/write-back-method: argocd`

**git**
This method creates a file named .argocd-source-<app-name>.yaml in GitHub and writes the parameters that have changed in the file.

Then Argo CD notices the change in GitHub and updates the application pod.

The annotation used to specify this method is:

`argocd-image-updater.argoproj.io/write-back-method: git`

For detailed information on the write-back method, refer to the official documentation.

### Conclusion
You have installed Argo CD Image Updater, connected it to ECR, deployed a sample Flask app, and verified automatic tag updates and rollouts.

Also you learned common annotations and strategies to fine‑tune updates.

I hope this blog gives you an understanding of Argo CD Image Updater. For more information and edge cases, refer to the official documentation.

## [Reference](https://devopscube.com/setup-argocd-image-updater/)

## 🔗 Stay connected with DockerMe! 🚀

**Subscribe to our channels, leave a comment, and drop a like to support our content. Your engagement helps us create more valuable DevOps and cloud content!** 🙌

[![Site](https://img.shields.io/badge/Dockerme.ir-0A66C2?style=for-the-badge&logo=docker&logoColor=white)](https://dockerme.ir/) [![linkedin](https://img.shields.io/badge/linkedin-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/ahmad-rafiee/) [![Telegram](https://img.shields.io/badge/telegram-0A66C2?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/dockerme) [![YouTube](https://img.shields.io/badge/youtube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://youtube.com/@dockerme) [![Instagram](https://img.shields.io/badge/instagram-FF0000?style=for-the-badge&logo=instagram&logoColor=white)](https://instagram.com/dockerme)
