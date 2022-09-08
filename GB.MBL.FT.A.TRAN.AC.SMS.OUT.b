* @ValidationCode : MjoyMjY4MjE5MjA6Q3AxMjUyOjE1OTM1ODEwMjIyNDY6REVMTDotMTotMTowOjA6ZmFsc2U6Ti9BOkRFVl8yMDE3MTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 01 Jul 2020 11:23:42
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.MBL.FT.A.TRAN.AC.SMS.OUT

    $INSERT  I_COMMON
    $INSERT  I_EQUATE
    $INSERT  I_GTS.COMMON


    $USING EB.SystemTables
    $USING EB.Foundation
    $USING EB.DataAccess
    $USING AC.AccountOpening
    $USING ST.Customer
    $USING FT.Contract
    $USING AC.Config

*************MODIFIED ON 16-08-2016 TO ALLOW SMS FOR PAYORDER***************


    IF (EB.SystemTables.getPgmVersion() EQ ",PR.PO.ISSUE") OR (EB.SystemTables.getPgmVersion() EQ ",PR.PO.COLLECTION") THEN
        Y.CHK.AMOUNT = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditAmount)

    END
    ELSE

        Y.CHK.AMOUNT = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitAmount)

    END

    IF EB.SystemTables.getVFunction() NE "A" THEN RETURN

* Please add all category in CAT.LIST which will propagate through the entire subroutine.

    FN.AC.CLASS = 'F.ACCOUNT.CLASS'
    F.AC.CLASS = ''
    EB.DataAccess.Opf(FN.AC.CLASS,F.AC.CLASS)
    
    Y.AC.CLASS.ID = 'U-RETAIL.CAT'
    EB.DataAccess.FRead(FN.AC.CLASS,Y.AC.CLASS.ID,R.AC.CLASS, F.AC.CLASS, ER.AC.CLASS)
    Y.CAT.LIST = R.AC.CLASS<AC.Config.AccountClass.ClsCategory>

    TXN.TYPE='ACNW':@FM:'AC':@FM:'ACIW':@FM:'ACOW'

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


    Y.FT.ID = EB.SystemTables.getIdNew()
    R.FT.REC = ''
    Y.FT.ERR = ''

    Y.TODAY =EB.SystemTables.getToday()
    TIME.ST = TIMEDATE()
    Y.DATE.TIME =Y.TODAY:'_':TIME.ST[1,2]:TIME.ST[4,2]:TIME.ST[7,2]
    Y.TM = TIME.ST[1,2]:':':TIME.ST[4,2]

    LOCATE EB.SystemTables.getRNew(FT.Contract.FundsTransfer.TransactionType) IN TXN.TYPE SETTING Y.TXN.POS THEN



*******************
        !FT.CRAC.FILE.GEN
*******************

        Y.CR.AC.ID = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditAcctNo)
        EB.DataAccess.FRead(FN.AC,Y.CR.AC.ID,R.CR.AC.REC,F.AC,Y.CR.AC.ERR)
        Y.CR.AC.BR = R.CR.AC.REC<AC.AccountOpening.Account.CoCode>

        Y.SMS.BP = '/t24bnk/mblisl/T24/UD/tcupload/SSL.SMS.OUT/cbsfile'
        OPEN Y.SMS.BP TO F.SMS.OUT ELSE
            RETURN
        END

        Y.FT.CUS.ID.CR=EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditCustomer)

        EB.DataAccess.FRead(FN.CUS,Y.FT.CUS.ID.CR,R.CUS.CR.REC,F.CUS,Y.CUS.ERR)
        Y.FT.CUS.CELL.CR=R.CUS.CR.REC<ST.Customer.Customer.EbCusSmsOne>
        
        LOCATE R.CR.AC.REC<AC.AccountOpening.Account.Category> IN Y.CAT.LIST<1,1> SETTING Y.POS THEN

            Y.CR.SMS.OUT = Y.FT.ID:'#':EB.SystemTables.getRNew(FT.Contract.FundsTransfer.AuthDate):' ':Y.TM:'#':EB.SystemTables.getRNew(FT.Contract.FundsTransfer.TransactionType):'#':EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditTheirRef):'#':EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditAcctNo):'#':'CR':'#':EB.SystemTables.getRNew(FT.Contract.FundsTransfer.AmountCredited):'#':Y.FT.CUS.CELL.CR:'#':R.CR.AC.REC<AC.AccountOpening.Account.OnlineActualBal>:'#':Y.FT.CUS.ID.CR:'#':R.CR.AC.REC<AC.AccountOpening.Account.Category>:'#':EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CoCode)
            Y.CR.FILE.NAME = 'SMS_':Y.FT.ID:'.':Y.CR.AC.ID:".":'CR':'.':Y.DATE.TIME

            WRITE Y.CR.SMS.OUT TO F.SMS.OUT,Y.CR.FILE.NAME
        END

*******************
        !FT.DRAC.FILE.GEN:
*******************

        Y.DR.AC.ID = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitAcctNo)
        EB.DataAccess.FRead(FN.AC,Y.DR.AC.ID,R.DR.AC.REC,F.AC,Y.DR.AC.ERR)
        Y.DR.AC.BR = R.DR.AC.REC<AC.AccountOpening.Account.CoCode>

        Y.SMS.BP = '/t24bnk/mblisl/T24/UD/tcupload/SSL.SMS.OUT/cbsfile'
        OPEN Y.SMS.BP TO F.SMS.OUT ELSE
            RETURN
        END

        Y.FT.CUS.ID.DR=EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitCustomer)

        EB.DataAccess.FRead(FN.CUS,Y.FT.CUS.ID.DR,R.CUS.DR.REC,F.CUS,Y.CUS.ERR)
        Y.FT.CUS.CELL.DR=R.CUS.DR.REC<ST.Customer.Customer.EbCusSmsOne>


        LOCATE R.DR.AC.REC<AC.AccountOpening.Account.Category> IN Y.CAT.LIST<1,1> SETTING Y.POS THEN

            Y.DR.SMS.OUT = Y.FT.ID:'#':EB.SystemTables.getRNew(FT.Contract.FundsTransfer.AuthDate):' ':Y.TM:'#':EB.SystemTables.getRNew(FT.Contract.FundsTransfer.TransactionType):'#':EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitTheirRef):'#':EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitAcctNo):'#':'DR':'#':EB.SystemTables.getRNew(FT.Contract.FundsTransfer.AmountDebited):'#':Y.FT.CUS.CELL.DR:'#':R.DR.AC.REC<AC.AccountOpening.Account.OnlineActualBal>:'#':Y.FT.CUS.ID.DR:'#':R.DR.AC.REC<AC.AccountOpening.Account.Category>:'#':EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CoCode)

            Y.DR.FILE.NAME ='SMS_':Y.FT.ID:'.': Y.DR.AC.ID:".":'DR.':Y.DATE.TIME
            WRITE Y.DR.SMS.OUT TO F.SMS.OUT,Y.DR.FILE.NAME
        END


        RETURN

    END
