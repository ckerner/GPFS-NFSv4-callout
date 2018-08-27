GPFSDIR=$(shell dirname $(shell which mmlscluster))
CURDIR=$(shell pwd)
LOCLDIR=/var/mmfs/etc

install: .FORCE
	cp -fp $(CURDIR)/gpfs-nfs4-bind-mounts.sh $(LOCLDIR)/gpfs-nfs4-bind-mounts.sh
	/usr/lpp/mmfs/bin/mmaddcallback NFSbind --command /var/mmfs/etc/gpfs-nfs4-bind-mounts.sh --event mount,preUnmount \
	   -N archive --sync --timeout 30 --onerror continue --parms "%eventName %fsName" --parms "%eventName %fsName"

update: .FORCE
	cp -fp $(CURDIR)/gpfs-nfs4-bind-mounts.sh $(LOCLDIR)/gpfs-nfs4-bind-mounts.sh

clean:
	rm -f $(LOCLDIR)/gpfs-nfs4-bind-mounts.sh

.FORCE:


