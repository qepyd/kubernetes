# 1.Pod的生命周期
Pod中可以有多个容器(多个initContainers、多个containers)，initContainers是串行启动完成工作
后退出，而containers是串行启动且不会退出。 initContainers、containers都会有如下hook和probe。
```
post start hook  # 启动后做什么操作，非周期性。
startup probe    # 启动性探测，非周期性。
livenessProbe    # 存活性探测，周期性的。
readinessProbe   # 就绪性探测，周期性的。
pre stop hook    # 停止前做什么操作，非周期性。
```
此图只展示了pods.spec.containers中各容器的hook和probe
<image src="./picture/pod-lifecycle.jpg" style="width: 100%; height: auto;">
```
startupProbe
  探测失败
    影响Pod加入到svc的后端端点。
    会导致容器的重启。
    若：只有startupProbe,应该考滤到应用程序的启动时长
	即初始探测等待时长(initialDelaySeconds)久一点。
  非周期性
    不会再进行探测了

readinessProbe
  探测失败
    影响Pod加入到svc的后端端点。
    不会导致容器的重启。
    若：只有readinessProbe,应该考滤到应用程序的启动时长
	即初始探测等待时长(initialDelaySeconds)久一点。
  周期性
    探测失败
      影响Pod加入到svc的后端端点。
     不会导致容器的重启。

livenessProbe
  探测失败
    不影响Pod加入到svc的后端端点。
    会导致容器的重启。
    若：只有livenessProbe，应该考滤到应用程序的启动时长，
	即初始探测等待时长(initialDelaySeconds)久一点。
  周期性
    探测失败
      不影响Pod加入到svc的后端端点。
      会导致容器的重启。
```
