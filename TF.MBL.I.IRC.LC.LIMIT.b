SUBROUTINE TF.MBL.I.IRC.LC.LIMIT
*-----------------------------------------------------------------------------
*Subroutine Description: IRC amount limit check
*Subroutine Type:
*Attached To    : CUSTOMER,MBL.CORP
*Attached As    : INPUT ROUTINE
*-----------------------------------------------------------------------------
* Modification History :
* 14/11/2019 -                            Retrofit   - MD. EBRAHIM KHALIL RIAN,
*                                                 FDS Bangladesh Limited
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING ST.Customer
    $USING EB.ErrorProcessing
    $USING EB.LocalReferences
*-----------------------------------------------------------------------------
    GOSUB INITIALISE ; *INITIALISATION
    GOSUB PROCESS ; *PROCESS BUSINESS LOGIC
*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc>INITIALISATION </desc>
    EB.LocalReferences.GetLocRef("CUSTOMER","LT.TF.AVL.LIMIT",Y.IRC.LC.AMOUNT.POS)
    EB.LocalReferences.GetLocRef("CUSTOMER","LT.IRC.EXP.DAT",Y.IRC.EXP.DT.POS)
RETURN
*** </region>

*** <region name= PROCESS>
PROCESS:
*** <desc>PROCESS BUSINESS LOGIC </desc>
    Y.IRC.EXP.DT.OLD = EB.SystemTables.getROld(ST.Customer.Customer.EbCusLocalRef)<1, Y.IRC.EXP.DT.POS>
    Y.IRC.EXP.DT.NEW = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusLocalRef)<1, Y.IRC.EXP.DT.POS>
    Y.IRC.LC.AMOUNT = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusLocalRef)<1, Y.IRC.LC.AMOUNT.POS>
    
    IF Y.IRC.EXP.DT.NEW GT Y.IRC.EXP.DT.OLD THEN
        IF Y.IRC.LC.AMOUNT NE "0" THEN
            EB.SystemTables.setAf(ST.Customer.Customer.EbCusLocalRef)
            EB.SystemTables.setAv(Y.IRC.LC.AMOUNT.POS)
            EB.SystemTables.setEtext("IRC LC Amount must be 0")
            EB.ErrorProcessing.StoreEndError()
        END
    END
    
    
RETURN
*** </region>
END
