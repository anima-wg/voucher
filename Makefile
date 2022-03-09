LIBDIR := lib
YANGDATE=2021-07-04
YANGPATH=${HOME}/.local/share/yang/modules
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
	sed -e 's/YYYY-MM-DD/'${YANGDATE}'/g' ietf-voucher.yang | (cd yang && pyang -p ${YANGPATH} --keep-comments -f yang >ietf-voucher@${YANGDATE}.yang )
	ln -s -f ietf-voucher@${YANGDATE}.yang yang/ietf-voucher-latest.yang

yang/iana-voucher-assertion-type@${YANGDATE}.yang: iana-voucher-assertion-type.yang
	mkdir -p yang
	sed -e 's/YYYY-MM-DD/'${YANGDATE}'/g' iana-voucher-assertion-type.yang | (cd yang && pyang -p ${YANGPATH} --keep-comments -f yang >iana-voucher-assertion-type@${YANGDATE}.yang )
	ln -s -f iana-voucher-assertion-type@${YANGDATE}.yang yang/iana-voucher-assertion-type.yang
	ln -s -f iana-voucher-assertion-type@${YANGDATE}.yang yang/iana-voucher-assertion-type-latest.yang

yang/ietf-voucher-tree-latest.txt: yang/ietf-voucher@${YANGDATE}.yang
	mkdir -p yang
	pyang -p ${YANGPATH} -f tree --tree-print-groupings yang/ietf-voucher@${YANGDATE}.yang > yang/ietf-voucher-tree-latest.txt

.PHONY: pyang-install
pyang-install:
	pip3 install pyang


