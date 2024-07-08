.SUFFIXES: .vrq .b64 .diag .vch

all:    vr_00-D0-E5-F2-00-02.b64 voucher_00-D0-E5-F2-00-02.b64

%.b64:  %.vch
	base64 -w 60 $< >$@

%.b64:  %.pkcs
	base64 -w 60 $< >$@

update:
	cp /ssw/projects/pandora/reach/spec/files/product/00-D0-E5-F2-00-02/voucher_00-D0-E5-F2-00-02.pkcs .
	cp /ssw/projects/pandora/reach/spec/files/product/00-D0-E5-F2-00-02/vr_00-D0-E5-F2-00-02.pkcs .
	cp /ssw/projects/pandora/reach/spec/files/product/00-D0-E5-F2-00-02/key.pem 00-D0-E5-F2-00-02.pem
	cp /ssw/projects/pandora/reach/spec/files/product/00-D0-E5-F2-00-02/device.crt 00-D0-E5-F2-00-02.crt
	cp /ssw/projects/pandora/reach/spec/files/product/00-D0-E5-F2-00-02/masa.crt masa-00-D0-E5-F2-00-02.crt
	cp /ssw/projects/pandora/reach/spec/files/product/00-D0-E5-F2-00-02/vendor.crt vendor-00-D0-E5-F2-00-02.crt
	cp /ssw/projects/pandora/highway/spec/files/cert/vendor_3072.key vendor-00-D0-E5-F2-00-02.pem
	cp /ssw/projects/pandora/highway/spec/files/cert/masa_prime256v1.key masa-00-D0-E5-F2-00-02.pem
	cp /ssw/projects/pandora/highway/spec/files/cert/masa_prime256v1.crt masa-00-D0-E5-F2-00-02.crt
	# if this fails, then the example needs to be renerated.
	diff /ssw/projects/pandora/highway/spec/files/cert/vendor_3072.crt vendor-00-D0-E5-F2-00-02.crt

