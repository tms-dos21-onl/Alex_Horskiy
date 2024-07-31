# Kubernetes (ч. 3)

Что интересного показать:
- Service
    - (Declarative) `kubectl apply -f 1-service.yaml`
- [DNS for Services and Pods](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/)
- Readiness Probe
    - (Declarative) `kubectl apply -f 2-readinessprobe.yaml`
- [Service Types](https://medium.com/devops-mojo/kubernetes-service-types-overview-introduction-to-k8s-service-types-what-are-types-of-kubernetes-services-ea6db72c3f8c)
    - ClusterIP
        - [Port Forwarding](https://www.middlewareinventory.com/blog/kubectl-port-forward/)
    - [Headless](https://www.middlewareinventory.com/blog/kubernetes-headless-service/)
    - NodePort
    - LoadBalancer
- [Kubernetes CNI vs kube-proxy](https://stackoverflow.com/questions/53534553/kubernetes-cni-vs-kube-proxy)
- Storage
    - PersistentVolumeClaim
    - StorageClass
    - [GKE Sample](https://cloud.google.com/kubernetes-engine/docs/concepts/persistent-volumes)
        - (Declarative) `kubectl apply -f 3-volume.yaml`
- Environment Variables
    - (Declarative) `kubectl apply -f 4-envvar.yaml`
- ConfigMap
    - (Declarative) `kubectl apply -f 5-configmap.yaml`
- Secret
    - (Declarative) `kubectl apply -f 6-secret.yaml`
- Deployment & Rolling updates
    - (Imperative) `kubectl create deployment nicedeployment --image nginx`
    - (Declarative) `kubectl apply -f 7-deployment.yaml`
- [Sequential Breakdown of the Deployment process](https://blog.cloudnativefolks.org/introduction-to-kubernetes-deployments)
- StatefulSet
    - (Declarative) `kubectl apply -f 8-statefulset.yaml`
        - (Connect to any MongoDB instance) `mongosh mongo.default.svc.cluster.local`
- [Assigning Pods to Nodes: nodeSelector, nodeAffinity, podAffinity & podAntiAffinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/)
    - [Taints and Tolerations, Node Affinity, and Node Selector - Explained](https://medium.com/saas-infra/taints-and-tolerations-node-affinity-and-node-selector-explained-f329653c2bc6)
    - (Declarative) `kubectl apply -f 9-scheduling.yaml`
- Scaling
    - [HPA vs VPA](https://www.densify.com/kubernetes-autoscaling/kubernetes-hpa/)
        - (Declarative) `kubectl apply -f 10-scaling.yaml`
    - ClusterAutoscaler

## Дополнительные ресурсы:

- [Kubernetes Fundamentals](https://kubebyexample.com/learning-paths/kubernetes-fundamentals/what-kubernetes-3-minutes)
- [Kubernetes in Action](https://www.manning.com/books/kubernetes-in-action)
