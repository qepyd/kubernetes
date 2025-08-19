==============================静态pv使用相关树内(in tree)卷插件对接存储系统==============================
静态pv使用相关卷类型(树内卷插件，不涉及csi这个树内卷插件)对接存储系统中的volume或image（需要事先准备好），再
创建相应的pvc资源对象匹配静态pv，最后Pod的Pod级别使用persistentVolumeClaim这个树内卷插件对接自身所在namespace
中的pvc资源对象，这样Pod就间接的对接到了存储系统中的volume或image。
