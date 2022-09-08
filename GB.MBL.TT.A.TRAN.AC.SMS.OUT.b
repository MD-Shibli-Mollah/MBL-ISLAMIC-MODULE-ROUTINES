* @ValidationCode : MjoyMjQ4MzQ4OTY6Q3AxMjUyOjE1OTM1NDA3MDU4MDM6REVMTDotMTotMTowOjA6ZmFsc2U6Ti9BOkRFVl8yMDE3MTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 01 Jul 2020 00:11:45
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.MBL.TT.A.TRAN.AC.SMS.OUT

    $INSERT  I_COMMON
    $INSERT  I_EQUATE
    $INSERT  I_GTS.COMMON
    
    $USING EB.SystemTables
    $USING EB.Foundation
    $USING EB.DataAccess
    $USING AC.AccountOpening
    $USING ST.Customer
    $USING TT.Contract
    $USING AC.Config

    Y.CHK.AMOUNT = EB.SystemTables.getRNew(TT.Contract.Teller.TeAmountLocalOne)

    IF EB.SystemTables.getVFunction() NE "A" THEN RETURN


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

    Y.TT.ID = EB.SystemTables.getIdNew()
    R.TT.REC = ''
    Y.TT.ERR = ''

    Y.TODAY =EB.SystemTables.getToday()
    TIME.ST = TIMEDATE()
    Y.DATE.TIME =Y.TODAY:'_':TIME.ST[1,2]:TIME.ST[4,2]:TIME.ST[7,2]
    Y.DT.TM = Y.TODAY:' ':TIME.ST[1,2]:TIME.ST[4,2]
    

    Y.VAL = EB.SystemTables.getRNew(TT.Contract.Teller.TeTransactionCode)
************************************************************************************
    Y.DATA = 'Y.VAL=':Y.VAL
    Y.DIR = 'MBL.DATA'
    Y.FILE.NAME = 'AMC'
    OPENSEQ Y.DIR,Y.FILE.NAME TO F.DIR THEN NULL
    WRITESEQ Y.DATA APPEND TO F.DIR ELSE
        CRT "Unable to write"
        CLOSESEQ F.DIR
    END
************************************************************************************
    BEGIN CASE
        CASE Y.VAL EQ 10
            GOSUB TT.CRAC.FILE.GEN

        CASE Y.VAL EQ 9
            GOSUB TT.CRAC.FILE.GEN
            
        CASE Y.VAL EQ 5

            GOSUB TT.CASHWDL.AC2.FILE.GEN

        CASE Y.VAL EQ 14

            GOSUB TT.CASHWDL.AC1.FILE.GEN

        CASE Y.VAL EQ 35
            GOSUB TT.CRAC.FILE.GEN

        CASE Y.VAL EQ 36
            GOSUB TT.CASHWDL.AC1.FILE.GEN

        CASE Y.VAL EQ 44
            GOSUB TT.CASHWDL.AC2.FILE.GEN


    END CASE
RETURN


TT.CRAC.FILE.GEN:
******************


    Y.CR.AC.ID = EB.SystemTables.getRNew(TT.Contract.Teller.TeAccountTwo)

    Y.CR.CUS.ID = EB.SystemTables.getRNew(TT.Contract.Teller.TeCustomerTwo)
    EB.DataAccess.FRead(FN.CUS,Y.CR.CUS.ID,R.TT.CR.CUS.REC,F.CUS,Y.CUS.ERR)
    Y.TT.CUS.CELL.CR = R.TT.CR.CUS.REC<ST.Customer.Customer.EbCusSmsOne>

    EB.DataAccess.FRead(FN.AC,Y.CR.AC.ID,R.CR.AC.REC,F.AC,Y.CR.AC.ERR)
    Y.CR.AC.BR = R.CR.AC.REC<AC.AccountOpening.Account.CoCode>

    Y.SMS.BP = '/t24bnk/mblisl/T24/UD/tcupload/SSL.SMS.OUT/cbsfile'
    OPEN Y.SMS.BP TO F.SMS.OUT ELSE
        RETURN
    END

    LOCATE R.CR.AC.REC<AC.AccountOpening.Account.Category> IN Y.CAT.LIST<1,1> SETTING Y.POS THEN

        Y.CR.SMS.OUT = Y.TT.ID:'#':Y.DT.TM:'#':Y.VAL:'#':EB.SystemTables.getRNew(TT.Contract.Teller.TeNarrativeTwo):'#':EB.SystemTables.getRNew(TT.Contract.Teller.TeAccountTwo):'#':'CR':'#':EB.SystemTables.getRNew(TT.Contract.Teller.TeAmountLocalOne):'#':Y.TT.CUS.CELL.CR:'#':R.CR.AC.REC<AC.AccountOpening.Account.OnlineActualBal>:'#':Y.CR.CUS.ID:'#':R.CR.AC.REC<AC.AccountOpening.Account.Category>:'#':EB.SystemTables.getRNew(TT.Contract.Teller.TeCoCode)
        Y.CR.FILE.NAME = 'SMS_':Y.TT.ID:".":'CR':'.':Y.DATE.TIME

        WRITE Y.CR.SMS.OUT TO F.SMS.OUT,Y.CR.FILE.NAME
    END
RETURN


TT.CASHWDL.AC2.FILE.GEN:
**************************



    Y.DR.AC.ID = EB.SystemTables.getRNew(TT.Contract.Teller.TeAccountTwo)
    Y.DR.CUS.ID=EB.SystemTables.getRNew(TT.Contract.Teller.TeCustomerTwo)

    EB.DataAccess.FRead(FN.CUS,Y.DR.CUS.ID,R.TT.DR.CUS.REC,F.CUS,Y.CUS.ERR)
    Y.TT.CUS.CELL.DR=R.TT.DR.CUS.REC<ST.Customer.Customer.EbCusSmsOne>


    EB.DataAccess.FRead(FN.AC,Y.DR.AC.ID,R.DR.AC.REC,F.AC,Y.DR.AC.ERR)
    Y.DR.AC.BR = R.DR.AC.REC<AC.AccountOpening.Account.CoCode>

    Y.SMS.BP = '/t24bnk/mblisl/T24/UD/tcupload/SSL.SMS.OUT/cbsfile'
    OPEN Y.SMS.BP TO F.SMS.OUT ELSE
        RETURN
    END


    LOCATE R.DR.AC.REC<AC.AccountOpening.Account.Category> IN Y.CAT.LIST<1,1> SETTING Y.POS THEN

        Y.DR.SMS.OUT = Y.TT.ID:'#':Y.DT.TM:'#':Y.VAL:'#':EB.SystemTables.getRNew(TT.Contract.Teller.TeNarrativeTwo):'#':EB.SystemTables.getRNew(TT.Contract.Teller.TeAccountTwo):'#':'DR':'#':EB.SystemTables.getRNew(TT.Contract.Teller.TeAmountLocalOne):'#':Y.TT.CUS.CELL.DR:'#':R.DR.AC.REC<AC.AccountOpening.Account.OnlineActualBal>:'#':Y.DR.CUS.ID:'#':R.DR.AC.REC<AC.AccountOpening.Account.Category>:'#':EB.SystemTables.getRNew(TT.Contract.Teller.TeCoCode)
        Y.DR.FILE.NAME = 'SMS_':Y.TT.ID:".":'DR':'.':Y.DATE.TIME

        WRITE Y.DR.SMS.OUT TO F.SMS.OUT,Y.DR.FILE.NAME

    END
RETURN

!TT.CASHWDL.CHQ.FILE.GEN:
************************

TT.CASHWDL.AC1.FILE.GEN:
************************



    Y.DR.AC.ID = EB.SystemTables.getRNew(TT.Contract.Teller.TeAccountOne)
    Y.DR.CUS.ID=EB.SystemTables.getRNew(TT.Contract.Teller.TeCustomerOne)

    EB.DataAccess.FRead(FN.CUS,Y.DR.CUS.ID,R.TT.DR.CUS.REC,F.CUS,Y.CUS.ERR)
    Y.TT.CUS.CELL.DR=R.TT.DR.CUS.REC<ST.Customer.Customer.EbCusSmsOne>

    EB.DataAccess.FRead(FN.AC,Y.DR.AC.ID,R.DR.AC.REC,F.AC,Y.DR.AC.ERR)

    Y.DR.AC.BR = R.DR.AC.REC<AC.AccountOpening.Account.CoCode>

    Y.SMS.BP = '/t24bnk/mblisl/T24/UD/tcupload/SSL.SMS.OUT/cbsfile'
    OPEN Y.SMS.BP TO F.SMS.OUT ELSE
        RETURN
    END

    LOCATE R.DR.AC.REC<AC.AccountOpening.Account.Category> IN Y.CAT.LIST<1,1> SETTING Y.POS THEN

        Y.DR.SMS.OUT = Y.TT.ID:'#':Y.DT.TM:'#':Y.VAL:'#':EB.SystemTables.getRNew(TT.Contract.Teller.TeNarrativeTwo):'#':EB.SystemTables.getRNew(TT.Contract.Teller.TeAccountOne):'#':'DR':'#':EB.SystemTables.getRNew(TT.Contract.Teller.TeAmountLocalOne):'#':Y.TT.CUS.CELL.DR:'#':R.DR.AC.REC<AC.AccountOpening.Account.OnlineActualBal>:'#':Y.DR.CUS.ID:'#':R.DR.AC.REC<AC.AccountOpening.Account.Category>:'#':EB.SystemTables.getRNew(TT.Contract.Teller.TeCoCode)
        Y.DR.FILE.NAME = 'SMS_':Y.TT.ID:".":'DR':'.':Y.DATE.TIME

        WRITE Y.DR.SMS.OUT TO F.SMS.OUT,Y.DR.FILE.NAME
************************************************************************************
        Y.DATA = 'Y.CAT.LIST=':Y.CAT.LIST:'*':'Y.DR.SMS.OUT=':Y.DR.SMS.OUT:'*':'Y.DR.FILE.NAME=':Y.DR.FILE.NAME
        Y.DIR = 'MBL.DATA'
        Y.FILE.NAME = 'AMC'
        OPENSEQ Y.DIR,Y.FILE.NAME TO F.DIR THEN NULL
        WRITESEQ Y.DATA APPEND TO F.DIR ELSE
            CRT "Unable to write"
            CLOSESEQ F.DIR
        END
************************************************************************************
    END
************************************************************************************
    Y.DATA = 'Y.DR.AC.ID=':Y.DR.AC.ID:'*':'Y.DR.AC.ID=':Y.DR.AC.ID:'*':'Y.POS=':Y.POS:'*':Y.CAT.LIST
    Y.DIR = 'MBL.DATA'
    Y.FILE.NAME = 'AMC'
    OPENSEQ Y.DIR,Y.FILE.NAME TO F.DIR THEN NULL
    WRITESEQ Y.DATA APPEND TO F.DIR ELSE
        CRT "Unable to write"
        CLOSESEQ F.DIR
    END
************************************************************************************

RETURN
