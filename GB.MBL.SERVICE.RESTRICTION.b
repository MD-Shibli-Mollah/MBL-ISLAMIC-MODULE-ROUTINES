SUBROUTINE GB.MBL.SERVICE.RESTRICTION
*-----------------------------------------------------------------------------
** Subroutine Description:
* ONLINE, IB & ATM Sevice Transaction Restriction
* Subroutine Type:
* Attached To    : ACTIVITY.API
* Attached As    : PREE.ROUTINE ACTIVITY.API, ACTIVITY.CLASS -ACCOUNTS-DEBIT-ARRANGEMENT, PROPERTY.CLASS - ACCOUNT, PC.ACTION - DR.MOVEMENT
* ACTIVITY.CLASS -ACCOUNTS-CREDIT-ARRANGEMENT, PROPERTY.CLASS - ACCOUNT, PC.ACTION - CR.MOVEMENT
*-----------------------------------------------------------------------------
* Modification History :
* 20/01/2020 -                            NEW   - Sarowar Mortoza
*                                                     FDS Pvt Ltd
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.APP.COMMON
    $INSERT I_AA.LOCAL.COMMON
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
    $USING AC.AccountOpening
*-----------------------------------------------------------------------------
    GOSUB INITIALISE ; *
    GOSUB OPENFILE ; *
    GOSUB PROCESS ; *
RETURN
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
    
    FN.FT.TXN = "F.FT.TXN.TYPE.CONDITION"
    F.FT.TXN = ""
    FN.TT.TXN="F.TELLER.TRANSACTION"
    F.TT.TXN=""
    
    FN.AC="F.ACCOUNT"
    F.AC=""
    
      
    Y.AC.NO = c_aalocLinkedAccount
    Y.TXN.REF = FIELD(c_aalocArrActivityRec<AA.Framework.ArrangementActivity.ArrActTxnContractId>,'\',1)
    Y.TXN.SYS.ID = c_aalocArrActivityRec<AA.Framework.ArrangementActivity.ArrActTxnSystemId>
    Y.RECORD.STATUS = c_aalocActivityStatus
    
* Y.CO.CODE=EB.SystemTables.getIdCompany()
    Y.TXN.CO.CODE = c_aalocArrActivityRec<AA.Framework.ArrangementActivity.ArrActArrCompanyCode>
    Y.CO=c_aalocArrActivityRec<AA.Framework.ArrangementActivity.ArrActCoCode>
         
    IF Y.AC.NO MATCHES '3A...' THEN
        RETURN
    END
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
    EB.DataAccess.Opf(FN.FT.TXN,F.FT.TXN)
    EB.DataAccess.Opf(FN.TT.TXN,F.TT.TXN)
    EB.DataAccess.Opf(FN.AC, F.AC)
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>
    GOSUB GET.TXN.CODE ; *GET TT/FT TXN CODE DURING TRANSACTION
    GOSUB GET.LOCAL.REF ; *GET LOCAL REFERENCE FIELD FOR ONLINE,IB,ATM RESTRICT
    
    IF Y.TXN.SYS.ID EQ 'FT' AND (Y.IB.RESTRICT EQ 'IB' AND Y.TXN.CODE EQ '213')  THEN
        EB.SystemTables.setEtext("Internet Service is Restricted for the Account")
        EB.ErrorProcessing.StoreEndError()
    END
    
    IF Y.TXN.SYS.ID EQ 'FT' AND (Y.ATM.RESTRICT EQ 'ATM' AND Y.TXN.CODE EQ '866')  THEN
        EB.SystemTables.setEtext("ATM Service is Restricted for the Account")
        EB.ErrorProcessing.StoreEndError()
    END
    
    IF Y.TXN.SYS.ID EQ 'FT' THEN
        GOSUB GET.FT.AC.INFO ; *GET FT DR/CR ACCOUNT COMPANY CODE INFO
    END
    
    IF Y.TXN.SYS.ID EQ 'TT' THEN
        GOSUB GET.TT.AC.INFO ; *GET TT DR/CR AC COMPANY CODE INFO
    END
    
    IF Y.ONLINE.RESTRICT EQ 'ONLINE' AND ONLINE.FLAG EQ '1'  THEN
        EB.SystemTables.setEtext("Online Service is Restricted for the Account")
        EB.ErrorProcessing.StoreEndError()
    END
        
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= GET.TXN.CODE>
GET.TXN.CODE:
*** <desc>GET TT/FT TXN CODE DURING TRANSACTION </desc>
    IF Y.TXN.SYS.ID EQ 'FT' THEN
        Y.TXN.TYPE = FT.Contract.getIdTxnType()
        EB.DataAccess.FRead(FN.FT.TXN, Y.TXN.TYPE, R.FT.TXN, F.FT.TXN, Y.ERR)
        Y.TXN.CODE=R.FT.TXN<FT.Config.TxnTypeCondition.FtSixTxnCodeCr>
    END
    
    IF Y.TXN.SYS.ID EQ 'TT' THEN
        EB.DataAccess.FRead(FN.TT.NAU,Y.TXN.REF,R.TT.REC,F.TT.NAU,Y.ERR)
        Y.TXN.CODE = R.TT.REC<TT.Contract.Teller.TeTransactionCode>
    END
    
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= GET.LOCAL.REF>
GET.LOCAL.REF:
*** <desc>GET LOCAL REFERENCE FIELD FOR ONLINE,IB,ATM RESTRICT </desc>
    Y.APP.NAME ="AA.PRD.DES.ACCOUNT"
    LOCAL.FIELDS = ""
    LOCAL.FIELDS = "LT.SEV.RESTRIC"
    FLD.POS = ""
    EB.Updates.MultiGetLocRef(Y.APP.NAME, LOCAL.FIELDS,FLD.POS)
    Y.LT.SEV.RESTRIC.POS=FLD.POS<1,1>

    Y.ARRANGEMENT.ID=c_aalocArrId
    CALL AA.GET.ARRANGEMENT.CONDITIONS(Y.ARRANGEMENT.ID,'ACCOUNT',Y.PROPERTY,'',Y.RET.ID,Y.RET.COND,E.RET.ERR)
    Y.RET.COND = RAISE(Y.RET.COND)
    Y.AC.RESTRICT = Y.RET.COND<AA.Account.Account.AcLocalRef,Y.LT.SEV.RESTRIC.POS>
    
    FIND 'ONLINE' IN Y.AC.RESTRICT<1,1> SETTING RESTRICT.POS1,RESTRICT.POS2,RESTRICT.POS3 THEN
        Y.ONLINE.RESTRICT=Y.RET.COND<AA.Account.Account.AcLocalRef,Y.LT.SEV.RESTRIC.POS,RESTRICT.POS3>
    END
    
    FIND 'IB' IN Y.AC.RESTRICT<1,1> SETTING RESTRICT.POS1,RESTRICT.POS2,RESTRICT.POS3 THEN
        Y.IB.RESTRICT=Y.RET.COND<AA.Account.Account.AcLocalRef,Y.LT.SEV.RESTRIC.POS,RESTRICT.POS3>
    END
    
    FIND 'ATM' IN Y.AC.RESTRICT<1,1> SETTING RESTRICT.POS1,RESTRICT.POS2,RESTRICT.POS3 THEN
        Y.ATM.RESTRICT=Y.RET.COND<AA.Account.Account.AcLocalRef,Y.LT.SEV.RESTRIC.POS,RESTRICT.POS3>
    END
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= GET.FT.AC.INFO>
GET.FT.AC.INFO:
*** <desc>GET FT DR/CR ACCOUNT COMPANY CODE INFO </desc>
    EB.DataAccess.FRead(FN.FT.NAU,Y.TXN.REF,R.FT.REC,F.FT.NAU,Y.ERR)
    Y.DR.AC=R.FT.REC<FT.Contract.FundsTransfer.DebitAcctNo>
    Y.CR.AC=R.FT.REC<FT.Contract.FundsTransfer.CreditAcctNo>
    Y.CO.CODE=R.FT.REC<FT.Contract.FundsTransfer.CoCode>
        
    EB.DataAccess.FRead(FN.AC, Y.DR.AC, R.DR.AC.REC, F.AC, Y.ERR)
    Y.DR.AC.CO.CODE=R.DR.AC.REC<AC.AccountOpening.Account.CoCode>
        
    EB.DataAccess.FRead(FN.AC, Y.CR.AC, R.AC.REC, F.AC, Y.ERR)
    Y.CR.AC.CO.CODE=R.AC.REC<AC.AccountOpening.Account.CoCode>
        
    IF (Y.DR.AC.CO.CODE NE Y.CO.CODE) OR (Y.CR.AC.CO.CODE NE Y.CO.CODE) THEN
        ONLINE.FLAG = 1
    END ELSE
        ONLINE.FLAG = 0
    END
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= GET.TT.AC.INFO>
GET.TT.AC.INFO:
*** <desc>GET TT DR/CR AC COMPANY CODE INFO </desc>
    Y.CO.CODE=''
    EB.DataAccess.FRead(FN.TT.NAU,Y.TXN.REF,R.TT,F.TT.NAU,Y.ERR)
    Y.AC = R.TT<TT.Contract.Teller.TeAccountTwo>
    Y.CO.CODE=R.TT<TT.Contract.Teller.TeCoCode>

    EB.DataAccess.FRead(FN.AC, Y.AC, R.AC.REC, F.AC, Y.ERR)
    Y.AC.CO.CODE=R.AC.REC<AC.AccountOpening.Account.CoCode>
        
    IF Y.AC.CO.CODE NE Y.CO.CODE THEN
        ONLINE.FLAG = 1
    END ELSE
        ONLINE.FLAG = 0
    END
    
RETURN
*** </region>

END







