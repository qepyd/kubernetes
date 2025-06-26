kubectl -n default   create configmap  ubuntu1804-apt-source \
   --from-file=sources.list=./sources.list  \
   --dry-run=client \
   -o yaml >./01-2.cm_default-ubuntu1804-apt-source.yaml
