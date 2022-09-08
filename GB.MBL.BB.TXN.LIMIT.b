SUBROUTINE GB.MBL.BB.TXN.LIMIT
*-----------------------------------------------------------------------------
** Subroutine Description:
* Transaction Limit, System will be able to handale transaction limit Account/Category -wise
* Subroutine Type:
* Attached To    : ACTIVITY.API
* Attached As    : PREE.ROUTINE ACTIVITY.API, ACTIVITY.CLASS -ACCOUNTS-DEBIT-ARRANGEMENT, PROPERTY.CLASS - ACCOUNT, PC.ACTION - DR.MOVEMENT
* ACTIVITY.CLASS -ACCOUNTS-CREDIT-ARRANGEMENT, PROPERTY.CLASS - ACCOUNT, PC.ACTION - CR.MOVEMENT
*-----------------------------------------------------------------------------
* Modification History :
* 30/03/2020 -                            NEW   - Sarowar Mortoza
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
    $USING FT.Contract
    $USING TT.Contract
    $USING AC.AccountOpening
    $USING EB.OverrideProcessing
    $INSERT I_F.MBL.TXN.LIMIT.ACCTWISE
    $INSERT I_F.MBL.TXN.LIMIT.PRODUCTWISE
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

    FN.AC="F.ACCOUNT"
    F.AC=""
      
    FN.TXN.LIMIT.ACCTWISE="F.MBL.TXN.LIMIT.ACCTWISE"
    F.TXN.LIMIT.ACCTWISE=""
    FN.TXN.LIMIT.PRODUCTWISE="F.MBL.TXN.LIMIT.PRODUCTWISE"
    F.TXN.LIMIT.PRODUCTWISE=""
    
    Y.AC.NO = c_aalocLinkedAccount
    Y.TXN.REF = FIELD(c_aalocArrActivityRec<AA.Framework.ArrangementActivity.ArrActTxnContractId>,'\',1)
    Y.TXN.SYS.ID = c_aalocArrActivityRec<AA.Framework.ArrangementActivity.ArrActTxnSystemId>
    Y.RECORD.STATUS = c_aalocActivityStatus
    Y.TXN.CO.CODE = c_aalocArrActivityRec<AA.Framework.ArrangementActivity.ArrActArrCompanyCode>
    
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
    EB.DataAccess.Opf(FN.AC, F.AC)
    EB.DataAccess.Opf(FN.TXN.LIMIT.ACCTWISE, F.TXN.LIMIT.ACCTWISE)
    EB.DataAccess.Opf(FN.TXN.LIMIT.PRODUCTWISE, F.TXN.LIMIT.PRODUCTWISE)
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>
    GOSUB GET.FT.AC.INFO ; *
    
    IF (Y.FT.AMT GT Y.DR.TXN.LMT.AMT.AC AND Y.DR.TXN.LMT.AMT.AC NE '') OR (Y.FT.AMT GT Y.CR.TXN.LMT.AMT.AC AND Y.CR.TXN.LMT.AMT.AC NE '' )THEN
        EB.SystemTables.setText("DR./CR. Account TXN Limit Amount Over Account Wise")
        EB.OverrideProcessing.StoreOverride(CurrNo)
    END
    
    IF ((Y.FT.AMT GT Y.ONLINE.DR.TXN.LMT.AMT.AC AND Y.ONLINE.DR.TXN.LMT.AMT.AC NE '' ) OR (Y.FT.AMT GT Y.ONLINE.CR.TXN.LMT.AMT.AC AND Y.ONLINE.CR.TXN.LMT.AMT.AC NE '' )) AND ONLINE.FLAG EQ '1' THEN
        EB.SystemTables.setText("DR./CR. Online Account TXN Limit Amount Over Account Wise")
        EB.OverrideProcessing.StoreOverride(CurrNo)
    END
    
    IF (Y.FT.AMT GT Y.DR.TXN.LMT.AMT.CAT AND Y.DR.TXN.LMT.AMT.CAT NE '' ) OR (Y.FT.AMT GT Y.CR.TXN.LMT.AMT.CAT AND Y.CR.TXN.LMT.AMT.CAT NE '' ) THEN
        EB.SystemTables.setText("DR./CR. Account TXN Limit Amount Over Product Wise")
        EB.OverrideProcessing.StoreOverride(CurrNo)
    END
    
    IF ((Y.FT.AMT GT Y.ONLINE.DR.TXN.LMT.AMT.CAT  AND Y.ONLINE.DR.TXN.LMT.AMT.CAT NE '') OR (Y.FT.AMT GT Y.ONLINE.CR.TXN.LMT.AMT.CAT AND Y.ONLINE.CR.TXN.LMT.AMT.CAT NE '' )) AND ONLINE.FLAG EQ '1' THEN
        EB.SystemTables.setText("DR./CR. Online Account TXN Limit Amount Over Product Wise")
        EB.OverrideProcessing.StoreOverride(CurrNo)
    END
          
    GOSUB GET.TT.AC.INFO ; *

    IF (Y.TT.AMT GT Y.DR.TXN.LMT.AMT.AC AND Y.DR.TXN.LMT.AMT.AC NE '') OR (Y.TT.AMT GT Y.CR.TXN.LMT.AMT.AC AND Y.CR.TXN.LMT.AMT.AC NE '' )THEN
        EB.SystemTables.setText("DR./CR. Account TXN Limit Amount Over Account Wise")
        EB.OverrideProcessing.StoreOverride(CurrNo)
    END
    
    IF ((Y.TT.AMT GT Y.ONLINE.DR.TXN.LMT.AMT.AC AND Y.ONLINE.DR.TXN.LMT.AMT.AC NE '' ) OR (Y.TT.AMT GT Y.ONLINE.CR.TXN.LMT.AMT.AC AND Y.ONLINE.CR.TXN.LMT.AMT.AC NE '' )) AND ONLINE.FLAG EQ '1' THEN
        EB.SystemTables.setText("DR./CR. Online Account TXN Limit Amount Over Account Wise")
        EB.OverrideProcessing.StoreOverride(CurrNo)
    END
    
    IF (Y.TT.AMT GT Y.DR.TXN.LMT.AMT.CAT AND Y.DR.TXN.LMT.AMT.CAT NE '' ) OR (Y.TT.AMT GT Y.CR.TXN.LMT.AMT.CAT AND Y.CR.TXN.LMT.AMT.CAT NE '' ) THEN
        EB.SystemTables.setText("DR./CR. Account TXN Limit Amount Over Product Wise")
        EB.OverrideProcessing.StoreOverride(CurrNo)
    END
    
    IF ((Y.TT.AMT GT Y.ONLINE.DR.TXN.LMT.AMT.CAT  AND Y.ONLINE.DR.TXN.LMT.AMT.CAT NE '') OR (Y.TT.AMT GT Y.ONLINE.CR.TXN.LMT.AMT.CAT AND Y.ONLINE.CR.TXN.LMT.AMT.CAT NE '' )) AND ONLINE.FLAG EQ '1' THEN
        EB.SystemTables.setText("DR./CR. Online Account TXN Limit Amount Over Product Wise")
        EB.OverrideProcessing.StoreOverride(CurrNo)
    END
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= GET.FT.AC.INFO>
GET.FT.AC.INFO:
*** <desc> </desc>
    EB.DataAccess.FRead(FN.FT.NAU,Y.TXN.REF,R.FT.REC,F.FT.NAU,Y.ERR)
    Y.DR.AC=R.FT.REC<FT.Contract.FundsTransfer.DebitAcctNo>
    Y.CR.AC=R.FT.REC<FT.Contract.FundsTransfer.CreditAcctNo>
    Y.CO.CODE=R.FT.REC<FT.Contract.FundsTransfer.CoCode>
    Y.DR.AMT=R.FT.REC<FT.Contract.FundsTransfer.DebitAmount>
    Y.CR.AMT=R.FT.REC<FT.Contract.FundsTransfer.CreditAmount>
    IF Y.DR.AMT EQ '' THEN
        Y.FT.AMT=Y.CR.AMT
    END ELSE
        Y.FT.AMT =Y.DR.AMT
    END
      
    EB.DataAccess.FRead(FN.AC, Y.DR.AC, R.DR.AC.REC, F.AC, Y.ERR)
    Y.DR.AC.CO.CODE=R.DR.AC.REC<AC.AccountOpening.Account.CoCode>
    Y.DR.AC.CATAG=R.DR.AC.REC<AC.AccountOpening.Account.Category>
        
    EB.DataAccess.FRead(FN.AC, Y.CR.AC, R.AC.REC, F.AC, Y.ERR)
    Y.CR.AC.CO.CODE=R.AC.REC<AC.AccountOpening.Account.CoCode>
    Y.CR.AC.CATAG=R.AC.REC<AC.AccountOpening.Account.Category>
        
    IF (Y.DR.AC.CO.CODE NE Y.CO.CODE) OR (Y.CR.AC.CO.CODE NE Y.CO.CODE) THEN
        ONLINE.FLAG = 1
    END ELSE
        ONLINE.FLAG = 0
    END
    
*******ACCOUNT WISE DR/CR TXN LIMIT************************************
    EB.DataAccess.FRead(FN.TXN.LIMIT.ACCTWISE, Y.DR.AC, R.DR.TXN.LIMIT, F.TXN.LIMIT.ACCTWISE, Y.ERR)
    Y.DR.TXN.LMT.AMT.AC=R.DR.TXN.LIMIT<TXN.LMTACWISE.DR.TXN.LMT>
    Y.ONLINE.DR.TXN.LMT.AMT.AC=R.DR.TXN.LIMIT<TXN.LMTACWISE.ONLINE.DR.TXN.LMT>
    
    EB.DataAccess.FRead(FN.TXN.LIMIT.ACCTWISE, Y.CR.AC, R.CR.TXN.LIMIT, F.TXN.LIMIT.ACCTWISE, Y.ERR)
    Y.CR.TXN.LMT.AMT.AC=R.CR.TXN.LIMIT<TXN.LMTACWISE.CR.TXN.LMT>
    Y.ONLINE.CR.TXN.LMT.AMT.AC=R.CR.TXN.LIMIT<TXN.LMTACWISE.ONLINE.CR.TXN.LMT>

*******CATEGORY WISE DR/CR TXN LIMIT************************************
    EB.DataAccess.FRead(FN.TXN.LIMIT.PRODUCTWISE, Y.DR.AC.CATAG, R.DR.TXN.LMT.CAT, F.TXN.LIMIT.PRODUCTWISE, Y.ERR)
    Y.DR.TXN.LMT.AMT.CAT=R.DR.TXN.LMT.CAT<TXN.LMTCATWISE.DR.TXN.LMT>
    Y.ONLINE.DR.TXN.LMT.AMT.CAT=R.DR.TXN.LMT.CAT<TXN.LMTCATWISE.ONLINE.DR.TXN.LMT>
    
    EB.DataAccess.FRead(FN.TXN.LIMIT.PRODUCTWISE, Y.CR.AC.CATAG, R.CR.TXN.LMT.CAT, F.TXN.LIMIT.PRODUCTWISE, Y.ERR)
    Y.CR.TXN.LMT.AMT.CAT=R.CR.TXN.LMT.CAT<TXN.LMTCATWISE.CR.TXN.LMT>
    Y.ONLINE.CR.TXN.LMT.AMT.CAT=R.CR.TXN.LMT.CAT<TXN.LMTCATWISE.ONLINE.CR.TXN.LMT>
        
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= GET.TT.AC.INFO>
GET.TT.AC.INFO:
*** <desc> </desc>
    Y.CO.CODE=''
    EB.DataAccess.FRead(FN.TT.NAU,Y.TXN.REF,R.TT,F.TT.NAU,Y.ERR)
    Y.CO.CODE=R.TT<TT.Contract.Teller.TeCoCode>
    Y.TT.AMT=R.TT<TT.Contract.Teller.TeAmountLocalOne>
    
    Y.DR.CR.MARKER= R.TT<TT.Contract.Teller.TeDrCrMarker>
    IF Y.DR.CR.MARKER EQ 'DEBIT' THEN
        Y.DR.AC=R.TT<TT.Contract.Teller.TeAccountOne>
    END ELSE
        Y.DR.AC=R.TT<TT.Contract.Teller.TeAccountTwo>
    END
        
    IF Y.DR.CR.MARKER EQ 'CREDIT' THEN
        Y.CR.AC=R.TT<TT.Contract.Teller.TeAccountOne>
    END ELSE
        Y.CR.AC=R.TT<TT.Contract.Teller.TeAccountTwo>
    END
    
    EB.DataAccess.FRead(FN.AC, Y.DR.AC, R.DR.AC.REC, F.AC, Y.ERR)
    Y.DR.AC.CO.CODE=R.DR.AC.REC<AC.AccountOpening.Account.CoCode>
    Y.DR.AC.CATAG=R.DR.AC.REC<AC.AccountOpening.Account.Category>
        
    EB.DataAccess.FRead(FN.AC, Y.CR.AC, R.AC.REC, F.AC, Y.ERR)
    Y.CR.AC.CO.CODE=R.AC.REC<AC.AccountOpening.Account.CoCode>
    Y.CR.AC.CATAG=R.AC.REC<AC.AccountOpening.Account.Category>
        
    IF (Y.DR.AC.CO.CODE NE Y.CO.CODE) OR (Y.CR.AC.CO.CODE NE Y.CO.CODE) THEN
        ONLINE.FLAG = 1
    END ELSE
        ONLINE.FLAG = 0
    END

*******ACCOUNT WISE DR/CR TXN LIMIT************************************
    EB.DataAccess.FRead(FN.TXN.LIMIT.ACCTWISE, Y.DR.AC, R.DR.TXN.LIMIT, F.TXN.LIMIT.ACCTWISE, Y.ERR)
    Y.DR.TXN.LMT.AMT.AC=R.DR.TXN.LIMIT<TXN.LMTACWISE.DR.TXN.LMT>
    Y.ONLINE.DR.TXN.LMT.AMT.AC=R.DR.TXN.LIMIT<TXN.LMTACWISE.ONLINE.DR.TXN.LMT>
    
    EB.DataAccess.FRead(FN.TXN.LIMIT.ACCTWISE, Y.CR.AC, R.CR.TXN.LIMIT, F.TXN.LIMIT.ACCTWISE, Y.ERR)
    Y.CR.TXN.LMT.AMT.AC=R.CR.TXN.LIMIT<TXN.LMTACWISE.CR.TXN.LMT>
    Y.ONLINE.CR.TXN.LMT.AMT.AC=R.CR.TXN.LIMIT<TXN.LMTACWISE.ONLINE.CR.TXN.LMT>

*******CATEGORY WISE DR/CR TXN LIMIT************************************
    EB.DataAccess.FRead(FN.TXN.LIMIT.PRODUCTWISE, Y.DR.AC.CATAG, R.DR.TXN.LMT.CAT, F.TXN.LIMIT.PRODUCTWISE, Y.ERR)
    Y.DR.TXN.LMT.AMT.CAT=R.DR.TXN.LMT.CAT<TXN.LMTCATWISE.DR.TXN.LMT>
    Y.ONLINE.DR.TXN.LMT.AMT.CAT=R.DR.TXN.LMT.CAT<TXN.LMTCATWISE.ONLINE.DR.TXN.LMT>
    
    EB.DataAccess.FRead(FN.TXN.LIMIT.PRODUCTWISE, Y.CR.AC.CATAG, R.CR.TXN.LMT.CAT, F.TXN.LIMIT.PRODUCTWISE, Y.ERR)
    Y.CR.TXN.LMT.AMT.CAT=R.CR.TXN.LMT.CAT<TXN.LMTCATWISE.CR.TXN.LMT>
    Y.ONLINE.CR.TXN.LMT.AMT.CAT=R.CR.TXN.LMT.CAT<TXN.LMTCATWISE.ONLINE.CR.TXN.LMT>
    
RETURN
*** </region>

END





