SUBROUTINE GB.MBL.A.CHQ.COLL.UNCLR.AMT
*-----------------------------------------------------------------------------
* Subroutine Description:
* This routine is to adjust uncleared amount from suspense account
* Routine Attach To: Auth routine
* Routine Attach Version: CHEQUE.COLLECTION,MBL.OWDCLR.CLEARED.BACPS & CHEQUE.COLLECTION,MBL.OWDCLR.RETURNED.BACPS
*
*-----------------------------------------------------------------------------
* Modification History :
* 24/03/2020 -                             Retrofit   -MD.SAROWAR MORTOZA
*                                                 FDS Bangladesh Limited
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $USING FT.Contract
    $USING AC.AccountOpening
    $USING ST.ChqSubmit
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING EB.Foundation
    $USING EB.ErrorProcessing
*-----------------------------------------------------------------------------
    GOSUB INITIALISE ; *
    GOSUB OPENFILE ; *
    GOSUB PROCESS ; *
RETURN
*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc> </desc>
    FN.ACCOUNT  = 'F.ACCOUNT'
    F.ACCOUNT   = ''
    R.ACCOUNT   = ''
    Y.ERR       = ''
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= OPENFILE>
OPENFILE:
*** <desc> </desc>
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)
    EB.DataAccess.Opf(FN.ACCOUNT,F.ACCOUNT)
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>
    Y.AC.NO = EB.SystemTables.getRNew(ST.ChqSubmit.ChequeCollection.ChqColCreditAccNo)<1,1>
    Y.AMOUNT = EB.SystemTables.getRNew(ST.ChqSubmit.ChequeCollection.ChqColAmount)<1,1>
    
*-----------------------------------------------------------------------------
    Y.UNCLR.POS=""
    FLD.NAMES = 'BACPS.UCLR.AMT'
    FLD.POS=""
    Y.APP.NAME ="ACCOUNT"
    EB.Foundation.MapLocalFields(Y.APP.NAME, FLD.NAMES,FLD.POS)
    Y.UNCLR.POS=FLD.POS<1,1>
    
    EB.DataAccess.FRead(FN.ACCOUNT,Y.AC.NO,R.ACCOUNT,F.ACCOUNT,Y.ERR)
    Y.AC.UNCLR.AMT =  R.ACCOUNT<AC.AccountOpening.Account.LocalRef,Y.UNCLR.POS>

    IF Y.AC.UNCLR.AMT THEN
        Y.AMOUNT2 = (Y.AC.UNCLR.AMT - Y.AMOUNT)
        R.ACCOUNT<AC.AccountOpening.Account.LocalRef,Y.UNCLR.POS>=Y.AMOUNT2
        CALL F.WRITE(FN.ACCOUNT,Y.AC.NO,R.ACCOUNT)
    END
RETURN
*** </region>

END



