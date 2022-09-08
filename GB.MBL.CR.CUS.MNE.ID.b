SUBROUTINE GB.MBL.CR.CUS.MNE.ID
*-----------------------------------------------------------------------------
**Subroutine Description:
** This routine is used for generate Mnemonic id i.e C:CUSTOMER ID
*Subroutine Type:
*Attached To    : Customer Version (CUSTOMER,MBL.INDV,CUSTOMER,MBL.CORP)
*Attached As    : CHECK.REC.RTN
*-----------------------------------------------------------------------------
* Modification History :
* 01/10/2019 -                            Retrofit   - Sarowar Mortoza
*                                                     FDS Pvt Ltd
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $USING ST.Customer
    $USING EB.SystemTables
*-----------------------------------------------------------------------------
    GOSUB INITIALISE ; *FILE INITIALISATION
    GOSUB PROCESS ; *BUSINESS LOGIC PROCESS
RETURN
*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc>FILE INITIALISATION </desc>
    Y.CUS.ID=''
    Y.CUS.ID =EB.SystemTables.getIdNew()
    Y.PGM.VERSION=''
    Y.PGM.VERSION=EB.SystemTables.getPgmVersion()
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc>BUSINESS LOGIC PROCESS </desc>
    EB.SystemTables.setRNew(ST.Customer.Customer.EbCusMnemonic, "C":Y.CUS.ID)
    EB.SystemTables.setRNew(ST.Customer.Customer.EbCusLanguage,"1")
    BEGIN CASE
        CASE Y.PGM.VERSION EQ ',MBL.CORP'
            EB.SystemTables.setRNew(ST.Customer.Customer.EbCusCustomerType,"ACTIVE")
        CASE Y.PGM.VERSION EQ ',MBL.INDV'
            EB.SystemTables.setRNew(ST.Customer.Customer.EbCusCustomerType,"ACTIVE")
        CASE Y.PGM.VERSION EQ ',BD.INDV.PROSPECT'
            EB.SystemTables.setRNew(ST.Customer.Customer.EbCusCustomerType,"PROSPECT")
    END CASE

RETURN
*** </region>

END


