SUBROUTINE GB.MBL.I.CUS.TIN
*-----------------------------------------------------------------------------
* Subroutine Description:
* This routine is used for validate 12 digit TIN no
* Subroutine Type:
* Attached To    : Customer Version (CUSTOMER,MBL.INDV CUSTOMER,MBL.CORP)
* Attached As    : INPUT ROTINE
*-----------------------------------------------------------------------------
* Modification History :
* 01/10/2019 -                            Retrofit   - Sarowar Mortoza
*                                                     FDS Pvt Ltd
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $USING ST.Customer
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING EB.Foundation
    $USING EB.ErrorProcessing
*-----------------------------------------------------------------------------
    GOSUB INITIALISE ; *FILE INITIALISATION
    GOSUB OPENFILE ; *FILE OPEN
    GOSUB PROCESS ; *BUSINESS LOGIC PROCESS
RETURN
*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc>FILE INITIALISATION </desc>
    FN.CUSTOMER = "F.CUSTOMER"
    F.CUSTOMER = ''
    
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= OPENFILE>
OPENFILE:
*** <desc>FILE OPEN </desc>
    EB.DataAccess.Opf(FN.CUSTOMER, F.CUSTOMER)
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS >
PROCESS:
*** <desc>BUSINESS LOGIC PROCESS </desc>

    Y.TIN.NO=EB.SystemTables.getRNew(ST.Customer.Customer.EbCusTaxId)
    Y.TIN.NO.LEN=LEN(Y.TIN.NO)
    IF Y.TIN.NO NE '' AND Y.TIN.NO.LEN NE 12 THEN
        EB.SystemTables.setAf(ST.Customer.Customer.EbCusTaxId)
        EB.SystemTables.setEtext("Invalid TIN ID Length")
        EB.ErrorProcessing.StoreEndError()
        RETURN
    END
RETURN
*** </region>

END



