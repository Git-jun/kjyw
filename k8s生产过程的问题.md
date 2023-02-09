# 1参考文章 https://kubesphere.io/zh/blogs/how-to-get-real-ip-in-pod/
* 本文介绍了三种获取真实 IP 的部署方式：
  * 直接通过 NortPort 访问获取真实 IP
  * 受制于 Local 模式，可能会导致服务不可访问。需要保证对外提供入口的节点上，必须具有服务的负载。

  * 通过 LB -> Service 访问获取真实 IP
  * 利用 LB 的探活能力，能够提高服务的可访问性。适用于服务较少，或者愿意每个服务一个 LB 的场景。

  * 通过 LB -> Ingress -> Service 访问获取真实 IP
  * 通过 LB 将 80、443 端口的流量转到 Ingress Controller ，再进行服务分发。但 Ingress Controller 使用 Local 模式，就要求 LB 的每个后端节点都有 Ingress Controller 副本。适用于对外暴露服务数量较多的场景。

** 当然也可以组合使用，对于并不需要获取客户端真实 IP 的服务，可以继续使用 Cluster 模式。**


# 2k8s ingress获取真实IP地址配置
* 处理方法
  * 修改容器的配置文件
* 配置文件：
ingress-nginx/ingress-nginx-controller
* 修改命令：
kubectl edit cm ingress-nginx-controller -n ingress-nginx 

添加内容:
```
compute-full-forwarded-for: "true"
forwarded-for-header: "X-Forwarded-For"
use-forwarded-headers: "true"
```
保存后立即生效。随后ingress的添加真实的IP行为会与RFC一样都依次添加到X-Forwarded-For中了



