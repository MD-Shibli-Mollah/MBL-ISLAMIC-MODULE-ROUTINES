* @ValidationCode : MjoyNTQ0OTg3NTpDcDEyNTI6MTU5MzUxMDA2ODU1OTpERUxMOi0xOi0xOjA6MDpmYWxzZTpOL0E6REVWXzIwMTcxMC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 30 Jun 2020 15:41:08
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.MBL.CC.A.TRAN.AC.SMS.OUT

    $INSERT  I_COMMON
    $INSERT  I_EQUATE
    $INSERT  I_GTS.COMMON
    
    $USING EB.SystemTables
    $USING EB.Foundation
    $USING EB.DataAccess
    $USING ST.ChqSubmit
    $USING AC.AccountOpening
    $USING ST.Customer
    $USING AC.Config
    
    Y.CHK.AMOUNT = EB.SystemTables.getRNew(ST.ChqSubmit.ChequeCollection.ChqColAmount)

    EB.Foundation.MapLocalFields("CHEQUE.COLLECTION","CHQ.COLL.STATUS",Y.CC.STATUS.POS)
    Y.CHQ.STATUS = EB.SystemTables.getRNew(ST.ChqSubmit.ChequeCollection.ChqColLocalRef)<1,Y.CC.STATUS.POS>

    IF EB.SystemTables.getVFunction() NE "A" OR Y.CHQ.STATUS NE '' THEN RETURN

* Please add all category in CAT.LIST which will propagate through the entire subroutine.
    FN.AC.CLASS = 'F.ACCOUNT.CLASS'
    F.AC.CLASS = ''
    EB.DataAccess.Opf(FN.AC.CLASS,F.AC.CLASS)
    
    Y.AC.CLASS.ID = 'U-RETAIL.CAT'
    EB.DataAccess.FRead(FN.AC.CLASS,Y.AC.CLASS.ID,R.AC.CLASS, F.AC.CLASS, ER.AC.CLASS)
    Y.CAT.LIST = R.AC.CLASS<AC.Config.AccountClass.ClsCategory>

    FN.AC = 'F.ACCOUNT'
    F.AC = ''
    EB.DataAccess.Opf(FN.AC,F.AC)

    FN.CUS = 'F.CUSTOMER'
    F.CUS = ''
    EB.DataAccess.Opf(FN.CUS,F.CUS)

    R.CR.AC.REC = ''
    R.DR.AC.REC = ''
    Y.CR.AC.ERR = ''
    Y.DR.AC.ERR = ''
    Y.CR.AC.ID = ''
    Y.DR.AC.ID = ''
    Y.CR.SMS.OUT = ''
    Y.DR.SMS.OUT = ''
    Y.CR.FILE.NAME = ''
    Y.DR.FILE.NAME = ''
    TOT.DEBIT1.AMT=''

    Y.TT.ID = EB.SystemTables.getRNew(ST.ChqSubmit.ChequeCollection.ChqColTxnId)

    Y.TODAY = EB.SystemTables.getToday()
    TIME.ST = TIMEDATE()
    Y.DATE.TIME =Y.TODAY:'_':TIME.ST[1,2]:TIME.ST[4,2]:TIME.ST[7,2]
    Y.DT.TM = Y.TODAY:' ':TIME.ST[1,2]:':':TIME.ST[4,2]


************
    !TT.PROCESS
************

    Y.VAL = EB.SystemTables.getRNew(ST.ChqSubmit.ChequeCollection.ChqColTxnCode)

    BEGIN CASE
        CASE Y.VAL EQ 93
            GOSUB CC.CRAC.FILE.GEN

    END CASE
RETURN


CC.CRAC.FILE.GEN:
******************

    
    Y.CR.AC.ID = EB.SystemTables.getRNew(ST.ChqSubmit.ChequeCollection.ChqColCreditAccNo)

    EB.DataAccess.FRead(FN.AC,Y.CR.AC.ID,R.CR.AC.REC,F.AC,Y.CR.AC.ERR)
    Y.CR.CUS.ID = R.CR.AC.REC<AC.AccountOpening.Account.Customer>
    Y.CR.AC.BR = R.CR.AC.REC<AC.AccountOpening.Account.CoCode>

    EB.DataAccess.FRead(FN.CUS,Y.CR.CUS.ID,R.CC.CR.CUS.REC,F.CUS,Y.CUS.ERR)
    Y.CC.CUS.CELL.CR = R.CC.CR.CUS.REC<ST.Customer.Customer.EbCusSmsOne>

    Y.SMS.BP = '/t24bnk/mblisl/T24/UD/tcupload/SSL.SMS.OUT/cbsfile'
    OPEN Y.SMS.BP TO F.SMS.OUT ELSE
        RETURN
    END

    LOCATE R.CR.AC.REC<AC.AccountOpening.Account.Category> IN Y.CAT.LIST<1,1> SETTING Y.POS THEN

        Y.CR.SMS.OUT = Y.TT.ID:'#':Y.DT.TM:'#':Y.VAL:'#':EB.SystemTables.getRNew(ST.ChqSubmit.ChequeCollection.ChqColNarrative):'#':EB.SystemTables.getRNew(ST.ChqSubmit.ChequeCollection.ChqColCreditAccNo):'#':'CR':'#':'BDT':EB.SystemTables.getRNew(ST.ChqSubmit.ChequeCollection.ChqColAmount):'#':Y.CC.CUS.CELL.CR:'#':R.CR.AC.REC<AC.AccountOpening.Account.OnlineActualBal>:'#':Y.CR.CUS.ID:'#':R.CR.AC.REC<AC.AccountOpening.Account.Category>:'#':EB.SystemTables.getRNew(ST.ChqSubmit.ChequeCollection.ChqColCoCode)
        Y.CR.FILE.NAME = 'SMS_':Y.TT.ID:".":'CR':'.':Y.DATE.TIME

        WRITE Y.CR.SMS.OUT TO F.SMS.OUT,Y.CR.FILE.NAME

    END

RETURN
