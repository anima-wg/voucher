YANGDATE=2023-01-10
CWTSIDDATE1=ietf-voucher@${YANGDATE}.sid
CWTSIDLIST1=ietf-voucher-sid.txt
CWTSIDDATE2=ietf-voucher-request@${YANGDATE}.sid
CWTSIDLIST2=ietf-voucher-request-sid.txt
LIBDIR := lib

# add this because your local install might be newer.
YANGMODULESPATH=${HOME}/.local/share/yang/modules
PYANG?=pyang
PYANGPATH=--path=yang --path=${YANGMODULESPATH}
include $(LIBDIR)/main.mk

$(LIBDIR)/main.mk:
ifneq (,$(shell grep "path *= *$(LIBDIR)" .gitmodules 2>/dev/null))
	git submodule sync
	git submodule update $(CLONE_ARGS) --init
else
	git clone -q --depth 10 $(CLONE_ARGS) \
	    -b main https://github.com/martinthomson/i-d-template $(LIBDIR)
endif



draft-ietf-anima-rfc8366bis.xml:: yang/ietf-voucher@${YANGDATE}.yang yang/ietf-voucher-tree-latest.txt yang/iana-voucher-assertion-type@${YANGDATE}.yang

yang/ietf-voucher@${YANGDATE}.yang: ietf-voucher.yang yang/iana-voucher-assertion-type@${YANGDATE}.yang
	mkdir -p yang
	sed -e 's/YYYY-MM-DD/'${YANGDATE}'/g' ietf-voucher.yang | (cd yang && pyang ${PYANGPATH} --keep-comments -f yang >ietf-voucher@${YANGDATE}.yang )
	ln -s -f ietf-voucher@${YANGDATE}.yang yang/ietf-voucher-latest.yang

yang/ietf-voucher-request@${YANGDATE}.yang: ietf-voucher-request.yang yang/iana-voucher-assertion-type@${YANGDATE}.yang
	mkdir -p yang
	sed -e 's/YYYY-MM-DD/'${YANGDATE}'/g' ietf-voucher-request.yang | (cd yang && pyang {PYANGPATH} --keep-comments -f yang >ietf-voucher-request@${YANGDATE}.yang )
	ln -s -f ietf-voucher-request@${YANGDATE}.yang yang/ietf-voucher-request-latest.yang

yang/iana-voucher-assertion-type@${YANGDATE}.yang: ref-iana-voucher-assertion-type.yang
	mkdir -p yang
	sed -e 's/YYYY-MM-DD/'${YANGDATE}'/g' ref-iana-voucher-assertion-type.yang | (cd yang && pyang ${PYANGPATH} --keep-comments -f yang >iana-voucher-assertion-type@${YANGDATE}.yang )
	ln -s -f iana-voucher-assertion-type@${YANGDATE}.yang yang/iana-voucher-assertion-type-latest.yang

yang/ietf-voucher-tree-latest.txt: yang/ietf-voucher@${YANGDATE}.yang
	mkdir -p yang
	pyang ${PYANGPATH} -f tree --tree-print-groupings --tree-line-length=70  yang/ietf-voucher@${YANGDATE}.yang > yang/ietf-voucher-tree-latest.txt

yang/ietf-voucher-request-tree-latest.txt: yang/ietf-voucher-request@${YANGDATE}.yang
	${PYANG} ${PYANGPATH} -f tree --tree-print-groupings --tree-line-length=70 yang/ietf-voucher-@${YANGDATE} > ietf-voucher-request-constrained-tree.txt

# Base SID value for voucher: 2450
boot-sid1: yang/ietf-voucher@${YANGDATE}.yang
	${PYANG} ${PYANGPATH} --sid-list --generate-sid-file 2450:50 yang/ietf-voucher@${YANGDATE}.yang

${CWTSIDLIST1}: yang/${CWTDATE1}  yang/ietf-voucher@${YANGDATE}.yang
	mkdir -p yang
	${PYANG} ${PYANGPATH} --sid-list --sid-update-file=${CWTSIDDATE1} yang/ietf-voucher@${YANGDATE}.yang | ./truncate-sid-table >ietf-voucher-sid.txt

# Base SID value for voucher request: 2500
boot-sid2: yang/ietf-voucher-request@${YANGDATE}.yang
	${PYANG} ${PYANGPATH} --sid-list --generate-sid-file 2500:50 yang/ietf-voucher-request@${YANGDATE}.yang

${CWTSIDLIST2}: yang/${CWTDATE2}  yang/ietf-voucher-request@${YANGDATE}.yang
	mkdir -p yang
	${PYANG} ${PYANGPATH} --sid-list --sid-update-file=${CWTSIDDATE2} yang/ietf-voucher-request@${YANGDATE}.yang | ./truncate-sid-table >ietf-voucher-request-sid.txt


.PHONY: pyang-install
pyang-install:
	pip3 install pyang


