# Koha Interlibrary Loans ILLSLNPKoha backend

## about SLNP
SLNP (TM) (Simple Library Network Protocol) is a TCP network socket based protocol 
designed and introduced by the company Sisis Informationssysteme GmbH (later a part of OCLC) 
for their library management system SISIS-SunRise (TM).
This protocol supports the bussiness processes of libraries.
A subset of SLNP that enables the communication required for regional an national ILL (Inter Library Loan) processes
has been published by Sisis Informationssysteme GmbH as basis for 
connection of library management systems to ILL servers that use SLNP.
Sisis Informationssysteme GmbH / OCLC owns all rights to SLNP.
SLNP is a registered trademark of Sisis Informationssysteme GmbH / OCLC.

## Synopsis
This ILL backend provides a simple method to handle Interlibrary Loan requests that are initiated by an regional ILL server using the SLNP protocol.
The additional service 'ILLZFLServerKoha' manages the communication with the regional ILL server and will insert records in tables illrequests and illrequestattributes 
by calling the 'create' method of ILLSLNPKoha. 
The remaining features of this ILL backend are accessible via the standard ILL framework in the Koha staff interface.

## Installing
* Create a directory in `Koha` called `Illbackends`, so you will end up with `Koha/Illbackends`
* Clone the repository into this directory, so you will end up with `Koha/Illbackends/ILLSLNPKoha`
* In the `ILLSLNPKoha` directory switch to the branch you wish to use (in the moment only 'master' (matching Koha-LMSCloud master) is supported)
* Activate ILL by enabling the `ILLModule` system preference and check the <interlibrary_loans> division in your koha-conf.xml
