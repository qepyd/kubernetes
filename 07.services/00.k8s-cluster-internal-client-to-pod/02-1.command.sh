kubectl -n lili   create configmap   ubuntu1804-apt-source \
   --from-file=sources.list=./sources.list  \
   --dry-run=client \
   -o yaml >./02-2.cm_lili-ubuntu1804-apt-source.yaml
