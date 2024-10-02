# 🌐k8s(Minikube)를 이용한 LoadBalancer 와 NodePort 이해 하기
![image](https://github.com/user-attachments/assets/fa7af23e-5e35-4fa8-af58-6af1ea2f555c)


![image](https://github.com/user-attachments/assets/29a6521a-7087-4298-aefd-727c4b560f1f)

## 🔍 프로젝트 목표
> Kubernetes 클러스터 환경에서 LoadBalancer와 NodePort 서비스 방식의 차이를 비교하고, 이를 통해 애플리케이션 배포 시의 네트워크 접근성을 최적화하는 방법을 이해하는 것입니다.

## 🛠️ 기술 스택
- 🐳 Docker: 애플리케이션 컨테이너화 및 이미지 생성
- ☸️ Kubernetes (K8s): 애플리케이션 관리 및 배포 자동화
- 🖥️ Minikube: 로컬 Kubernetes 클러스터 환경
- 🚀 NGINX 및 Spring Boot: 애플리케이션 서버

## 환경설정 
> jar 파일을 사용하여 image 빌드 후 사용하기 
### 🛠️jar 파일 build
![](https://velog.velcdn.com/images/yuwankang/post/559e6847-3e26-4614-bdd6-f2666b1dff0f/image.png)

### 🐳Dockerfile
```bash
# 베이스 이미지로 OpenJDK 17을 사용합니다.
FROM openjdk:17

# 작업 디렉토리를 /app으로 설정합니다.
WORKDIR /app

# 호스트의 SpringApp-0.0.1-SNAPSHOT.jar 파일을 현재 Docker 이미지의 /app 디렉토리로 복사합니다.
COPY SpringApp-0.0.1-SNAPSHOT.jar /app

# Docker 컨테이너가 시작될 때 실행할 명령어를 지정합니다.
CMD ["java", "-jar", "SpringApp-0.0.1-SNAPSHOT.jar"]
```

### 🏗️docker image 빌드 및 실행
```
docker build -t spring-app-image .
docker run -d --name spring-app-container spring-app-image
```
![](https://velog.velcdn.com/images/yuwankang/post/5c89e190-a9e6-4291-9955-0861ad58607b/image.png)

## ⚙️ Minkube 클러스터 시작
```
minikube start
```
#### 🔧 dashboard  활성화
>  클러스터에 기본적인 리소스 모니터링 활성화

```bash
minikube addons enable metrics-server
```
> dashboard 활성화

```bash
minikube dashboard
```

## 🐳Docker 이미지를 Minikube에서 로드
- Minikube의 Docker 환경 설정을 현재 셸 세션에 적용합니다.
- 이미지 빌드 (이미지 이름은 spring-app-image로 설정)
```bash
eval $(minikube docker-env)  
docker build -t spring-app-image .  
```
![](https://velog.velcdn.com/images/yuwankang/post/c56f78d7-951a-4b5e-9ca6-c86ff6ec3f7a/image.png)
### 🔍이미지 확인
> Minikube에 SSH로 접속

```
minikube ssh
```

> Docker 이미지 확인

```
docker images
```
![](https://velog.velcdn.com/images/yuwankang/post/31422b97-e612-40b4-acb7-d967a7715484/image.png)


- Docker 이미지를 Minikube에 로드
```
kubectl create deployment spring-app-image --image=spring-app-image --replicas=3
```
```
kubectl expose deployment spring-app-image --type=NodePort --port=80
```
![](https://velog.velcdn.com/images/yuwankang/post/574ba7e0-61b3-4c28-9b1a-a3bf1288a33e/image.png)

# 🚀LoadBalance 방식

>동일한 NGINX를 3개로 구성해서 생성 및 배포

```bash
kubectl create deployment spring-app-image --image=spring-app-image --replicas=3
```
> 서비스 확인

```
kubectl get services
```
![image](https://github.com/user-attachments/assets/405d15af-ace2-45b3-aefb-37f8cd22ff98)



> 🌍NGINX 클러스터 External IP 추가

```bash
ubectl expose deployment spring-app-image --type=LoadBalancer --port=80
```
> Minikube에서 외부 IP 제공받기 위한 터널링

```
minikube tunnel
```
![image](https://github.com/user-attachments/assets/c44e2174-a219-4af4-985b-6e9e8a857dba)

> 🌐EXTERNAL-IP를 확인하기

```
kubectl get services

curl <EXTERNAL-IP>
```
![](https://velog.velcdn.com/images/yuwankang/post/5433bdbe-9103-4bfd-9da1-efefafcb0857/image.png)
- 포트 포워딩
![image](https://github.com/user-attachments/assets/bd903518-feb2-49dd-bf0d-27c16055d7e8)


- DashBoard에서 확인
![](https://velog.velcdn.com/images/yuwankang/post/2234e080-6eb9-405b-91bf-8a9fdc3d62b6/image.png)

## 🔄클러스터 디플로이먼트와 서비스 삭제
```
kubectl delete service nginx
```
- NGINX 배포 삭제 : 파드, 레플리카, 디플로이먼트 동시 삭제
```
kubectl delete deployment nginx
```
- Minikube 클러스터 삭제
```
minikube delete
```

# ⚙️NodePort 방식 


### 🛠️Kubernetes 리소스 정의
> spring-app-deployment.yaml 
**yaml파일**을 활용하여 처리하였습니다.

```bash
apiVersion: apps/v1
kind: Deployment
metadata:
  name: spring-app
spec:
  replicas: 3  # 원하는 파드 수
  selector:
    matchLabels:
      app: spring-app
  template:
    metadata:
      labels:
        app: spring-app
    spec:
      containers:
        - name: spring-app
          image: spring-app-image:latest  # Minikube에서 사용할 이미지
          imagePullPolicy: IfNotPresent  # 추가된 부분
          ports:
            - containerPort: 8899  # 애플리케이션이 사용하는 포트
---
apiVersion: v1
kind: Service
metadata:
  name: spring-app-service
spec:
  selector:
    app: spring-app
  ports:
    - protocol: TCP
      port: 80  # 서비스의 노출 포트
      targetPort: 8899  # 컨테이너 포트
  type: NodePort  # LoadBalancer 대신 NodePort로 변경

```

> spring-app-deployment.yaml 파일을 사용하여 Kubernetes에 배포

```
kubectl apply -f spring-app-deployment.yaml
```



![](https://velog.velcdn.com/images/yuwankang/post/214e30f6-5136-473d-8b40-642ddd146b5f/image.png)


#### dashboard  활성화
>  클러스터에 기본적인 리소스 모니터링 활성화

```bash
minikube addons enable metrics-server
```
> dashboard 활성화

```bash
minikube dashboard
```
![](https://velog.velcdn.com/images/yuwankang/post/403eff2d-5d9b-4f64-bf03-c148d2e5b196/image.png)
![](https://velog.velcdn.com/images/yuwankang/post/d72d5a0c-cf69-4088-bd21-6d4a672a2b65/image.png)

# 결과 및 결론
![image](https://github.com/user-attachments/assets/272e3216-4891-4b31-855b-d1bdb92fa85a)
- LoadBalancer 방식: 외부 네트워크에서 접근이 가능하지만, Minikube에서는 터널링이 필요. 클러스터 외부에서 쉽게 접속 가능하다는 장점이 있음.
- NodePort 방식: 로컬 네트워크에서만 접근 가능하며, 터널링이 필요하지 않음. 로컬 클러스터 환경에서 더 간단하게 설정할 수 있다는 장점이 있음.

# 📈 향후 확장
> 향후에는 Ingress 및 Service Mesh를 추가하여 더 복잡한 네트워크 구조와 다양한 서비스 배포 방식에 대해 프로젝트 완성하겠습니다.
