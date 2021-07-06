---
docname: draft-richardson-anima-rfc8366bis-latest
stand_alone: true
ipr: trust200902
cat: std
consensus: 'yes'
pi:
  toc: 'yes'
  symrefs: 'yes'
  sortrefs: 'yes'
  compact: 'yes'
  subcompact: 'no'
  linkmailto: 'no'
  editing: 'no'
  comments: 'yes'
  inline: 'yes'
  rfcedstyle: 'yes'
title: A Voucher Artifact for Bootstrapping Protocols
abbrev: Voucher Profile
area: Operations
wg: ANIMA Working Group
kw: voucher
date: 2021-07
author:
- ins: K. Watsen
  name: Kent Watsen
  org: Juniper Networks
  email: kwatsen@juniper.net
- ins: M. Richardson
  name: Michael C. Richardson
  org: Sandelman Software
  email: mcr+ietf@sandelman.ca
  uri: http://www.sandelman.ca/
- ins: M. Pritikin
  name: Max Pritikin
  org: Cisco Systems
  email: pritikin@cisco.com
- ins: T. Eckert
  name: Toerless Eckert
  org: Futurewei Technologies Inc.
  abbrev: Huawei
  street: 2330 Central Expy
  city: Santa Clara
  code: '95050'
  country: United States of America
  email: tte+ietf@cs.fau.de
normative:
  RFC5652:
  RFC6020:
  RFC8259:
  RFC7950:
  ITU-T.X690.2015:
    target: https://www.itu.int/rec/T-REC-X.690/
    title: 'Information Technology - ASN.1 encoding rules: Specification of Basic
      Encoding Rules (BER), Canonical Encoding Rules (CER) and Distinguished Encoding
      Rules (DER)'
    author:
    - org: International Telecommunication Union
    date: 2015-08
    seriesinfo:
      ITU-T Recommendation X.690,: ISO/IEC 8825-1
informative:
  RFC5246:
  RFC3688:
  RFC6838:
  RFC6241:
  RFC8040:
  RFC8340:
  RFC6125:
  RFC7435:
  ZERO-TOUCH: RFC8572
  BRSKI: RFC8995
  SECUREJOIN: I-D.ietf-6tisch-dtsecurity-secure-join
  YANG-GUIDE: RFC8407
  Stajano99theresurrecting:
    target: https://www.cl.cam.ac.uk/research/dtg/www/files/publications/public/files/tr.1999.2.pdf
    title: 'The Resurrecting Duckling: Security Issues for Ad-Hoc Wireless Networks'
    author:
    - ins: F. Stajano
      name: Frank Stajano
      org: ''
    - ins: R. Anderson
      name: Ross Anderson
      org: ''
    date: 1999
  imprinting:
    target: https://en.wikipedia.org/w/index.php?title=Imprinting_(psychology)&oldid=825757556
    title: 'Wikipedia article: Imprinting'
    author:
    - surname: Wikipedia
      org: ''
    date: 2018-02

--- abstract


This document defines a strategy to securely assign a pledge to an owner
using an artifact signed, directly or indirectly, by the pledge's manufacturer.
This artifact is known as a "voucher".

This document defines an artifact format as a YANG-defined JSON document
that has been signed using a Cryptographic Message Syntax (CMS) structure.
Other YANG-derived formats are possible.
The voucher artifact is normally generated by
the pledge's manufacturer (i.e., the Manufacturer Authorized Signing
Authority (MASA)).

This document only defines the voucher artifact, leaving it to other
documents to describe specialized protocols for accessing it.

--- middle

# Introduction {#introduction}

This document defines a strategy to securely assign a candidate device
(pledge) to an owner using an artifact signed, directly or indirectly,
by the pledge's manufacturer, i.e., the Manufacturer Authorized
Signing Authority (MASA).  This artifact is known as the "voucher".

The voucher artifact is a JSON {{RFC8259}} document that
conforms with a data model described by YANG {{RFC7950}}, is
encoded using the rules defined in {{RFC8259}}, and
is signed using (by default) a CMS structure {{RFC5652}}.

The primary purpose of a voucher is to securely convey a
certificate, the "pinned-domain-cert", that a pledge can
use to authenticate subsequent interactions. A voucher may be useful
in several contexts, but the driving motivation
herein is to support secure bootstrapping mechanisms.  Assigning
ownership is important to bootstrapping mechanisms so that the pledge
can authenticate the network that is trying to take control of it.

The lifetimes of vouchers may vary. In some bootstrapping protocols,
the vouchers may include a nonce restricting them to a single use,
whereas the vouchers in other bootstrapping protocols may have an
indicated lifetime. In order to support long lifetimes, this document
recommends using short lifetimes with programmatic renewal, see
{{renewal-over-revocation}}.

This document only defines the voucher artifact, leaving it to other
documents to describe specialized protocols for accessing it.
Some bootstrapping protocols using the voucher artifact defined in
this document include: {{ZERO-TOUCH}}, {{SECUREJOIN}}, and
{{BRSKI}}).

# Terminology

This document uses the following terms:

Artifact:
: Used throughout to represent the voucher as instantiated in the form
  of a signed structure.

Domain:
: The set of entities or infrastructure under common administrative
  control.
  The goal of the bootstrapping protocol is to enable a pledge to
  discover and join a domain.

Imprint:
: The process where a device obtains the cryptographic key material to
  identify and trust future interactions with a network. This term is
  taken from Konrad Lorenz's work in biology with new ducklings:
  "during a critical period, the duckling would assume that anything
  that looks like a mother duck is in fact their mother"
  {{Stajano99theresurrecting}}. An equivalent for a device is to
  obtain the fingerprint of the network's root certification authority
  certificate. A device that imprints on an attacker suffers a similar
  fate to a duckling that imprints on a hungry wolf. Imprinting is a
  term from psychology and ethology, as described in {{imprinting}}.

Join Registrar (and Coordinator):
: A representative of the domain that is configured, perhaps
  autonomically, to decide whether a new device is allowed to join the
  domain. The administrator of the domain interfaces with a join
  registrar (and Coordinator) to control this process.
  Typically, a join registrar is "inside" its domain. For simplicity,
  this document often refers to this as just "registrar".

MASA (Manufacturer Authorized Signing Authority):
: The entity that, for the purpose of this document, signs the
  vouchers for a manufacturer's pledges.
  In some bootstrapping protocols, the MASA may have an Internet
  presence and be integral to the bootstrapping process, whereas in
  other protocols the MASA may be an offline service that has no
  active role in the bootstrapping process.

Owner:
: The entity that controls the private key of the "pinned-domain-cert"
  certificate conveyed by the voucher.

Pledge:
: The prospective device attempting to find and securely join a
  domain.
  When shipped, it only trusts authorized representatives of the
  manufacturer.

Registrar:
: See join registrar.

TOFU (Trust on First Use):
: Where a pledge device makes no security decisions but rather simply
  trusts the first domain entity it is contacted by.
  Used similarly to {{RFC7435}}.
  This is also known as the "resurrecting duckling" model.

Voucher:
: A signed statement from the MASA service that indicates to a pledge
  the cryptographic identity of the domain it should trust.

# Requirements Language

{::boilerplate bcp14-tagged}


# Survey of Voucher Types

A voucher is a cryptographically protected statement to the pledge
device authorizing a zero-touch "imprint" on the join registrar of the
domain. The specific information a voucher provides is influenced by the
bootstrapping use case.

The voucher can impart the following information to
the join registrar and pledge:

Assertion Basis:
: Indicates the method that protects
  the imprint (this is distinct from the voucher signature that
  protects the voucher itself). This might include
  manufacturer-asserted ownership verification, assured
  logging operations, or reliance on pledge endpoint behavior
  such as secure root of trust
  of measurement. The join registrar might use this information.
  Only some methods are normatively defined in this
  document. Other methods are left for future work.

Authentication of Join Registrar:
: Indicates how the pledge
  can authenticate the join registrar.  This document defines
  a mechanism to pin the domain certificate.
  Pinning a symmetric key, a raw key, or "CN-ID" or "DNS-ID"
  information (as defined in {{RFC6125}}) is left for future work.

Anti-Replay Protections:
: Time- or nonce-based
  information to constrain the voucher to time periods or bootstrap
  attempts.


A number of bootstrapping scenarios can be met using differing
combinations of this information. All scenarios address the primary
threat of a Man-in-The-Middle (MiTM) registrar gaining control over
the pledge device. The following combinations are "types" of vouchers:

~~~~
             |Assertion   |Registrar ID    | Validity    |
Voucher      |Log-|Veri-  |Trust  |CN-ID or| RTC | Nonce |
Type         | ged|  fied |Anchor |DNS-ID  |     |       |
---------------------------------------------------------|
Audit        |  X |       | X     |        |     | X     |
-------------|----|-------|-------|--------|-----|-------|
Nonceless    |  X |       | X     |        | X   |       |
Audit        |    |       |       |        |     |       |
-------------|----|-------|-------|--------|-----|-------|
Owner Audit  |  X |   X   | X     |        | X   | X     |
-------------|----|-------|-------|--------|-----|-------|
Owner ID     |    |   X   | X     |  X     | X   |       |
-------------|----|-------|----------------|-----|-------|
Bearer       |  X |       |   wildcard     | optional    |
out-of-scope |    |       |                |             |
-------------|----|-------|----------------|-------------|

NOTE: All voucher types include a 'pledge ID serial-number'
      (not shown here for space reasons).
~~~~

Audit Voucher:
: An Audit Voucher is named after the logging assertion mechanisms
  that the registrar then "audits" to enforce local policy. The
  registrar mitigates a MiTM registrar by auditing that an unknown
  MiTM registrar does not appear in the log entries. This does not
  directly prevent the MiTM but provides a response mechanism that
  ensures the MiTM is unsuccessful. The advantage is that actual
  ownership knowledge is not required on the MASA service.

Nonceless Audit Voucher:
: An Audit Voucher without a validity period statement. Fundamentally,
  it is the same as an Audit Voucher except that it can be issued in
  advance to support network partitions or to provide a permanent
  voucher for remote deployments.

Ownership Audit Voucher:
: An Audit Voucher where the MASA service has verified the registrar
  as the authorized owner.
  The MASA service mitigates a MiTM registrar by refusing to generate
  Audit Vouchers for unauthorized registrars. The registrar uses audit
  techniques to supplement the MASA. This provides an ideal sharing of
  policy decisions and enforcement between the vendor and the owner.

Ownership ID Voucher:
: Named after inclusion of the pledge's CN-ID or DNS-ID within the
  voucher. The MASA service mitigates a MiTM registrar by identifying
  the specific registrar (via WebPKI) authorized to own the pledge.

Bearer Voucher:
: A Bearer Voucher is named after the inclusion of a registrar ID
  wildcard. Because the registrar identity is not indicated, this
  voucher type must be treated as a secret and protected from exposure
  as any 'bearer' of the voucher can claim the pledge
  device. Publishing a nonceless bearer voucher effectively turns the
  specified pledge into a "TOFU" device with minimal mitigation
  against MiTM registrars. Bearer vouchers are out of scope.

# Voucher Artifact {#voucher}

The voucher's primary purpose is to securely assign a pledge to an
owner.
The voucher informs the pledge which entity it should consider to be
its owner.

This document defines a voucher that is a JSON-encoded instance of the
YANG module defined in {{voucher-yang-module}} that has been, by
default, CMS signed.

This format is described here as a practical basis for some uses (such
as in NETCONF), but more to clearly indicate what vouchers look like
in practice.
This description also serves to validate the YANG data model.

Future work is expected to define new mappings of the voucher to
Concise Binary Object Representation (CBOR) (from JSON) and to change
the signature container from CMS to JSON Object Signing and Encryption
(JOSE) or CBOR Object Signing and Encryption (COSE).
XML or ASN.1 formats are also conceivable.

This document defines a media type and a filename extension for the
CMS-encoded JSON type.  Future documents on additional formats
would define additional media types.  Signaling is in the form of a MIME
Content-Type, an HTTP Accept: header, or more mundane methods like
use of a filename extension when a voucher is transferred on a USB
key.

## Tree Diagram {#voucher-tree-diagram}

The following tree diagram illustrates a high-level view of a voucher
document.
The notation used in this diagram is described in {{RFC8340}}.
Each node in the diagram is fully described by the YANG module in
{{voucher-yang-module}}.
Please review the YANG module for a detailed description of the
voucher format.

~~~~
{::include yang/ietf-voucher-tree-latest.txt}
~~~~


## Examples {#voucher-examples}

This section provides voucher examples for illustration
purposes.  These examples conform to the encoding rules
defined in {{RFC8259}}.

The following example illustrates an ephemeral voucher (uses a nonce).
The MASA generated this voucher using the 'logged' assertion type, knowing
that it would be suitable for the pledge making the request.


~~~~
{
  "ietf-voucher:voucher": {
    "created-on": "2016-10-07T19:31:42Z",
    "assertion": "logged",
    "serial-number": "JADA123456789",
    "idevid-issuer": "base64encodedvalue==",
    "pinned-domain-cert": "base64encodedvalue==",
    "nonce": "base64encodedvalue=="
  }
}
~~~~

The following example illustrates a non-ephemeral voucher (no nonce).
While the voucher itself expires after two weeks, it presumably can
be renewed for up to a year.   The MASA generated this voucher
using the 'verified' assertion type, which should satisfy all pledges.


~~~~
{
  "ietf-voucher:voucher": {
    "created-on": "2016-10-07T19:31:42Z",
    "expires-on": "2016-10-21T19:31:42Z",
    "assertion": "verified",
    "serial-number": "JADA123456789",
    "idevid-issuer": "base64encodedvalue==",
    "pinned-domain-cert": "base64encodedvalue==",
    "domain-cert-revocation-checks": "true",
    "last-renewal-date": "2017-10-07T19:31:42Z"
  }
}
~~~~


## YANG Module {#voucher-yang-module}

Following is a YANG {{RFC7950}} module formally
describing the voucher's JSON document structure.


~~~~ yang
{::include yang/ietf-voucher-latest.yang}
~~~~
{: sourcecode-markers="true" sourcecode-name="ietf-voucher@2021-07-02.yang”}


## CMS Format Voucher Artifact {#cms-voucher}

The IETF evolution of PKCS#7 is CMS {{RFC5652}}.
A CMS-signed voucher, the default type, contains a ContentInfo
structure with the voucher content. An eContentType of 40
indicates that the content is a JSON-encoded voucher.

The signing structure is a CMS SignedData structure, as specified by
Section 5.1 of {{RFC5652}}, encoded using ASN.1 Distinguished Encoding
Rules (DER), as specified in ITU-T X.690 {{ITU-T.X690.2015}}.

To facilitate interoperability, {{vcj}} in this document registers the
media type "application/voucher-cms+json" and the filename extension
".vcj".

The CMS structure MUST contain a 'signerInfo' structure, as
described in Section 5.1 of {{RFC5652}}, containing the
signature generated over the content using a private key
trusted by the recipient. Normally, the recipient is the pledge and the
signer is the MASA. Another possible use could be as a "signed
voucher request" format originating from the pledge or registrar
toward the MASA.
Within this document, the signer is assumed to be the MASA.

Note that Section 5.1 of {{RFC5652}} includes a
discussion about how to validate a CMS object, which is really a
PKCS7 object (cmsVersion=1).  Intermediate systems (such the
Bootstrapping Remote Secure Key Infrastructures {{BRSKI}} registrar)
that might need to evaluate the voucher in flight MUST be prepared for
such an older format.
No signaling is necessary, as the manufacturer knows the capabilities
of the pledge and will use an appropriate format voucher for each
pledge.

The CMS structure SHOULD also contain all of the certificates
leading up to and including the signer's trust anchor certificate
known to the recipient.  The inclusion of the trust anchor is
unusual in many applications, but third parties cannot accurately
audit the transaction without it.

The CMS structure MAY also contain revocation objects for any
intermediate certificate authorities (CAs) between the
voucher issuer and the trust anchor known to the recipient.
However, the use of CRLs and other validity mechanisms is
discouraged, as the pledge is unlikely to be able to perform
online checks and is unlikely to have a trusted clock source.
As described below, the use of short-lived vouchers and/or a
pledge-provided nonce provides a freshness guarantee.

# Design Considerations {#design-con}

## Renewals Instead of Revocations {#renewal-over-revocation}

The lifetimes of vouchers may vary.  In some bootstrapping protocols,
the vouchers may be created and consumed immediately, whereas in other
bootstrapping solutions, there may be a significant time delay between
when a voucher is created and when it is consumed.
In cases when there is a time delay, there is a need for the pledge
to ensure that the assertions made when the voucher was created are
still valid.

A revocation artifact is generally used to verify the continued validity
of an assertion such as a PKIX certificate, web token, or a "voucher".  With
this approach, a potentially long-lived assertion is paired with a reasonably
fresh revocation status check to ensure that the assertion is still valid.
However, this approach increases solution complexity, as it introduces the
need for additional protocols and code paths to distribute and process the
revocations.

Addressing the shortcomings of revocations, this document recommends
instead the use of lightweight renewals of short-lived non-revocable
vouchers.  That is, rather than issue a long-lived voucher, where the
'expires-on' leaf is set to some distant date, the expectation
is for the MASA to instead issue a short-lived voucher, where the
'expires-on' leaf is set to a relatively near date, along with a promise
(reflected in the 'last-renewal-date' field) to reissue the voucher again
when needed.  Importantly, while issuing the initial voucher may incur
heavyweight verification checks ("Are you who you say you are?" "Does the
pledge actually belong to you?"), reissuing the voucher should be a
lightweight process, as it ostensibly only updates the voucher's
validity period.
With this approach, there is
only the one artifact, and only one code path is needed to process
it; there is no possibility of a pledge choosing to skip the
revocation status check because, for instance, the OCSP Responder is
not reachable.

While this document recommends issuing short-lived vouchers, the
voucher artifact does not restrict the ability to create long-lived
voucher, if required; however, no revocation method is described.

Note that a voucher may be signed by a chain of intermediate CAs
leading up to the trust anchor certificate known by the pledge.  Even
though the voucher itself is not revocable, it may still be revoked,
per se, if one of the intermediate CA certificates is revoked.

## Voucher Per Pledge

The solution described herein originally enabled a single voucher to
apply to many pledges, using lists of regular expressions to represent
ranges of serial-numbers.  However, it was determined that blocking the
renewal of a voucher that applied to many devices would be excessive
when only the ownership for a single pledge needed to be blocked.
Thus, the voucher format now only supports a single serial-number
to be listed.


# Security Considerations {#sec-con}

## Clock Sensitivity

An attacker could use an expired voucher to gain control over
a device that has no understanding of time.  The device cannot
trust NTP as a time reference, as an attacker could control
the NTP stream.

There are three things to defend against this: 1) devices are
required to verify that the expires-on field has not yet passed,
2) devices without access to time can use nonces to
get ephemeral vouchers, and 3) vouchers without expiration times
may be used, which will appear in the audit log, informing the
security decision.

This document defines a voucher format that  contains time values
for expirations, which require an accurate clock
in order to be processed correctly.  Vendors planning on
issuing vouchers with expiration values must ensure that devices
have an accurate clock when shipped from manufacturing
facilities and take steps to prevent clock tampering.
If it is not possible to ensure clock accuracy, then
vouchers with expirations should not be issued.


## Protect Voucher PKI in HSM

Pursuant the recommendation made in Section 6.1 for the MASA to be
deployed as an online voucher signing service, it is RECOMMENDED that
the MASA's private key used for signing vouchers is protected by
a hardware security module (HSM).


## Test Domain Certificate Validity When Signing

If a domain certificate is compromised, then any outstanding
vouchers for that domain could be used by the attacker.  The domain
administrator is clearly expected to initiate revocation of any
domain identity certificates (as is normal in PKI solutions).

Similarly,they are expected to contact the MASA to indicate that
an outstanding (presumably short lifetime) voucher should be blocked from
automated renewal.
Protocols for voucher distribution are
RECOMMENDED to check for revocation of domain identity certificates
before the signing of vouchers.

## YANG Module Security Considerations

The YANG module specified in this document defines the schema
for data that is subsequently encapsulated by a CMS signed-data
content type, as described in Section 5 of {{RFC5652}}.  As such,
all of the YANG modeled data is protected from modification.

Implementations should be aware that the signed data is only
protected from external modification; the data is still visible.
This potential disclosure of information doesn't affect security
so much as privacy.  In particular, adversaries can glean
information such as which devices belong to which organizations
and which CRL Distribution Point and/or OCSP Responder URLs are
accessed to validate the vouchers.  When privacy is important,
the CMS signed-data content type SHOULD be encrypted, either by
conveying it via a mutually authenticated secure transport protocol
(e.g., TLS {{RFC5246}}) or by encapsulating the signed-data
content type with an enveloped-data content type (Section 6
of {{RFC5652}}), though details for how to do this are outside
the scope of this document.

The use of YANG to define data structures, via the 'yang-data'
statement, is relatively new and distinct from the traditional use of
YANG to define an API accessed by network management protocols such as
NETCONF {{RFC6241}} and RESTCONF {{RFC8040}}. For this reason, these
guidelines do not follow template described by Section 3.7 of
{{YANG-GUIDE}}.


# IANA Considerations {#iana-considerations}

## The IETF XML Registry

This document registers a URI in the "IETF XML
Registry" {{RFC3688}}.  IANA has registered the following:

~~~~
   URI: urn:ietf:params:xml:ns:yang:ietf-voucher
   Registrant Contact: The ANIMA WG of the IETF.
   XML: N/A, the requested URI is an XML namespace.
~~~~

## The YANG Module Names Registry

This document registers a YANG module in the "YANG Module Names"
registry {{RFC6020}}.  IANA has registered the following:



~~~~
   name:         ietf-voucher
   namespace:    urn:ietf:params:xml:ns:yang:ietf-voucher
   prefix:       vch
   reference:    RFC 8366
~~~~



## The Media Types Registry {#vcj}

This document registers a new media type in the "Media Types"
registry {{RFC6838}}. IANA has registered the following:

Type name:
: application

Subtype name:
: voucher-cms+json

Required parameters:
: none

Optional parameters:
: none

Encoding considerations:
: CMS-signed JSON vouchers are ASN.1/DER encoded.

Security considerations:
: See {{sec-con}}

Interoperability considerations:
: The format is designed to be broadly interoperable.

Published specification:
: RFC 8366

Applications that use this media type:
: ANIMA, 6tisch, and NETCONF zero-touch imprinting systems.

Fragment identifier considerations:
: none

Additional information:
: Deprecated alias names for this type:
  : none

  Magic number(s):
  : None

  File extension(s):
  : .vcj

  Macintosh file type code(s):
  : none

Person and email address to contact for further information:
: IETF ANIMA WG

Intended usage:
: LIMITED

Restrictions on usage:
: NONE

Author:
: ANIMA WG

Change controller:
: IETF

Provisional registration? (standards tree only):
: NO


## The SMI Security for S/MIME CMS Content Type Registry

IANA has registered the following OID in the "SMI Security for S/MIME
CMS Content Type (1.2.840.113549.1.9.16.1)" registry:

~~~~
            Decimal  Description                             References
            -------  --------------------------------------  ----------
            40       id-ct-animaJSONVoucher                  RFC 8366
~~~~




--- back

# Acknowledgements
{: numbered="no"}

The authors would like to thank for following for
lively discussions on list and in the halls (ordered
by last name): William Atwood, Toerless Eckert, and Sheng Jiang.

Russ Housley provided the upgrade from PKCS7 to CMS (RFC 5652) along
with the detailed CMS structure diagram.
