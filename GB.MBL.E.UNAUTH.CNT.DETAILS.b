* @ValidationCode : Mjo0MTIwMjM1ODk6Q3AxMjUyOjE1OTQxMTQxMTk1NDU6dXNlcjotMTotMTowOjA6ZmFsc2U6Ti9BOkRFVl8yMDE3MTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 07 Jul 2020 15:28:39
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : user
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0

* @AUTHOR : MD SHIBLI MOLLAH

SUBROUTINE GB.MBL.E.UNAUTH.CNT.DETAILS(Y.RETURN)
*PROGRAM GB.MBL.E.UNAUTH.CNT.DETAILS
 
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $USING ST.Customer
    $USING AC.AccountOpening
*$INSERT LIMIT
    $USING LI.Config
* $INSERT I_F.TELLER.ID
    $USING TT.Contract
*  $INSERT I_F.TELLER
*$INSERT I_F.FUNDS.TRANSFER
    $USING FT.Contract
    $USING LD.Contract
    $USING  PD.Contract
*  $INSERT I_F.LETTER.OF.CREDIT
    $USING LC.Contract
* $INSERT I_F.CHEQUE.ISSUE
    $USING ST.ChqIssue
* $INSERT I_F.TELLER.FINANCIAL.SERVICES
    $USING TT.TellerFinancialService
* $INSERT I_F.ACCOUNT.CREDIT.INT
    $USING IC.Config
* $INSERT I_F.ACCOUNT.DEBIT.INT
  
*  $INSERT I_F.PAYMENT.STOP
    $USING ST.ChqPaymentStop
* $INSERT I_F.DRAWINGS
* $INSERT I_F.AC.CHARGE.REQUEST
    $USING FT.AdhocChargeRequests
*  $INSERT I_F.AZ.ACCOUNT
    $USING AZ.Contract
* $INSERT I_F.AC.LOCKED.EVENTS
* $INSERT I_F.COLLATERAL.RIGHT
    $USING CO.Contract
*  $INSERT I_F.COLLATERAL
* $INSERT I_F.ACCOUNT.CLOSURE
    $USING AC.AccountClosure
*  $INSERT I_F.CHEQUE.COLLECTION
    $USING ST.ChqSubmit
* $INSERT I_F.IM.DOCUMENT.UPLOAD
    $USING IM.Foundation
* $INSERT I_F.ACCT.INACTIVE.RESET
* $INSERT I_F.STANDING.ORDER
    $USING AC.StandingOrders
*  $INSERT DEBIT.CARD.REQ
*   $INSERT I_F.AB.H.TRANS.PROFILE
* $INSERT I_F.MD.DEAL
    $USING MD.Contract
    $USING EB.DataAccess
    $INSERT I_F.MBL.TXN.PROFILE
    $USING AA.Framework
    $USING AA.TermAmount
    $USING AA.PaymentSchedule
    $USING ST.CompanyCreation
    $USING EB.SystemTables
    $USING EB.Reports


    GOSUB INIT
*
    GOSUB OPENFILES
*
    GOSUB PROCESS
RETURN

INIT:
*    ST.CompanyCreation.LoadCompany('BNK')
    Y.COMPANY = EB.SystemTables.getIdCompany()
    FN.CUS = 'F.CUSTOMER$NAU'
    F.CUS = ''
    FN.ACC = 'F.ACCOUNT$NAU'
    F.ACC = ''
    FN.LIMIT = 'F.LIMIT$NAU'
    F.LIMIT = ''
    FN.FT = 'F.FUNDS.TRANSFER$NAU'
    F.FT = ''
    FN.TID = 'F.TELLER.ID$NAU'
    F.TID = ''
    FN.TT = 'F.TELLER$NAU'
    F.TT = ''
    FN.AA.RETAIL = 'F.AA.ARRANGEMENT.ACTIVITY$NAU'
    F.AA.RETAIL = ''
    
    FN.AA.DEPOSIT = 'F.AA.ARRANGEMENT.ACTIVITY$NAU'
    F.AA.DEPOSIT = ''
    
    FN.AA.LENDING = 'F.AA.ARRANGEMENT.ACTIVITY$NAU'
    F.AA.LENDING = ''
    
    FN.LC = 'F.LETTER.OF.CREDIT$NAU'
    F.LC = ''
    FN.CHQ = 'F.CHEQUE.ISSUE$NAU'
    F.CHQ = ''
    FN.TFS = 'F.TELLER.FINANCIAL.SERVICES$NAU'
    F.TFS = ''
*  FN.ACI = 'F.ACCOUNT.CREDIT.INT$NAU' ***
*  F.ACI = ''
*  FN.ADI = 'F.ACCOUNT.DEBIT.INT$NAU' ***
* F.ADI = ''
    FN.PS = 'F.PAYMENT.STOP$NAU'
    F.PS = ''
    FN.DRAW = 'F.DRAWINGS$NAU'
    F.DRAW = ''
    FN.ACR = 'F.AC.CHARGE.REQUEST$NAU'
    F.ACR = ''
* FN.AZ = 'F.AZ.ACCOUNT$NAU' ***
* F.AZ = ''
    FN.ACLK = 'F.AC.LOCKED.EVENTS$NAU'
    F.ACLK = ''
    FN.COLLR = 'F.COLLATERAL.RIGHT$NAU'
    F.COLLR = ''
    FN.COLL = 'F.COLLATERAL$NAU'
    F.COLL = ''
    FN.AC.CLOSURE = 'F.ACCOUNT.CLOSURE$NAU'
    F.AC.CLOSURE = ''
    FN.CHQ.COLL = 'F.CHEQUE.COLLECTION$NAU'
    F.CHQ.COLL = ''
    FN.SIGN = 'F.IM.DOCUMENT.UPLOAD$NAU'
    F.SIGN = ''
    FN.SIGN.1 = 'F.IM.DOCUMENT.IMAGE'
    F.SIGN.1 = ''
    FN.INACTV.RESET = 'F.ACCT.INACTIVE.RESET$NAU'
    F.INACTV.RESET = ''
    FN.STO = 'F.STANDING.ORDER$NAU'
    F.STO = ''
    
*   FN.DR.CARD = 'F.EB.DEBIT.CARD.REQ$NAU'
*   F.DR.CARD = ''
    FN.TP = 'F.MBL.TXN.PROFILE$NAU'
    F.TP = ''

    FN.MD = 'F.MD.DEAL$NAU'
    F.MD = ''


RETURN

OPENFILES:

    EB.DataAccess.Opf(FN.CUS,F.CUS)
    EB.DataAccess.Opf(FN.ACC,F.ACC)
    EB.DataAccess.Opf(FN.LIMIT,F.LIMIT)
    EB.DataAccess.Opf(FN.FT,F.FT)
    EB.DataAccess.Opf(FN.TID,F.TID)
    EB.DataAccess.Opf(FN.TT,F.TT)
    EB.DataAccess.Opf(FN.AA.RETAIL,F.AA.RETAIL)
    EB.DataAccess.Opf(FN.AA.DEPOSIT,F.AA.DEPOSIT)
    EB.DataAccess.Opf(FN.AA.LENDING,F.AA.LENDING)
*  EB.DataAccess.Opf(FN.PD,F.PD)
    EB.DataAccess.Opf(FN.LC,F.LC)
    EB.DataAccess.Opf(FN.CHQ,F.CHQ)
    EB.DataAccess.Opf(FN.TFS,F.TFS)
* EB.DataAccess.Opf(FN.ACI,F.ACI)
*  EB.DataAccess.Opf(FN.ADI,F.ADI)
    EB.DataAccess.Opf(FN.PS,F.PS)
    EB.DataAccess.Opf(FN.DRAW,F.DRAW)
    EB.DataAccess.Opf(FN.ACR,F.ACR)
*  EB.DataAccess.Opf(FN.AZ,F.AZ)
    EB.DataAccess.Opf(FN.ACLK,F.ACLK)
    EB.DataAccess.Opf(FN.COLLR,F.COLLR)
    EB.DataAccess.Opf(FN.COLL,F.COLL)
    EB.DataAccess.Opf(FN.AC.CLOSURE,F.AC.CLOSURE)
    EB.DataAccess.Opf(FN.CHQ.COLL,F.CHQ.COLL)
    EB.DataAccess.Opf(FN.SIGN,F.SIGN)
    EB.DataAccess.Opf(FN.SIGN.1,F.SIGN.1)
    EB.DataAccess.Opf(FN.INACTV.RESET,F.INACTV.RESET)
    EB.DataAccess.Opf(FN.STO,F.STO)
* EB.DataAccess.Opf(FN.DR.CARD,F.DR.CARD)
    EB.DataAccess.Opf(FN.TP,F.TP)
    EB.DataAccess.Opf(FN.MD,F.MD)

RETURN

PROCESS:

*
    LOCATE "CO.CODE" IN EB.Reports.getEnqSelection()<2,1> SETTING CO.POS THEN
        Y.SEL.CO = EB.Reports.getEnqSelection()<4, CO.POS>
    END

    Y.JUL.DATE = ""
    CALL JULDATE(TODAY,Y.JUL.DATE)
    Y.TXN.DATE = Y.JUL.DATE[3,5]

************
    !CUS.RECORD:
************


    IF Y.SEL.CO NE '' THEN
        SEL.CMD.CUS = "SELECT ":FN.CUS:" WITH COMPANY.BOOK EQ ":Y.SEL.CO
    END ELSE
        SEL.CMD.CUS = "SELECT ":FN.CUS:" WITH COMPANY.BOOK EQ ":Y.COMPANY
    END
*
    EB.DataAccess.Readlist(SEL.CMD.CUS,SEL.CMD.LIST.CUS,'',NO.OF.REC.CUS,RET.CODE.CUS)

    LOOP
        REMOVE Y.ID FROM SEL.CMD.LIST.CUS SETTING Y.CUS.POS
    WHILE Y.ID:Y.CUS.POS

        EB.DataAccess.FRead(FN.CUS,Y.ID,CUS.REC,F.CUS,CUS.ERR)

*        Y.RECORD.STATUS = CUS.REC<EB.CUS.RECORD.STATUS>
        Y.RECORD.STATUS = CUS.REC<ST.Customer.Customer.EbCusRecordStatus>
*        Y.INPUTTER = CUS.REC<EB.CUS.INPUTTER>
        Y.INPUTTER = CUS.REC<ST.Customer.Customer.EbCusInputter>
        Y.INP.CNT = DCOUNT(Y.INPUTTER,@VM)
        Y.INPUTTER = Y.INPUTTER<1,Y.INP.CNT>
        Y.INPUTTER = FIELD(Y.INPUTTER,'_',2)
        Y.DATE.TIME = CUS.REC<ST.Customer.Customer.EbCusDateTime>

        Y.DT.TM.CNT = DCOUNT(Y.DATE.TIME,@VM)
        Y.DATE.TIME = Y.DATE.TIME<1,Y.DT.TM.CNT>
        Y.DT = Y.DATE.TIME[1,6]
        Y.DT.DISP = OCONV(ICONV(Y.DT[1,6],"D2/"),'D4')
        Y.TM.MIN = Y.DATE.TIME[7,2]
        Y.TM.SEC = Y.DATE.TIME[9,2]
        Y.INP.DT.TM = Y.DT.DISP:"  ":Y.TM.MIN:':':Y.TM.SEC

*  Y.CO.CODE = CUS.REC<EB.CUS.LOCAL.REF,87>
        Y.CO.CODE = CUS.REC<ST.Customer.Customer.EbCusCoCode>
        Y.APP = "Customer"

        GOSUB Y.DATA.ARRAY

    REPEAT

*
***********
    !AC.RECORD:
***********

    IF Y.SEL.CO NE '' THEN
        SEL.CMD.ACC = "SELECT ":FN.ACC:" WITH CO.CODE EQ ":Y.SEL.CO
    END ELSE
        SEL.CMD.ACC = "SELECT ":FN.ACC:" WITH CO.CODE EQ ":Y.COMPANY
    END

    EB.DataAccess.Readlist(SEL.CMD.ACC,SEL.CMD.LIST.ACC,'',NO.OF.REC.ACC,RET.CODE.ACC)

    LOOP
        REMOVE Y.ID FROM SEL.CMD.LIST.ACC SETTING Y.ACC.POS
    WHILE Y.ID:Y.ACC.POS


        EB.DataAccess.FRead(FN.ACC,Y.ID,AC.REC,F.ACC,ACC.ERR)

*        Y.RECORD.STATUS = AC.REC<AC.RECORD.STATUS>
        Y.RECORD.STATUS = AC.REC<AC.AccountOpening.Account.RecordStatus>
*        Y.INPUTTER = AC.REC<AC.INPUTTER>
        Y.INPUTTER = AC.REC<AC.AccountOpening.Account.Inputter>
        Y.INP.CNT = DCOUNT(Y.INPUTTER,@VM)
        Y.INPUTTER = Y.INPUTTER<1,Y.INP.CNT>
        Y.INPUTTER = FIELD(Y.INPUTTER,'_',2)
*
* Y.DATE.TIME = AC.REC<AC.DATE.TIME>
        Y.DATE.TIME = AC.REC<AC.AccountOpening.Account.DateTime>
        Y.DT.TM.CNT = DCOUNT(Y.DATE.TIME,@VM)
        Y.DATE.TIME = Y.DATE.TIME<1,Y.DT.TM.CNT>
        Y.DT = Y.DATE.TIME[1,6]
        Y.DT.DISP = OCONV(ICONV(Y.DT[1,6],"D2/"),'D4')
        Y.TM.MIN = Y.DATE.TIME[7,2]
        Y.TM.SEC = Y.DATE.TIME[9,2]
        Y.INP.DT.TM = Y.DT.DISP:"  ":Y.TM.MIN:':':Y.TM.SEC

*   Y.CO.CODE = AC.REC<AC.CO.CODE>
        Y.CO.CODE = AC.REC<AC.AccountOpening.Account.CoCode>
        Y.APP = "Account"

        GOSUB Y.DATA.ARRAY

    REPEAT


***********
    !TP.RECORD:
***********
    IF Y.SEL.CO NE '' THEN
        SEL.CMD.TP = "SELECT ":FN.TP:" WITH CO.CODE EQ ":Y.SEL.CO
    END ELSE
        SEL.CMD.TP = "SELECT ":FN.TP:" WITH CO.CODE EQ ":Y.COMPANY
    END

    EB.DataAccess.Readlist(SEL.CMD.TP,SEL.CMD.LIST.TP,'',NO.OF.REC.TP,RET.CODE.TP)

    LOOP
        REMOVE Y.ID FROM SEL.CMD.LIST.TP SETTING Y.TP.POS
    WHILE Y.ID:Y.TP.POS

        EB.DataAccess.FRead(FN.TP,Y.ID,TP.REC,F.TP,TP.ERR)

* Y.RECORD.STATUS = TP.REC<AB.TR.PROF.CURR.NO>
        Y.RECORD.STATUS = TP.REC<MB.TP.RECORD.STATUS>
*   Y.INPUTTER = TP.REC<AB.TR.PROF.DATE.TIME>
        Y.INPUTTER = TP.REC<MB.TP.INPUTTER>
        Y.INP.CNT = DCOUNT(Y.INPUTTER,@VM)
        Y.INPUTTER = Y.INPUTTER<1,Y.INP.CNT>
        Y.INPUTTER = FIELD(Y.INPUTTER,'_',2)

*  Y.DATE.TIME = TP.REC<AB.TR.PROF.AUTHORISER>
        Y.DATE.TIME = TP.REC<MB.TP.DATE.TIME>
        Y.DT.TM.CNT = DCOUNT(Y.DATE.TIME,@VM)
        Y.DATE.TIME = Y.DATE.TIME<1,Y.DT.TM.CNT>
        Y.DT = Y.DATE.TIME[1,6]
        Y.DT.DISP = OCONV(ICONV(Y.DT[1,6],"D2/"),'D4')
        Y.TM.MIN = Y.DATE.TIME[7,2]
        Y.TM.SEC = Y.DATE.TIME[9,2]
        Y.INP.DT.TM = Y.DT.DISP:"  ":Y.TM.MIN:':':Y.TM.SEC

*   Y.CO.CODE = TP.REC<AB.TR.PROF.DEPT.CODE>
        Y.CO.CODE = TP.REC<MB.TP.CO.CODE>
        Y.APP = "Transaction Profile"

        GOSUB Y.DATA.ARRAY

    REPEAT


***********
    !SIGN.CARD:
***********
    IF Y.SEL.CO NE '' THEN
        SEL.CMD.SIGN = "SELECT ":FN.SIGN:" WITH CO.CODE EQ ":Y.SEL.CO
    END ELSE
        SEL.CMD.SIGN = "SELECT ":FN.SIGN:" WITH CO.CODE EQ ":Y.COMPANY
    END

    EB.DataAccess.Readlist(SEL.CMD.SIGN,SEL.CMD.LIST.SIGN,'',NO.OF.REC.SIGN,RET.CODE.SIGN)
    
    LOOP
        REMOVE Y.ID FROM SEL.CMD.LIST.SIGN SETTING Y.SIGN.POS
    WHILE Y.ID:Y.SIGN.POS

        EB.DataAccess.FRead(FN.SIGN.1, Y.ID, Y.REC.SIGN, F.SIGN.1, ERR.SIGN)
*IMAGE*************************
        Y.RECORD.STATUS = "INAU"
*****CHANGE
        Y.INPUTTER = Y.REC.SIGN<IM.Foundation.DocumentImage.DocInputter>
        Y.INP.CNT = DCOUNT(Y.INPUTTER,@VM)
        Y.INPUTTER = Y.INPUTTER<1,Y.INP.CNT>
        Y.INPUTTER = FIELD(Y.INPUTTER,'_',2)

        Y.DATE.TIME = Y.REC.SIGN<IM.Foundation.DocumentImage.DocDateTime>
        Y.DT.TM.CNT = DCOUNT(Y.DATE.TIME,@VM)
        Y.DATE.TIME = Y.DATE.TIME<1,Y.DT.TM.CNT>
        Y.DT = Y.DATE.TIME[1,6]
        Y.DT.DISP = OCONV(ICONV(Y.DT[1,6],"D2/"),'D4')
        Y.TM.MIN = Y.DATE.TIME[7,2]
        Y.TM.SEC = Y.DATE.TIME[9,2]
        Y.INP.DT.TM = Y.DT.DISP:"  ":Y.TM.MIN:':':Y.TM.SEC

        Y.CO.CODE = Y.REC.SIGN<IM.Foundation.DocumentImage.DocCoCode>
        Y.APP = "Signature CARD"

        GOSUB Y.DATA.ARRAY

    REPEAT

****************
    !AC.CLSR.RECORD:
****************
    IF Y.SEL.CO NE '' THEN
        SEL.CMD.AC.CLOSURE = "SELECT ":FN.AC.CLOSURE:" WITH CO.CODE EQ ":Y.SEL.CO
    END ELSE
        SEL.CMD.AC.CLOSURE = "SELECT ":FN.AC.CLOSURE:" WITH CO.CODE EQ ":Y.COMPANY
    END

    EB.DataAccess.Readlist(SEL.CMD.AC.CLOSURE,SEL.CMD.LIST.AC.CLOSURE,'',NO.OF.REC.AC.CLOSURE,RET.CODE.AC.CLOSURE)

    LOOP
        REMOVE Y.ID FROM SEL.CMD.LIST.AC.CLOSURE SETTING Y.AC.CLSR.POS
    WHILE Y.ID:Y.AC.CLSR.POS

        EB.DataAccess.FRead(FN.AC.CLOSURE,Y.ID,AC.CLSR.REC,F.AC.CLOSURE,AC.CLSR.ERR)

* Y.TXN.AMT = AC.CLSR.REC<AC.ACL.TOTAL.ACC.AMT>
        Y.TXN.AMT = AC.CLSR.REC<AC.AccountClosure.AccountClosure.AclTotalAccAmt>
*  Y.RECORD.STATUS = AC.CLSR.REC<AC.ACL.RECORD.STATUS>
        Y.RECORD.STATUS = AC.CLSR.REC<AC.AccountClosure.AccountClosure.AclRecordStatus>
*  Y.INPUTTER = AC.CLSR.REC<AC.ACL.INPUTTER>
        Y.INPUTTER = AC.CLSR.REC<AC.AccountClosure.AccountClosure.AclInputter>
        Y.INP.CNT = DCOUNT(Y.INPUTTER,@VM)
        Y.INPUTTER = Y.INPUTTER<1,Y.INP.CNT>
        Y.INPUTTER = FIELD(Y.INPUTTER,'_',2)

*  Y.DATE.TIME = AC.CLSR.REC<AC.ACL.DATE.TIME>
        Y.DATE.TIME = AC.CLSR.REC<AC.AccountClosure.AccountClosure.AclDateTime>
        Y.DT.TM.CNT = DCOUNT(Y.DATE.TIME,@VM)
        Y.DATE.TIME = Y.DATE.TIME<1,Y.DT.TM.CNT>
        Y.DT = Y.DATE.TIME[1,6]
        Y.DT.DISP = OCONV(ICONV(Y.DT[1,6],"D2/"),'D4')
        Y.TM.MIN = Y.DATE.TIME[7,2]
        Y.TM.SEC = Y.DATE.TIME[9,2]
        Y.INP.DT.TM = Y.DT.DISP:"  ":Y.TM.MIN:':':Y.TM.SEC

* Y.CO.CODE = AC.CLSR.REC<AC.ACL.CO.CODE>
        Y.CO.CODE = AC.CLSR.REC<AC.AccountClosure.AccountClosure.AclCoCode>
        Y.APP = "Account Closure"

        GOSUB Y.DATA.ARRAY

    REPEAT

***********************
    !INACTIVE.RESET.RECORD:
***********************

    IF Y.SEL.CO NE '' THEN
        SEL.CMD.INACTV = "SELECT ":FN.INACTV.RESET:" WITH CO.CODE EQ ":Y.SEL.CO
    END ELSE
        SEL.CMD.INACTV = "SELECT ":FN.INACTV.RESET:" WITH CO.CODE EQ ":Y.COMPANY
    END

    EB.DataAccess.Readlist(SEL.CMD.INACTV,SEL.CMD.LIST.INACTV,'',NO.OF.REC.INACTV,RET.CODE.INACTV)

    LOOP
        REMOVE Y.ID FROM SEL.CMD.LIST.INACTV SETTING Y.AC.INACTV.POS
    WHILE Y.ID:Y.AC.INACTV.POS

        EB.DataAccess.FRead(FN.INACTV.RESET,Y.ID,INACTV.REC,F.INACTV.RESET,INACTV.ERR)

*  Y.RECORD.STATUS =  INACTV.REC<AC.IR.RECORD.STATUS>
        Y.RECORD.STATUS =  INACTV.REC<AC.AccountOpening.AcctInactiveReset.IrRecordStatus>
* Y.INPUTTER = INACTV.REC<AC.IR.INPUTTER>
        Y.INPUTTER = INACTV.REC<AC.AccountOpening.AcctInactiveReset.IrInputter>
        Y.INP.CNT = DCOUNT(Y.INPUTTER,@VM)
        Y.INPUTTER = Y.INPUTTER<1,Y.INP.CNT>
        Y.INPUTTER = FIELD(Y.INPUTTER,'_',2)

*    Y.DATE.TIME = INACTV.REC<AC.IR.DATE.TIME>
        Y.DATE.TIME = INACTV.REC<AC.AccountOpening.AcctInactiveReset.IrDateTime>
        Y.DT.TM.CNT = DCOUNT(Y.DATE.TIME,@VM)
        Y.DATE.TIME = Y.DATE.TIME<1,Y.DT.TM.CNT>
        Y.DT = Y.DATE.TIME[1,6]
        Y.DT.DISP = OCONV(ICONV(Y.DT[1,6],"D2/"),'D4')
        Y.TM.MIN = Y.DATE.TIME[7,2]
        Y.TM.SEC = Y.DATE.TIME[9,2]
        Y.INP.DT.TM = Y.DT.DISP:"  ":Y.TM.MIN:':':Y.TM.SEC

*  Y.CO.CODE = INACTV.REC<AC.IR.CO.CODE>
        Y.CO.CODE = INACTV.REC<AC.AccountOpening.AcctInactiveReset.IrCoCode>
        Y.APP = "Inactive Account Reset"

        GOSUB Y.DATA.ARRAY

    REPEAT

********************
    !FUNDS.BLOCK.RECORD:
********************
    IF Y.SEL.CO NE '' THEN
        SEL.CMD.ACLK = "SELECT ":FN.ACLK:" WITH CO.CODE EQ ":Y.SEL.CO
    END ELSE
        SEL.CMD.ACLK = "SELECT ":FN.ACLK:" WITH CO.CODE EQ ":Y.COMPANY
    END

    EB.DataAccess.Readlist(SEL.CMD.ACLK,SEL.CMD.LIST.ACLK,'',NO.OF.REC.ACLK,RET.CODE.ACLK)

    LOOP

        REMOVE Y.ID FROM SEL.CMD.LIST.ACLK SETTING Y.ACLK.POS
    WHILE Y.ID:Y.ACLK.POS

        EB.DataAccess.FRead(FN.ACLK,Y.ID,ACLK.REC,F.ACLK,ACLK.ERR)

*   Y.TXN.AMT = ACLK.REC<AC.LCK.LOCKED.AMOUNT>
        Y.TXN.AMT = ACLK.REC<AC.AccountOpening.LockedEvents.LckLockedAmount>
* Y.RECORD.STATUS = ACLK.REC<AC.LCK.RECORD.STATUS>
        Y.RECORD.STATUS = ACLK.REC<AC.AccountOpening.LockedEvents.LckRecordStatus>
*  Y.INPUTTER = ACLK.REC< AC.LCK.INPUTTER>
        Y.INPUTTER = ACLK.REC<AC.AccountOpening.LockedEvents.LckInputter>
        Y.INP.CNT = DCOUNT(Y.INPUTTER,@VM)
        Y.INPUTTER = Y.INPUTTER<1,Y.INP.CNT>
        Y.INPUTTER = FIELD(Y.INPUTTER,'_',2)

*  Y.DATE.TIME = ACLK.REC<AC.LCK.DATE.TIME>
        Y.DATE.TIME = ACLK.REC<AC.AccountOpening.LockedEvents.LckDateTime>
        Y.DT.TM.CNT = DCOUNT(Y.DATE.TIME,@VM)
        Y.DATE.TIME = Y.DATE.TIME<1,Y.DT.TM.CNT>
        Y.DT = Y.DATE.TIME[1,6]
        Y.DT.DISP = OCONV(ICONV(Y.DT[1,6],"D2/"),'D4')
        Y.TM.MIN = Y.DATE.TIME[7,2]
        Y.TM.SEC = Y.DATE.TIME[9,2]
        Y.INP.DT.TM = Y.DT.DISP:"  ":Y.TM.MIN:':':Y.TM.SEC

* Y.CO.CODE = ACLK.REC<AC.LCK.CO.CODE>
        Y.CO.CODE = ACLK.REC<AC.AccountOpening.LockedEvents.LckCoCode>
        Y.APP = "Fund Block of Account (ACLK)"

        GOSUB Y.DATA.ARRAY

    REPEAT

************
    !STO.RECORD:
************

    IF Y.SEL.CO NE '' THEN
        SEL.CMD.STO = "SELECT ":FN.STO:" WITH CO.CODE EQ ":Y.SEL.CO
    END ELSE
        SEL.CMD.STO = "SELECT ":FN.STO:" WITH CO.CODE EQ ":Y.COMPANY
    END
    EB.DataAccess.Readlist(SEL.CMD.STO,SEL.CMD.LIST.STO,'',NO.OF.REC.STO,RET.CODE.STO)
 
    LOOP
        REMOVE Y.ID FROM SEL.CMD.LIST.STO SETTING Y.STO.POS
    WHILE Y.ID:Y.STO.POS

        EB.DataAccess.FRead(FN.STO,Y.ID,STO.REC,F.STO,STO.ERR)

*    Y.TXN.AMT = STO.REC<STO.CURRENT.AMOUNT.BAL>
        Y.TXN.AMT = STO.REC<AC.StandingOrders.StandingOrder.StoCurrentAmountBal>
*   Y.RECORD.STATUS = STO.REC<STO.RECORD.STATUS>
        Y.RECORD.STATUS = STO.REC<AC.StandingOrders.StandingOrder.StoRecordStatus>
        Y.INPUTTER = STO.REC<AC.StandingOrders.StandingOrder.StoInputter>
        Y.INP.CNT = DCOUNT(Y.INPUTTER,@VM)
        Y.INPUTTER = Y.INPUTTER<1,Y.INP.CNT>
        Y.INPUTTER = FIELD(Y.INPUTTER,'_',2)

        Y.DATE.TIME = STO.REC<AC.StandingOrders.StandingOrder.StoDateTime>
        Y.DT.TM.CNT = DCOUNT(Y.DATE.TIME,@VM)
        Y.DATE.TIME = Y.DATE.TIME<1,Y.DT.TM.CNT>
        Y.DT = Y.DATE.TIME[1,6]
        Y.DT.DISP = OCONV(ICONV(Y.DT[1,6],"D2/"),'D4')
        Y.TM.MIN = Y.DATE.TIME[7,2]
        Y.TM.SEC = Y.DATE.TIME[9,2]
        Y.INP.DT.TM = Y.DT.DISP:"  ":Y.TM.MIN:':':Y.TM.SEC
*
        Y.CO.CODE = STO.REC<AC.StandingOrders.StandingOrder.StoCoCode>
        Y.APP = "Standing Order (STO)"

        GOSUB Y.DATA.ARRAY

    REPEAT

***************
    !CHEQUE.RECORD:
**************
    IF Y.SEL.CO NE '' THEN
        SEL.CMD.CHQ = "SELECT ":FN.CHQ:" WITH CO.CODE EQ ":Y.SEL.CO
    END ELSE
        SEL.CMD.CHQ = "SELECT ":FN.CHQ:" WITH CO.CODE EQ ":Y.COMPANY
    END

    EB.DataAccess.Readlist(SEL.CMD.CHQ,SEL.CMD.LIST.CHQ,'',NO.OF.REC.CHQ,RET.CODE.CHQ)

    LOOP
        REMOVE Y.ID FROM SEL.CMD.LIST.CHQ SETTING Y.CHQ.POS
    WHILE Y.ID:Y.CHQ.POS

        EB.DataAccess.FRead(FN.CHQ,Y.ID,CHQ.REC,F.CHQ,CHQ.ERR)

* Y.TXN.AMT = CHQ.REC<CHEQUE.IS.CHG.AMOUNT>
        Y.TXN.AMT = CHQ.REC<ST.ChqIssue.ChequeIssue.ChequeIsChgAmount>
        Y.RECORD.STATUS = CHQ.REC<ST.ChqIssue.ChequeIssue.ChequeIsRecordStatus>
        Y.INPUTTER = CHQ.REC<ST.ChqIssue.ChequeIssue.ChequeIsInputter>
        Y.INP.CNT = DCOUNT(Y.INPUTTER,@VM)
        Y.INPUTTER = Y.INPUTTER<1,Y.INP.CNT>
        Y.INPUTTER = FIELD(Y.INPUTTER,'_',2)
*
        Y.DATE.TIME = CHQ.REC<ST.ChqIssue.ChequeIssue.ChequeIsDateTime>
        Y.DT.TM.CNT = DCOUNT(Y.DATE.TIME,@VM)
        Y.DATE.TIME = Y.DATE.TIME<1,Y.DT.TM.CNT>
        Y.DT = Y.DATE.TIME[1,6]
        Y.DT.DISP = OCONV(ICONV(Y.DT[1,6],"D2/"),'D4')
        Y.TM.MIN = Y.DATE.TIME[7,2]
        Y.TM.SEC = Y.DATE.TIME[9,2]
        Y.INP.DT.TM = Y.DT.DISP:"  ":Y.TM.MIN:':':Y.TM.SEC

        Y.CO.CODE = CHQ.REC<ST.ChqIssue.ChequeIssue.ChequeIsCoCode>
        Y.APP = "Cheque Issue & Reverse"

        GOSUB Y.DATA.ARRAY

    REPEAT

******************
    !PAYMENT.STOP.REC:
******************
    IF Y.SEL.CO NE '' THEN
        SEL.CMD.PS = "SELECT ":FN.PS:" WITH CO.CODE EQ ":Y.SEL.CO
    END ELSE
        SEL.CMD.PS = "SELECT ":FN.PS:" WITH CO.CODE EQ ":Y.COMPANY
    END
    EB.DataAccess.Readlist(SEL.CMD.PS,SEL.CMD.LIST.PS,'',NO.OF.REC.PS,RET.CODE.PS)

    LOOP
        REMOVE Y.ID FROM SEL.CMD.LIST.PS SETTING Y.PS.POS
    WHILE Y.ID:Y.PS.POS

        EB.DataAccess.FRead(FN.PS,Y.ID,PS.REC,F.PS,PS.ERR)


*Y.TXN.AMT = PS.REC<AC.PAY.CHG.AMOUNT>
        Y.TXN.AMT = PS.REC<ST.ChqPaymentStop.PaymentStop.AcPayChgAmount>
        Y.RECORD.STATUS = PS.REC<ST.ChqPaymentStop.PaymentStop.AcPayRecordStatus>
        Y.INPUTTER = PS.REC<ST.ChqPaymentStop.PaymentStop.AcPayInputter>
        Y.INP.CNT = DCOUNT(Y.INPUTTER,@VM)
        Y.INPUTTER = Y.INPUTTER<1,Y.INP.CNT>
        Y.INPUTTER = FIELD(Y.INPUTTER,'_',2)
*
        Y.DATE.TIME = PS.REC<ST.ChqPaymentStop.PaymentStop.AcPayDateTime>
        Y.DT.TM.CNT = DCOUNT(Y.DATE.TIME,@VM)
        Y.DATE.TIME = Y.DATE.TIME<1,Y.DT.TM.CNT>
        Y.DT = Y.DATE.TIME[1,6]
        Y.DT.DISP = OCONV(ICONV(Y.DT[1,6],"D2/"),'D4')
        Y.TM.MIN = Y.DATE.TIME[7,2]
        Y.TM.SEC = Y.DATE.TIME[9,2]
        Y.INP.DT.TM = Y.DT.DISP:"  ":Y.TM.MIN:':':Y.TM.SEC

        Y.CO.CODE = PS.REC<ST.ChqPaymentStop.PaymentStop.AcPayCoCode>
        Y.APP = "Payment Stop of Cheque"

        GOSUB Y.DATA.ARRAY

    REPEAT

*******************
    !TID.CHANGE.RECORD:
*******************

    IF Y.SEL.CO NE '' THEN
        SEL.CMD.TID = "SELECT ":FN.TID:" WITH CO.CODE EQ ":Y.SEL.CO
    END ELSE
        SEL.CMD.TID = "SELECT ":FN.TID:" WITH CO.CODE EQ ":Y.COMPANY
    END
    EB.DataAccess.Readlist(SEL.CMD.TID,SEL.CMD.LIST.TID,'',NO.OF.REC.TID,RET.CODE.TID)

    LOOP
        REMOVE Y.ID FROM SEL.CMD.LIST.TID SETTING Y.TID.POS
    WHILE Y.ID:Y.TID.POS

        EB.DataAccess.FRead(FN.TID,Y.ID,TID.REC,F.TID,TID.ERR)

*  Y.RECORD.STATUS = TID.REC<TT.TID.RECORD.STATUS>
        Y.RECORD.STATUS = TID.REC<TT.Contract.TellerId.TidRecordStatus>
        Y.INPUTTER = TID.REC<TT.Contract.TellerId.TidInputter>
        Y.INP.CNT = DCOUNT(Y.INPUTTER,@VM)
        Y.INPUTTER = Y.INPUTTER<1,Y.INP.CNT>
        Y.INPUTTER = FIELD(Y.INPUTTER,'_',2)

        Y.DATE.TIME = TID.REC<TT.Contract.TellerId.TidDateTime>
        Y.DT.TM.CNT = DCOUNT(Y.DATE.TIME,@VM)
        Y.DATE.TIME = Y.DATE.TIME<1,Y.DT.TM.CNT>
        Y.DT = Y.DATE.TIME[1,6]
        Y.DT.DISP = OCONV(ICONV(Y.DT[1,6],"D2/"),'D4')
        Y.TM.MIN = Y.DATE.TIME[7,2]
        Y.TM.SEC = Y.DATE.TIME[9,2]
        Y.INP.DT.TM = Y.DT.DISP:"  ":Y.TM.MIN:':':Y.TM.SEC

        Y.CO.CODE = TID.REC<TT.Contract.TellerId.TidCoCode>
        Y.APP = "Head Teller ID Change"

        GOSUB Y.DATA.ARRAY

    REPEAT

***********
    !TT.RECORD:
***********

*
    IF Y.SEL.CO NE '' THEN
        SEL.CMD.TT = "SELECT ":FN.TT:" WITH CO.CODE EQ ":Y.SEL.CO
    END ELSE
        SEL.CMD.TT = "SELECT ":FN.TT:" WITH CO.CODE EQ ":Y.COMPANY
    END

    EB.DataAccess.Readlist(SEL.CMD.TT,SEL.CMD.LIST.TT,'',NO.OF.REC.TT,RET.CODE.TT)


    LOOP
        REMOVE Y.ID FROM SEL.CMD.LIST.TT SETTING Y.TT.POS
    WHILE Y.ID:Y.TT.POS

        EB.DataAccess.FRead(FN.TT,Y.ID,TT.REC,F.TT,TT.ERR)

*Y.TXN.AMT = TT.REC<TT.TE.AMOUNT.LOCAL.1>
        Y.TXN.AMT = TT.REC<TT.Contract.Teller.TeAmountLocalOne>
        Y.RECORD.STATUS = TT.REC<TT.Contract.Teller.TeRecordStatus>
        Y.INPUTTER = TT.REC<TT.Contract.Teller.TeInputter>
        Y.INP.CNT = DCOUNT(Y.INPUTTER,@VM)
        Y.INPUTTER = Y.INPUTTER<1,Y.INP.CNT>
        Y.INPUTTER = FIELD(Y.INPUTTER,'_',2)

        Y.DATE.TIME = TT.REC<TT.Contract.Teller.TeDateTime>
        Y.DT.TM.CNT = DCOUNT(Y.DATE.TIME,@VM)
        Y.DATE.TIME = Y.DATE.TIME<1,Y.DT.TM.CNT>
        Y.DT = Y.DATE.TIME[1,6]
        Y.DT.DISP = OCONV(ICONV(Y.DT[1,6],"D2/"),'D4')
        Y.TM.MIN = Y.DATE.TIME[7,2]
        Y.TM.SEC = Y.DATE.TIME[9,2]
        Y.INP.DT.TM = Y.DT.DISP:"  ":Y.TM.MIN:':':Y.TM.SEC

        Y.CO.CODE = TT.REC<TT.Contract.Teller.TeCoCode>
        Y.APP = "Teller (Cash & CLG)"

        GOSUB Y.DATA.ARRAY

    REPEAT

***********
    !FT.RECORD:
***********

    IF Y.SEL.CO NE '' THEN
        SEL.CMD.FT = "SELECT ":FN.FT:" WITH (TRANSACTION.TYPE NE 'ACIW' AND TRANSACTION.TYPE NE 'ACOW') AND CO.CODE EQ ":Y.SEL.CO
    END ELSE
        SEL.CMD.FT = "SELECT ":FN.FT:" WITH (TRANSACTION.TYPE NE 'ACIW' AND TRANSACTION.TYPE NE 'ACOW') AND CO.CODE EQ ":Y.COMPANY
    END

    EB.DataAccess.Readlist(SEL.CMD.FT,SEL.CMD.LIST.FT,'',NO.OF.REC.FT,RET.CODE.FT)

    LOOP
        REMOVE Y.ID FROM SEL.CMD.LIST.FT SETTING Y.FT.POS
    WHILE Y.ID:Y.FT.POS

        EB.DataAccess.FRead(FN.FT,Y.ID,FT.REC,F.FT,FT.ERR)

* Y.TXN.AMT = FT.REC<FT.LOC.AMT.DEBITED>
        Y.TXN.AMT = FT.REC<FT.Contract.FundsTransfer.LocAmtDebited>
        Y.RECORD.STATUS = FT.REC<FT.Contract.FundsTransfer.RecordStatus>
        Y.INPUTTER = FT.REC<FT.Contract.FundsTransfer.Inputter>
        Y.INP.CNT = DCOUNT(Y.INPUTTER,@VM)
        Y.INPUTTER = Y.INPUTTER<1,Y.INP.CNT>
        Y.INPUTTER = FIELD(Y.INPUTTER,'_',2)

        Y.DATE.TIME = FT.REC<FT.Contract.FundsTransfer.DateTime>
        Y.DT.TM.CNT = DCOUNT(Y.DATE.TIME,@VM)
        Y.DATE.TIME = Y.DATE.TIME<1,Y.DT.TM.CNT>
        Y.DT = Y.DATE.TIME[1,6]
        Y.DT.DISP = OCONV(ICONV(Y.DT[1,6],"D2/"),'D4')
        Y.TM.MIN = Y.DATE.TIME[7,2]
        Y.TM.SEC = Y.DATE.TIME[9,2]
        Y.INP.DT.TM = Y.DT.DISP:"  ":Y.TM.MIN:':':Y.TM.SEC

        Y.CO.CODE = FT.REC<FT.Contract.FundsTransfer.CoCode>
        Y.APP = "Funds Transfer"

        GOSUB Y.DATA.ARRAY

    REPEAT


**********
    !CHQ.COLL:
**********
    IF Y.SEL.CO NE '' THEN
        SEL.CMD.FT = "SELECT ":FN.FT:" WITH TRANSACTION.TYPE EQ 'ACIW' 'ACOW' AND CO.CODE EQ ":Y.SEL.CO
    END ELSE
        SEL.CMD.FT = "SELECT ":FN.FT:" WITH TRANSACTION.TYPE EQ 'ACIW' 'ACOW' AND CO.CODE EQ ":Y.COMPANY
    END

    EB.DataAccess.Readlist(SEL.CMD.FT,SEL.CMD.LIST.FT.1,'',NO.OF.REC.FT.1,RET.CODE.FT)

    LOOP
        REMOVE Y.ID FROM SEL.CMD.LIST.FT.1 SETTING Y.FT.POS.1
    WHILE Y.ID:Y.FT.POS.1

        EB.DataAccess.FRead(FN.FT,Y.ID,FT.REC,F.FT,FT.ERR)

* Y.TXN.AMT = FT.REC<FT.LOC.AMT.DEBITED>
        Y.TXN.AMT = FT.REC<FT.Contract.FundsTransfer.LocAmtDebited>
        Y.RECORD.STATUS = FT.REC<FT.Contract.FundsTransfer.RecordStatus>
        Y.INPUTTER = FT.REC<FT.Contract.FundsTransfer.Inputter>
        Y.INP.CNT = DCOUNT(Y.INPUTTER,@VM)
        Y.INPUTTER = Y.INPUTTER<1,Y.INP.CNT>
        Y.INPUTTER = FIELD(Y.INPUTTER,'_',2)

        Y.DATE.TIME = FT.REC<FT.Contract.FundsTransfer.DateTime>
        Y.DT.TM.CNT = DCOUNT(Y.DATE.TIME,@VM)
        Y.DATE.TIME = Y.DATE.TIME<1,Y.DT.TM.CNT>
        Y.DT = Y.DATE.TIME[1,6]
        Y.DT.DISP = OCONV(ICONV(Y.DT[1,6],"D2/"),'D4')
        Y.TM.MIN = Y.DATE.TIME[7,2]
        Y.TM.SEC = Y.DATE.TIME[9,2]
        Y.INP.DT.TM = Y.DT.DISP:"  ":Y.TM.MIN:':':Y.TM.SEC

        Y.CO.CODE = FT.REC<FT.Contract.FundsTransfer.CoCode>
        Y.APP = "Cheque Clearing FT"

        GOSUB Y.DATA.ARRAY

    REPEAT

*************************************************************
    
    IF Y.SEL.CO NE '' THEN
        SEL.CMD.CHQ.COLL = "SELECT ":FN.CHQ.COLL:" WITH CO.CODE EQ ":Y.SEL.CO
    END ELSE
        SEL.CMD.CHQ.COLL = "SELECT ":FN.CHQ.COLL:" WITH CO.CODE EQ ":Y.COMPANY
    END
    EB.DataAccess.Readlist(SEL.CMD.CHQ.COLL,SEL.CMD.LIST.CHQ.COLL,'',NO.OF.REC.CHQ.COLL,RET.CODE.CHQ.COLL)

    LOOP
        REMOVE Y.ID FROM SEL.CMD.LIST.CHQ.COLL SETTING Y.CHQ.COLL.POS
    WHILE Y.ID:Y.CHQ.COLL.POS

        EB.DataAccess.FRead(FN.CHQ.COLL,Y.ID,CHQ.COLL.REC,F.CHQ.COLL,CHQ.COLL.ERR)

        Y.TXN.AMT = CHQ.COLL.REC<ST.ChqSubmit.ChequeCollection.ChqColAmount>
        Y.RECORD.STATUS = CHQ.COLL.REC<ST.ChqSubmit.ChequeCollection.ChqColRecordStatus>
        Y.INPUTTER =  CHQ.COLL.REC<ST.ChqSubmit.ChequeCollection.ChqColInputter>
        Y.INP.CNT = DCOUNT(Y.INPUTTER,@VM)
        Y.INPUTTER = Y.INPUTTER<1,Y.INP.CNT>
        Y.INPUTTER = FIELD(Y.INPUTTER,'_',2)

        Y.DATE.TIME = CHQ.COLL.REC<ST.ChqSubmit.ChequeCollection.ChqColDateTime>
        Y.DT.TM.CNT = DCOUNT(Y.DATE.TIME,@VM)
        Y.DATE.TIME = Y.DATE.TIME<1,Y.DT.TM.CNT>
        Y.DT = Y.DATE.TIME[1,6]
        Y.DT.DISP = OCONV(ICONV(Y.DT[1,6],"D2/"),'D4')
        Y.TM.MIN = Y.DATE.TIME[7,2]
        Y.TM.SEC = Y.DATE.TIME[9,2]
        Y.INP.DT.TM = Y.DT.DISP:"  ":Y.TM.MIN:':':Y.TM.SEC

        Y.CO.CODE = CHQ.COLL.REC<ST.ChqSubmit.ChequeCollection.ChqColCoCode>
        Y.APP = "Cheque Collection"

        GOSUB Y.DATA.ARRAY

    REPEAT



*******************
    !AC.CHG.REQ.RECORD:
*******************
    IF Y.SEL.CO NE '' THEN
        SEL.CMD.ACR = "SELECT ":FN.ACR:" WITH CO.CODE EQ ":Y.SEL.CO
    END ELSE
        SEL.CMD.ACR = "SELECT ":FN.ACR:" WITH CO.CODE EQ ":Y.COMPANY
    END
    EB.DataAccess.Readlist(SEL.CMD.ACR,SEL.CMD.LIST.ACR,'',NO.OF.REC.ACR,RET.CODE.ACR)


    LOOP
        REMOVE Y.ID FROM SEL.CMD.LIST.ACR SETTING Y.ACR.POS
    WHILE Y.ID:Y.ACR.POS

        EB.DataAccess.FRead(FN.ACR,Y.ID,ACR.REC,F.ACR,ACR.ERR)

*  Y.TXN.AMT = ACR.REC<CHG.TOTAL.CHG.AMT>
        Y.TXN.AMT = ACR.REC<FT.AdhocChargeRequests.AcChargeRequest.ChgTotalChgAmt>
        Y.RECORD.STATUS = ACR.REC<FT.AdhocChargeRequests.AcChargeRequest.ChgRecordStatus>
        Y.INPUTTER = ACR.REC<FT.AdhocChargeRequests.AcChargeRequest.ChgInputter>
        Y.INP.CNT = DCOUNT(Y.INPUTTER,@VM)
        Y.INPUTTER = Y.INPUTTER<1,Y.INP.CNT>
        Y.INPUTTER = FIELD(Y.INPUTTER,'_',2)

        Y.DATE.TIME = ACR.REC<FT.AdhocChargeRequests.AcChargeRequest.ChgDateTime>
        Y.DT.TM.CNT = DCOUNT(Y.DATE.TIME,@VM)
        Y.DATE.TIME = Y.DATE.TIME<1,Y.DT.TM.CNT>
        Y.DT = Y.DATE.TIME[1,6]
        Y.DT.DISP = OCONV(ICONV(Y.DT[1,6],"D2/"),'D4')
        Y.TM.MIN = Y.DATE.TIME[7,2]
        Y.TM.SEC = Y.DATE.TIME[9,2]
        Y.INP.DT.TM = Y.DT.DISP:"  ":Y.TM.MIN:':':Y.TM.SEC

        Y.CO.CODE = ACR.REC<FT.AdhocChargeRequests.AcChargeRequest.ChgCoCode>
        Y.APP = "Account Charge Request (CHG)"

        GOSUB Y.DATA.ARRAY

    REPEAT


************
    !TFS.RECORD:
************

    IF Y.SEL.CO NE '' THEN
        SEL.CMD.TFS = "SELECT ":FN.TFS:" WITH CO.CODE EQ ":Y.SEL.CO
    END ELSE
        SEL.CMD.TFS = "SELECT ":FN.TFS:" WITH CO.CODE EQ ":Y.COMPANY
    END

    EB.DataAccess.Readlist(SEL.CMD.TFS,SEL.CMD.LIST.TFS,'',NO.OF.REC.TFS,RET.CODE.TFS)

    LOOP
        REMOVE Y.ID FROM SEL.CMD.LIST.TFS SETTING Y.TFS.POS
    WHILE Y.ID:Y.TFS.POS

        EB.DataAccess.FRead(FN.TFS,Y.ID,TFS.REC,F.TFS,TFS.ERR)

*  Y.TXN.AMT = TFS.REC<TFS.AMOUNT>
        Y.TXN.AMT = TFS.REC<TT.TellerFinancialService.TellerFinancialServices.TfsAmount>
        Y.RECORD.STATUS = TFS.REC<TT.TellerFinancialService.TellerFinancialServices.TfsRecordStatus>
        Y.INPUTTER = TFS.REC<TT.TellerFinancialService.TellerFinancialServices.TfsInputter>
        Y.INP.CNT = DCOUNT(Y.INPUTTER,@VM)
        Y.INPUTTER = Y.INPUTTER<1,Y.INP.CNT>
        Y.INPUTTER = FIELD(Y.INPUTTER,'_',2)

        Y.DATE.TIME = TFS.REC<TT.TellerFinancialService.TellerFinancialServices.TfsDateTime>
        Y.DT.TM.CNT = DCOUNT(Y.DATE.TIME,@VM)
        Y.DATE.TIME = Y.DATE.TIME<1,Y.DT.TM.CNT>
        Y.DT = Y.DATE.TIME[1,6]
        Y.DT.DISP = OCONV(ICONV(Y.DT[1,6],"D2/"),'D4')
        Y.TM.MIN = Y.DATE.TIME[7,2]
        Y.TM.SEC = Y.DATE.TIME[9,2]
        Y.INP.DT.TM = Y.DT.DISP:"  ":Y.TM.MIN:':':Y.TM.SEC

        Y.CO.CODE = TFS.REC<TT.TellerFinancialService.TellerFinancialServices.TfsCoCode>
        Y.APP = "Teller Financial Services (TFS)"

        GOSUB Y.DATA.ARRAY

    REPEAT


**************
    !LIMIT.RECORD:
**************

    IF Y.SEL.CO NE '' THEN
        SEL.CMD.LIMIT = "SELECT ":FN.LIMIT:" WITH CO.CODE EQ ":Y.SEL.CO
    END ELSE
        SEL.CMD.LIMIT = "SELECT ":FN.LIMIT:" WITH CO.CODE EQ ":Y.COMPANY
    END
    EB.DataAccess.Readlist(SEL.CMD.LIMIT,SEL.CMD.LIST.LIMIT,'',NO.OF.REC.LIMIT,RET.CODE.LIMIT)

    LOOP
        REMOVE Y.ID FROM SEL.CMD.LIST.LIMIT SETTING Y.LIMIT.POS
    WHILE Y.ID:Y.LIMIT.POS

        EB.DataAccess.FRead(FN.LIMIT,Y.ID,LIMIT.REC,F.LIMIT,LIMIT.ERR)

* Y.TXN.AMT = LIMIT.REC<LI.INTERNAL.AMOUNT>
        Y.TXN.AMT = LIMIT.REC<LI.Config.Limit.InternalAmount>
        Y.RECORD.STATUS = LIMIT.REC<LI.Config.Limit.RecordStatus>
        Y.INPUTTER = LIMIT.REC<LI.Config.Limit.Inputter>
        Y.INP.CNT = DCOUNT(Y.INPUTTER,@VM)
        Y.INPUTTER = Y.INPUTTER<1,Y.INP.CNT>
        Y.INPUTTER = FIELD(Y.INPUTTER,'_',2)

        Y.DATE.TIME = LIMIT.REC<LI.Config.Limit.DateTime>
        Y.DT.TM.CNT = DCOUNT(Y.DATE.TIME,@VM)
        Y.DATE.TIME = Y.DATE.TIME<1,Y.DT.TM.CNT>
        Y.DT = Y.DATE.TIME[1,6]
        Y.DT.DISP = OCONV(ICONV(Y.DT[1,6],"D2/"),'D4')
        Y.TM.MIN = Y.DATE.TIME[7,2]
        Y.TM.SEC = Y.DATE.TIME[9,2]
        Y.INP.DT.TM = Y.DT.DISP:"  ":Y.TM.MIN:':':Y.TM.SEC

        Y.CO.CODE = LIMIT.REC<LI.Config.Limit.CoCode>
        Y.APP = "Limit"

        GOSUB Y.DATA.ARRAY

    REPEAT


*******************
    !COLL.RIGHT.RECORD:
*******************

    IF Y.SEL.CO NE '' THEN
        SEL.CMD.COLLR = "SELECT ":FN.COLLR:" WITH CO.CODE EQ ":Y.SEL.CO
    END ELSE
        SEL.CMD.COLLR = "SELECT ":FN.COLLR:" WITH CO.CODE EQ ":Y.COMPANY
    END
    EB.DataAccess.Readlist(SEL.CMD.COLLR,SEL.CMD.LIST.COLLR,'',NO.OF.REC.COLLR,RET.CODE.COLLR)


    LOOP
        REMOVE Y.ID FROM SEL.CMD.LIST.COLLR SETTING Y.COLLR.POS
    WHILE Y.ID:Y.COLLR.POS

        EB.DataAccess.FRead(FN.COLLR,Y.ID,COLLR.REC,F.COLLR,COLLR.ERR)

* Y.RECORD.STATUS = COLLR.REC<COLL.RIGHT.RECORD.STATUS>
        Y.RECORD.STATUS = COLLR.REC<CO.Contract.CollateralRight.CollRightRecordStatus>
        Y.INPUTTER = COLLR.REC<CO.Contract.CollateralRight.CollRightInputter>
        Y.INP.CNT = DCOUNT(Y.INPUTTER,@VM)
        Y.INPUTTER = Y.INPUTTER<1,Y.INP.CNT>
        Y.INPUTTER = FIELD(Y.INPUTTER,'_',2)

        Y.DATE.TIME = COLLR.REC<CO.Contract.CollateralRight.CollRightDateTime>
        Y.DT.TM.CNT = DCOUNT(Y.DATE.TIME,@VM)
        Y.DATE.TIME = Y.DATE.TIME<1,Y.DT.TM.CNT>
        Y.DT = Y.DATE.TIME[1,6]
        Y.DT.DISP = OCONV(ICONV(Y.DT[1,6],"D2/"),'D4')
        Y.TM.MIN = Y.DATE.TIME[7,2]
        Y.TM.SEC = Y.DATE.TIME[9,2]
        Y.INP.DT.TM = Y.DT.DISP:"  ":Y.TM.MIN:':':Y.TM.SEC

        Y.CO.CODE = COLLR.REC<CO.Contract.CollateralRight.CollRightCoCode>
        Y.APP = "Collateral Right"

        GOSUB Y.DATA.ARRAY

    REPEAT

*******************
    !COLLATERAL.RECORD:
*******************
    IF Y.SEL.CO NE '' THEN
        SEL.CMD.COLL = "SELECT ":FN.COLL:" WITH CO.CODE EQ ":Y.SEL.CO
    END ELSE
        SEL.CMD.COLL = "SELECT ":FN.COLL:" WITH CO.CODE EQ ":Y.COMPANY
    END
    EB.DataAccess.Readlist(SEL.CMD.COLL,SEL.CMD.LIST.COLL,'',NO.OF.REC.COLL,RET.CODE.COLL)

    LOOP
        REMOVE Y.ID FROM SEL.CMD.LIST.COLL SETTING Y.COLL.POS
    WHILE Y.ID:Y.COLL.POS

        EB.DataAccess.FRead(FN.COLL,Y.ID,COLL.REC,F.COLL,COLL.ERR)

* Y.RECORD.STATUS = COLL.REC<COLL.RECORD.STATUS>
        Y.RECORD.STATUS = COLL.REC<CO.Contract.Collateral.CollRecordStatus>
        Y.INPUTTER = COLL.REC<CO.Contract.Collateral.CollInputter>
        Y.INP.CNT = DCOUNT(Y.INPUTTER,@VM)
        Y.INPUTTER = Y.INPUTTER<1,Y.INP.CNT>
        Y.INPUTTER = FIELD(Y.INPUTTER,'_',2)

        Y.DATE.TIME = COLL.REC<CO.Contract.Collateral.CollDateTime>
        Y.DT.TM.CNT = DCOUNT(Y.DATE.TIME,@VM)
        Y.DATE.TIME = Y.DATE.TIME<1,Y.DT.TM.CNT>
        Y.DT = Y.DATE.TIME[1,6]
        Y.DT.DISP = OCONV(ICONV(Y.DT[1,6],"D2/"),'D4')
        Y.TM.MIN = Y.DATE.TIME[7,2]
        Y.TM.SEC = Y.DATE.TIME[9,2]
        Y.INP.DT.TM = Y.DT.DISP:"  ":Y.TM.MIN:':':Y.TM.SEC

        Y.CO.CODE = COLL.REC<CO.Contract.Collateral.CollCoCode>
        Y.APP = "Collateral"

        GOSUB Y.DATA.ARRAY

    REPEAT

***********
    !AA.RETAIL.RECORD:
***********
    IF Y.SEL.CO NE '' THEN
        SEL.CMD.LD = "SELECT ":FN.AA.RETAIL:" WITH ACTIVITY LIKE 'ACCOUNTS...' AND ACTIVITY UNLIKE '...VIEW-ARRANGEMENT' AND TXN.SYSTEM.ID NE 'FT' AND TXN.SYSTEM.ID NE 'TT' AND TXN.SYSTEM.ID NE 'AC' AND CO.CODE EQ ":Y.SEL.CO
    END ELSE
        SEL.CMD.LD = "SELECT ":FN.AA.RETAIL:" WITH ACTIVITY LIKE 'ACCOUNTS...' AND ACTIVITY UNLIKE '...VIEW-ARRANGEMENT' AND TXN.SYSTEM.ID NE 'FT' AND TXN.SYSTEM.ID NE 'TT' AND TXN.SYSTEM.ID NE 'AC' AND CO.CODE EQ ":Y.COMPANY
    END

    EB.DataAccess.Readlist(SEL.CMD.LD,SEL.CMD.LIST.LD,'',NO.OF.REC.LD,RET.CODE.LD)

    LOOP
        REMOVE Y.AA.ID FROM SEL.CMD.LIST.LD SETTING Y.LD.POS
    WHILE Y.AA.ID:Y.LD.POS

        EB.DataAccess.FRead(FN.AA.RETAIL,Y.AA.ID,AA.RETAIL.REC,F.AA.RETAIL,LD.ERR)
        
        Y.AA.ID = AA.RETAIL.REC<AA.Framework.ArrangementActivity.ArrActArrangement>
        Y.ID = Y.AA.ID
*
*____TERM AMOUNT___
        PropertyClass1 = 'TERM.AMOUNT'
        AA.Framework.GetArrangementConditions(Y.AA.ID, PropertyClass1, Idproperty, Effectivedate, Returnids, Returnconditions1, Returnerror) ;* Product conditions with activities
        R.REC1 = RAISE(Returnconditions1)
        Y.AMT = R.REC1<AA.TermAmount.TermAmount.AmtAmount>
*
        Y.TXN.AMT = Y.AMT
        Y.PRINCIPAL = Y.AMT
        
        PropertyClass1 = 'PAYMENT.SCHEDULE'
        AA.Framework.GetArrangementConditions(Y.AA.ID, PropertyClass1, Idproperty, Effectivedate, Returnids, Returnconditions2, Returnerror) ;* Product conditions with activities
        R.REC2 = RAISE(Returnconditions2)
        Y.INSTALLMENT = R.REC2<AA.PaymentSchedule.PaymentSchedule.PsActualAmt>
        
        Y.RECORD.STATUS = AA.RETAIL.REC<AA.Framework.ArrangementActivity.ArrActRecordStatus>
        Y.INPUTTER = AA.RETAIL.REC<AA.Framework.ArrangementActivity.ArrActInputter>
        Y.INP.CNT = DCOUNT(Y.INPUTTER,@VM)
        Y.INPUTTER = Y.INPUTTER<1,Y.INP.CNT>
        Y.INPUTTER = FIELD(Y.INPUTTER,'_',2)
*
        Y.DATE.TIME = AA.RETAIL.REC<AA.Framework.ArrangementActivity.ArrActDateTime>
        Y.DT.TM.CNT = DCOUNT(Y.DATE.TIME,@VM)
        Y.DATE.TIME = Y.DATE.TIME<1,Y.DT.TM.CNT>
        Y.DT = Y.DATE.TIME[1,6]
        Y.DT.DISP = OCONV(ICONV(Y.DT[1,6],"D2/"),'D4')
        Y.TM.MIN = Y.DATE.TIME[7,2]
        Y.TM.SEC = Y.DATE.TIME[9,2]
        Y.INP.DT.TM = Y.DT.DISP:"  ":Y.TM.MIN:':':Y.TM.SEC

        Y.CO.CODE = AA.RETAIL.REC<AA.Framework.ArrangementActivity.ArrActCoCode>
        Y.APP = "AA RETAIL ACCOUNTS"

        GOSUB Y.DATA.ARRAY

    REPEAT

************

    !AA.DEPOSIT.RECORD:
***********
    IF Y.SEL.CO NE '' THEN
        SEL.CMD.DEP = "SELECT ":FN.AA.DEPOSIT:" WITH ACTIVITY LIKE 'DEPOSITS...' AND ACTIVITY UNLIKE '...VIEW-ARRANGEMENT' AND TXN.SYSTEM.ID NE 'FT' AND TXN.SYSTEM.ID NE 'TT' AND TXN.SYSTEM.ID NE 'AC' AND CO.CODE EQ ":Y.SEL.CO
    END ELSE
        SEL.CMD.DEP = "SELECT ":FN.AA.DEPOSIT:" WITH ACTIVITY LIKE 'DEPOSITS...' AND ACTIVITY UNLIKE '...VIEW-ARRANGEMENT' AND TXN.SYSTEM.ID NE 'FT' AND TXN.SYSTEM.ID NE 'TT' AND TXN.SYSTEM.ID NE 'AC' AND CO.CODE EQ ":Y.COMPANY
    END

    EB.DataAccess.Readlist(SEL.CMD.DEP,SEL.CMD.LIST.DEP,'',NO.OF.REC.DEP,RET.CODE.DEP)

    LOOP
        REMOVE Y.AA.ID FROM SEL.CMD.LIST.DEP SETTING Y.DEP.POS
    WHILE Y.AA.ID:Y.DEP.POS

        EB.DataAccess.FRead(FN.AA.DEPOSIT,Y.AA.ID,AA.DEPOSIT.REC,F.AA.DEPOSIT,DEP.ERR)
        
        Y.AA.ID = AA.DEPOSIT.REC<AA.Framework.ArrangementActivity.ArrActArrangement>
        
        Y.ID = Y.AA.ID
*
*____TERM AMOUNT___
        PropertyClass1 = 'TERM.AMOUNT'
        AA.Framework.GetArrangementConditions(Y.AA.ID, PropertyClass1, Idproperty, Effectivedate, Returnids, Returnconditions1, Returnerror) ;* Product conditions with activities
        R.REC1 = RAISE(Returnconditions1)
        Y.AMT = R.REC1<AA.TermAmount.TermAmount.AmtAmount>
*
        Y.TXN.AMT = Y.AMT
        Y.PRINCIPAL = Y.AMT
        
        PropertyClass1 = 'PAYMENT.SCHEDULE'
        AA.Framework.GetArrangementConditions(Y.AA.ID, PropertyClass1, Idproperty, Effectivedate, Returnids, Returnconditions2, Returnerror) ;* Product conditions with activities
        R.REC2 = RAISE(Returnconditions2)
        Y.INSTALLMENT = R.REC2<AA.PaymentSchedule.PaymentSchedule.PsActualAmt>
        
        Y.RECORD.STATUS = AA.DEPOSIT.REC<AA.Framework.ArrangementActivity.ArrActRecordStatus>
        Y.INPUTTER = AA.DEPOSIT.REC<AA.Framework.ArrangementActivity.ArrActInputter>
        Y.INP.CNT = DCOUNT(Y.INPUTTER,@VM)
        Y.INPUTTER = Y.INPUTTER<1,Y.INP.CNT>
        Y.INPUTTER = FIELD(Y.INPUTTER,'_',2)
*
        Y.DATE.TIME = AA.DEPOSIT.REC<AA.Framework.ArrangementActivity.ArrActDateTime>
        Y.DT.TM.CNT = DCOUNT(Y.DATE.TIME,@VM)
        Y.DATE.TIME = Y.DATE.TIME<1,Y.DT.TM.CNT>
        Y.DT = Y.DATE.TIME[1,6]
        Y.DT.DISP = OCONV(ICONV(Y.DT[1,6],"D2/"),'D4')
        Y.TM.MIN = Y.DATE.TIME[7,2]
        Y.TM.SEC = Y.DATE.TIME[9,2]
        Y.INP.DT.TM = Y.DT.DISP:"  ":Y.TM.MIN:':':Y.TM.SEC

        Y.CO.CODE = AA.DEPOSIT.REC<AA.Framework.ArrangementActivity.ArrActCoCode>
        Y.APP = "AA DEPOSITS"

        GOSUB Y.DATA.ARRAY

    REPEAT


************

    !AA.LENDING.RECORD:
***********
    IF Y.SEL.CO NE '' THEN
        SEL.CMD.LEN = "SELECT ":FN.AA.LENDING:" WITH ACTIVITY LIKE 'LENDING...' AND ACTIVITY UNLIKE '...VIEW-ARRANGEMENT' AND TXN.SYSTEM.ID NE 'FT' AND TXN.SYSTEM.ID NE 'TT' AND TXN.SYSTEM.ID NE 'AC' AND CO.CODE EQ ":Y.SEL.CO
    END ELSE
        SEL.CMD.LEN = "SELECT ":FN.AA.LENDING:" WITH ACTIVITY LIKE 'LENDING...' AND ACTIVITY UNLIKE '...VIEW-ARRANGEMENT' AND TXN.SYSTEM.ID NE 'FT' AND TXN.SYSTEM.ID NE 'TT' AND TXN.SYSTEM.ID NE 'AC' AND CO.CODE EQ ":Y.COMPANY
    END

    EB.DataAccess.Readlist(SEL.CMD.LEN,SEL.CMD.LIST.LEN,'',NO.OF.REC.LEN,RET.CODE.LEN)

    LOOP
        REMOVE Y.AA.ID FROM SEL.CMD.LIST.LEN SETTING Y.LEN.POS
    WHILE Y.AA.ID:Y.LEN.POS

        EB.DataAccess.FRead(FN.AA.LENDING,Y.AA.ID,AA.LENDING.REC,F.AA.LENDING,LEN.ERR)
        
        Y.AA.ID = AA.LENDING.REC<AA.Framework.ArrangementActivity.ArrActArrangement>
        
        Y.ID = Y.AA.ID
*
*____TERM AMOUNT___
        PropertyClass1 = 'TERM.AMOUNT'
        AA.Framework.GetArrangementConditions(Y.AA.ID, PropertyClass1, Idproperty, Effectivedate, Returnids, Returnconditions1, Returnerror) ;* Product conditions with activities
        R.REC1 = RAISE(Returnconditions1)
        Y.AMT = R.REC1<AA.TermAmount.TermAmount.AmtAmount>
*
        Y.TXN.AMT = Y.AMT
        Y.PRINCIPAL = Y.AMT
        
        PropertyClass1 = 'PAYMENT.SCHEDULE'
        AA.Framework.GetArrangementConditions(Y.AA.ID, PropertyClass1, Idproperty, Effectivedate, Returnids, Returnconditions2, Returnerror) ;* Product conditions with activities
        R.REC2 = RAISE(Returnconditions2)
        Y.INSTALLMENT = R.REC2<AA.PaymentSchedule.PaymentSchedule.PsActualAmt>
        
        Y.RECORD.STATUS = AA.LENDING.REC<AA.Framework.ArrangementActivity.ArrActRecordStatus>
        Y.INPUTTER = AA.LENDING.REC<AA.Framework.ArrangementActivity.ArrActInputter>
        Y.INP.CNT = DCOUNT(Y.INPUTTER,@VM)
        Y.INPUTTER = Y.INPUTTER<1,Y.INP.CNT>
        Y.INPUTTER = FIELD(Y.INPUTTER,'_',2)
*
        Y.DATE.TIME = AA.LENDING.REC<AA.Framework.ArrangementActivity.ArrActDateTime>
        Y.DT.TM.CNT = DCOUNT(Y.DATE.TIME,@VM)
        Y.DATE.TIME = Y.DATE.TIME<1,Y.DT.TM.CNT>
        Y.DT = Y.DATE.TIME[1,6]
        Y.DT.DISP = OCONV(ICONV(Y.DT[1,6],"D2/"),'D4')
        Y.TM.MIN = Y.DATE.TIME[7,2]
        Y.TM.SEC = Y.DATE.TIME[9,2]
        Y.INP.DT.TM = Y.DT.DISP:"  ":Y.TM.MIN:':':Y.TM.SEC

        Y.CO.CODE = AA.LENDING.REC<AA.Framework.ArrangementActivity.ArrActCoCode>
        Y.APP = "AA LENDING"

        GOSUB Y.DATA.ARRAY

    REPEAT

************
***********

    !MD.RECORD:
***********
    IF Y.SEL.CO NE '' THEN
        SEL.CMD.MD = "SELECT ":FN.MD:" WITH CO.CODE EQ ":Y.SEL.CO
    END ELSE
        SEL.CMD.MD = "SELECT ":FN.MD:" WITH CO.CODE EQ ":Y.COMPANY
    END
    EB.DataAccess.Readlist(SEL.CMD.MD,SEL.CMD.LIST.MD,'',NO.OF.REC.MD,RET.CODE.MD)

    LOOP
        REMOVE Y.ID FROM SEL.CMD.LIST.MD SETTING Y.MD.POS
    WHILE Y.ID:Y.MD.POS

        EB.DataAccess.FRead(FN.MD,Y.ID,MD.REC,F.MD,MD.ERR)


*   Y.RECORD.STATUS = MD.REC<MD.DEA.RECORD.STATUS>
        Y.RECORD.STATUS = MD.REC<MD.Contract.Deal.DeaRecordStatus>
*   Y.INPUTTER = MD.REC<MD.DEA.INPUTTER>
        Y.INPUTTER = MD.REC<MD.Contract.Deal.DeaInputter>
        Y.INP.CNT = DCOUNT(Y.INPUTTER,@VM)
        Y.INPUTTER = Y.INPUTTER<1,Y.INP.CNT>
        Y.INPUTTER = FIELD(Y.INPUTTER,'_',2)

*Y.DATE.TIME = MD.REC<MD.DEA.DATE.TIME>
        Y.DATE.TIME = MD.REC<MD.Contract.Deal.DeaDateTime>
        Y.DT.TM.CNT = DCOUNT(Y.DATE.TIME,@VM)
        Y.DATE.TIME = Y.DATE.TIME<1,Y.DT.TM.CNT>
        Y.DT = Y.DATE.TIME[1,6]
        Y.DT.DISP = OCONV(ICONV(Y.DT[1,6],"D2/"),'D4')
        Y.TM.MIN = Y.DATE.TIME[7,2]
        Y.TM.SEC = Y.DATE.TIME[9,2]
        Y.INP.DT.TM = Y.DT.DISP:"  ":Y.TM.MIN:':':Y.TM.SEC

        Y.CO.CODE = MD.REC<MD.Contract.Deal.DeaCoCode>
*
        Y.APP = "Miscellaneous Deals (MD)"

        GOSUB Y.DATA.ARRAY

    REPEAT

***********
    !LC.RECORD:
***********
    IF Y.SEL.CO NE '' THEN
        SEL.CMD.LC = "SELECT ":FN.LC:" WITH CO.CODE EQ ":Y.SEL.CO
    END ELSE
        SEL.CMD.LC = "SELECT ":FN.LC:" WITH CO.CODE EQ ":Y.COMPANY
    END
    EB.DataAccess.Readlist(SEL.CMD.LC,SEL.CMD.LIST.LC,'',NO.OF.REC.LC,RET.CODE.LC)

    LOOP
        REMOVE Y.ID FROM SEL.CMD.LIST.LC SETTING Y.LC.POS
    WHILE Y.ID:Y.LC.POS

        EB.DataAccess.FRead(FN.LC,Y.ID,LC.REC,F.LC,LC.ERR)

        Y.LC.TYPE = LC.REC<LC.Contract.LetterOfCredit.TfLcLcType>
        Y.TXN.AMT = LC.REC<LC.Contract.LetterOfCredit.TfLcLcAmount>
        Y.RECORD.STATUS = LC.REC<LC.Contract.LetterOfCredit.TfLcRecordStatus>
        Y.INPUTTER = LC.REC<LC.Contract.LetterOfCredit.TfLcInputter>
        Y.INP.CNT = DCOUNT(Y.INPUTTER,@VM)
        Y.INPUTTER = Y.INPUTTER<1,Y.INP.CNT>
        Y.INPUTTER = FIELD(Y.INPUTTER,'_',2)
*
        Y.DATE.TIME = LC.REC<LC.Contract.LetterOfCredit.TfLcDateTime>
        Y.DT.TM.CNT = DCOUNT(Y.DATE.TIME,@VM)
        Y.DATE.TIME = Y.DATE.TIME<1,Y.DT.TM.CNT>
        Y.DT = Y.DATE.TIME[1,6]
        Y.DT.DISP = OCONV(ICONV(Y.DT[1,6],"D2/"),'D4')
        Y.TM.MIN = Y.DATE.TIME[7,2]
        Y.TM.SEC = Y.DATE.TIME[9,2]
        Y.INP.DT.TM = Y.DT.DISP:"  ":Y.TM.MIN:':':Y.TM.SEC

        Y.CO.CODE = LC.REC<LC.Contract.LetterOfCredit.TfLcCoCode>

        IF Y.LC.TYPE THEN
            Y.APP = "Letter of Credit (":Y.LC.TYPE:")"
        END ELSE
            Y.APP = "Letter of Credit"
        END

        GOSUB Y.DATA.ARRAY

    REPEAT

***********
    !DR.RECORD:
***********
    IF Y.SEL.CO NE '' THEN
        SEL.CMD.DRAW = "SELECT ":FN.DRAW:" WITH CO.CODE EQ ":Y.SEL.CO
    END ELSE
        SEL.CMD.DRAW = "SELECT ":FN.DRAW:" WITH CO.CODE EQ ":Y.COMPANY
    END

    EB.DataAccess.Readlist(SEL.CMD.DRAW,SEL.CMD.LIST.DRAW,'',NO.OF.REC.DRAW,RET.CODE.DRAW)

    LOOP
        REMOVE Y.ID FROM SEL.CMD.LIST.DRAW SETTING Y.DRAW.POS
    WHILE Y.ID:Y.DRAW.POS

        EB.DataAccess.FRead(FN.DRAW,Y.ID,DRAW.REC,F.DRAW,DRAW.ERR)

        Y.DR.TYPE = DRAW.REC<LC.Contract.Drawings.TfDrDrawingType>
        Y.TXN.AMT = DRAW.REC<LC.Contract.Drawings.TfDrDocumentAmount>
        Y.RECORD.STATUS = DRAW.REC<LC.Contract.Drawings.TfDrRecordStatus>
        Y.INPUTTER = DRAW.REC<LC.Contract.Drawings.TfDrInputter>
        Y.INP.CNT = DCOUNT(Y.INPUTTER,@VM)
        Y.INPUTTER = Y.INPUTTER<1,Y.INP.CNT>
        Y.INPUTTER = FIELD(Y.INPUTTER,'_',2)
*
        Y.DATE.TIME = DRAW.REC<LC.Contract.Drawings.TfDrDateTime>
        Y.DT.TM.CNT = DCOUNT(Y.DATE.TIME,@VM)
        Y.DATE.TIME = Y.DATE.TIME<1,Y.DT.TM.CNT>
        Y.DT = Y.DATE.TIME[1,6]
        Y.DT.DISP = OCONV(ICONV(Y.DT[1,6],"D2/"),'D4')
        Y.TM.MIN = Y.DATE.TIME[7,2]
        Y.TM.SEC = Y.DATE.TIME[9,2]
        Y.INP.DT.TM = Y.DT.DISP:"  ":Y.TM.MIN:':':Y.TM.SEC

        Y.CO.CODE = DRAW.REC<LC.Contract.Drawings.TfDrCoCode>
        Y.APP = "Drawings (":Y.DR.TYPE:")"

        GOSUB Y.DATA.ARRAY

    REPEAT


Y.DATA.ARRAY:

    Y.GT.DT = TIMEDATE()
    Y.GT.DT.DISP = "Generation Time & Date: ":Y.GT.DT
*
    Y.RETURN<-1> = Y.ID:'*':Y.TXN.AMT:'*':Y.PRINCIPAL:'*':Y.INSTALLMENT:'*':Y.RECORD.STATUS:'*':Y.INPUTTER:'*':Y.INP.DT.TM:'*':Y.CO.CODE:'*':Y.APP:'*':Y.GT.DT.DISP
*
    Y.ID = ''
    Y.TXN.AMT = ''
    Y.PRINCIPAL = ''
    Y.INSTALLMENT = ''
    Y.RECORD.STATUS = ''
    Y.INPUTTER = ''
    Y.INP.DT.TM = ''
    Y.CO.CODE = ''
    Y.APP = ''
    Y.GT.DT.DISP = ''
*   PRINT Y.RETURN
RETURN
END