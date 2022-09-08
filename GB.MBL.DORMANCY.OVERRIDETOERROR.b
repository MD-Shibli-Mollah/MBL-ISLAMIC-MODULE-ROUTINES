SUBROUTINE GB.MBL.DORMANCY.OVERRIDETOERROR
*-----------------------------------------------------------------------------
** Subroutine Description:
* Raise error message for Dr. Transaction if Account is dormant
* Subroutine Type:
* Attached To    : ACTIVITY.API
* Attached As    : PREE.ROUTINE ACTIVITY.API, ACTIVITY.CLASS -ACCOUNTS-DEBIT-ARRANGEMENT, PROPERTY.CLASS - ACCOUNT, PC.ACTION - DR.MOVEMENT
*-----------------------------------------------------------------------------
* Modification History :
* 20/01/2020 -                            NEW   - Sarowar Mortoza
*                                                     FDS Pvt Ltd
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.APP.COMMON
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_AA.CONTRACT.DETAILS
    $USING AA.Framework
    $USING AA.Account
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING EB.ErrorProcessing
    $USING EB.Updates
    $USING FT.Contract
    $USING FT.Config
    $USING TT.Contract
    $USING TT.Config
    $USING AA.PaymentSchedule
    $USING AC.AccountOpening
*-----------------------------------------------------------------------------
    GOSUB INITIALISE ; *
    GOSUB OPENFILE ; *
    GOSUB PROCESS ; *
*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc> </desc>
    FN.TT = "F.TELLER"
    F.TT = ""
    FN.TT.NAU = "F.TELLER$NAU"
    F.TT.NAU = ""
    
    FN.FT = "F.FUNDS.TRANSFER"
    F.FT = ""
    FN.FT.NAU = "F.FUNDS.TRANSFER$NAU"
    F.FT.NAU = ""
    
    FN.AC="F.ACCOUNT"
    F.AC=""
    
    FN.AA.AC.DETAIL="F.AA.ACCOUNT.DETAILS"
    F.AA.AC.DETAIL=""
    
    Y.AC.NO = c_aalocLinkedAccount
    Y.TXN.REF = FIELD(c_aalocArrActivityRec<AA.Framework.ArrangementActivity.ArrActTxnContractId>,'\',1)
    Y.TXN.SYS.ID = c_aalocArrActivityRec<AA.Framework.ArrangementActivity.ArrActTxnSystemId>
    Y.ARRANGEMENT.ID=c_aalocArrId
    Y.ACTIVITY=c_aalocArrActivityRec<AA.Framework.ArrangementActivity.ArrActActivity>
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= OPENFILE>
OPENFILE:
*** <desc> </desc>
    EB.DataAccess.Opf(FN.TT,F.TT)
    EB.DataAccess.Opf(FN.TT.NAU,F.TT.NAU)
    EB.DataAccess.Opf(FN.FT,F.FT)
    EB.DataAccess.Opf(FN.FT.NAU,F.FT.NAU)
    EB.DataAccess.Opf(FN.AC, F.AC)
    EB.DataAccess.Opf(FN.AA.AC.DETAIL, F.AA.AC.DETAIL)
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>
    GOSUB GET.TXN.INFO ; *FOR GET DR. ACCOUNT INFO

    Y.DORMANCY.STATUS=AA$ACCOUNT.DETAILS<AA.PaymentSchedule.AccountDetails.AdArrDormancyStatus>

    IF Y.TXN.SYS.ID EQ 'TT' AND Y.DORMANCY.STATUS EQ 'DORMANT' THEN
        EB.SystemTables.setAf(TT.Contract.Teller.TeAccountTwo)
        EB.SystemTables.setEtext('Account is Dormant not Possible Withdraw')
        EB.ErrorProcessing.StoreEndError()
    END
    
    IF Y.TXN.SYS.ID EQ 'FT' AND Y.FT.DORMANCY.STATUS EQ 'DORMANT' THEN
        EB.SystemTables.setAf(FT.Contract.FundsTransfer.DebitAcctNo)
        EB.SystemTables.setEtext('Account is Dormant not Possible Withdraw')
        EB.ErrorProcessing.StoreEndError()
    END
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= GET.TXN.INFO>
GET.TXN.INFO:
*** <desc>FOR GET DR. ACCOUNT INFO </desc>
    IF Y.TXN.SYS.ID EQ 'TT' THEN
        EB.DataAccess.FRead(FN.TT.NAU,Y.TXN.REF,R.TT.REC,F.TT.NAU,Y.ERR)
        Y.DR.AC = R.TT.REC<TT.Contract.Teller.TeAccountTwo>
        Y.DR.AC1 = R.TT.REC<TT.Contract.Teller.TeAccountOne>
    END
    IF Y.TXN.SYS.ID EQ 'FT' THEN
        EB.DataAccess.FRead(FN.FT.NAU,Y.TXN.REF,R.FT.REC,F.FT.NAU,Y.ERR)
        Y.DR.AC = R.FT.REC<FT.Contract.FundsTransfer.DebitAcctNo>
        
        EB.DataAccess.FRead(FN.AC, Y.DR.AC, R.AC.REC, F.AC, Y.ERR)
        Y.ARR.ID=R.AC.REC<AC.AccountOpening.Account.ArrangementId>
        EB.DataAccess.FRead(FN.AA.AC.DETAIL, Y.ARR.ID, R.AA.DETAIL, F.AA.AC.DETAIL, Y.ERR)
        Y.FT.DORMANCY.STATUS=R.AA.DETAIL<AA.PaymentSchedule.AccountDetails.AdArrDormancyStatus>
    END
RETURN
*** </region>

END




