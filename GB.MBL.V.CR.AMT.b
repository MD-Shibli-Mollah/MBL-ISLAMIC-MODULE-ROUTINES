* @ValidationCode : MjotMTkyMzU4NjQwNDpDcDEyNTI6MTU5MjUwNjAxNDU1NzpERUxMOi0xOi0xOjA6MDpmYWxzZTpOL0E6REVWXzIwMTcxMC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 19 Jun 2020 00:46:54
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.MBL.V.CR.AMT
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
*Subroutine Description: This routine for validation
*Subroutine Type       : Validation
*Attached To           : version
*Attached As           : ROUTINE
*Developed by          : S.M. Sayeed
*Designation           : Technical Consultant
*Email                 : s.m.sayeed@fortress-global.com
*Incoming Parameters   :
*Outgoing Parameters   :
*-----------------------------------------------------------------------------
* Modification History :
* 1)
*    Date :
*    Modification Description :
*    Modified By  :
*
*-----------------------------------------------------------------------------
*
*1/S----Modification Start
*
*1/E----Modification End
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.BD.MBL.LPC.CHARGE.REC
    
    $USING EB.SystemTables
    $USING EB.ErrorProcessing
    $USING FT.Contract
    $USING EB.DataAccess
    $USING AC.AccountOpening
    $USING EB.Updates
    $USING AA.PaymentSchedule
    $USING AA.TermAmount
    $USING TT.Contract
*-----------------------------------------------------------------------------
    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN
*---------------------------------------------------------------------
******
INIT:
******
    FN.LPC.CRG = 'F.BD.MBL.LPC.CHARGE.REC'
    F.LPC.CRG = ''
    FN.ACCT = 'F.ACCOUNT'
    F.ACCT = ''
    FN.AA.AC = 'F.AA.ACCOUNT.DETAILS'
    F.AA.AC = ''
    Y.APP.1 ='FUNDS.TRANSFER'
    Y.FIELD = 'LT.FT.LPC.CRG':VM:'LT.FT.TOT.AMT':VM:'LT.FT.LPC.DUE'
    Y.APP.2 ='TELLER'
    Y.FIELD.2 = 'LT.FT.LPC.CRG':VM:'LT.FT.TOT.AMT':VM:'LT.FT.LPC.DUE':VM:'LT.TT.TOT.AMT'
    Y.LPC.SETTLE.POS=''
    Y.TOT.FUND.AMT.POS = ''
    Y.TOT.TOT.DUE.AMT.POS = ''
    Y.TOT.MAIN.AMT.INP.POS = ''
    Y.TOT.FUND.AMT = 0
RETURN
**********
OPENFILES:
**********
    EB.DataAccess.Opf(FN.ACCT,F.ACCT)
    EB.DataAccess.Opf(FN.LPC.CRG, F.LPC.CRG)
    EB.DataAccess.Opf(FN.AA.AC, F.AA.AC)
RETURN
********
PROCESS:
    
    Y.APPLICATION = EB.SystemTables.getApplication()
    IF Y.APPLICATION EQ 'FUNDS.TRANSFER' THEN
        Y.CREDIT.ACCT.ID = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditAcctNo)
        EB.Updates.MultiGetLocRef(Y.APP.1, Y.FIELD, Y.POSITION)
        Y.LPC.SETTLE.POS = Y.POSITION<1,1>
        Y.TOT.FUND.AMT.POS = Y.POSITION<1,2>
        Y.TOT.TOT.DUE.AMT.POS = Y.POSITION<1,3>
        Y.TOT.LOCAL.FIELD = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.LocalRef)
        Y.TOT.FUND.AMT = Y.TOT.LOCAL.FIELD<1,Y.TOT.FUND.AMT.POS>
    END
    
    IF Y.APPLICATION EQ 'TELLER' THEN
        Y.CREDIT.ACCT.ID = EB.SystemTables.getRNew(TT.Contract.Teller.TeAccountTwo)
        EB.Updates.MultiGetLocRef(Y.APP.2, Y.FIELD.2, Y.POSITION)
        Y.LPC.SETTLE.POS = Y.POSITION<1,1>
        Y.TOT.FUND.AMT.POS = Y.POSITION<1,2>
        Y.TOT.TOT.DUE.AMT.POS = Y.POSITION<1,3>
        Y.TOT.MAIN.AMT.INP.POS = Y.POSITION<1,4>
        Y.TOT.LOCAL.FIELD = EB.SystemTables.getRNew(TT.Contract.Teller.TeLocalRef)
        Y.TOT.MAIN.AMT.ARR = Y.TOT.LOCAL.FIELD<1,Y.TOT.MAIN.AMT.INP.POS>
        CONVERT SM TO VM IN Y.TOT.MAIN.AMT.ARR
        NO.OF.AMT.FILED = DCOUNT(Y.TOT.MAIN.AMT.ARR,VM)
        FOR I = 1 TO NO.OF.AMT.FILED
            Y.TOT.FUND.AMT = Y.TOT.FUND.AMT + Y.TOT.MAIN.AMT.ARR<1,I>
        NEXT I
        Y.TOT.LOCAL.FIELD<1,Y.TOT.FUND.AMT.POS> = Y.TOT.FUND.AMT
    END
    
    EB.DataAccess.FRead(FN.ACCT, Y.CREDIT.ACCT.ID, REC.ACCT, F.ACCT, ERR)
    Y.ARR.ID  = REC.ACCT<AC.AccountOpening.Account.ArrangementId>
    
    Y.DUE.INST = 0

    EB.DataAccess.FRead(FN.LPC.CRG, Y.ARR.ID, REC.LPC, F.LPC.CRG, ERR.LPC)
    EB.DataAccess.FRead(FN.AA.AC,Y.ARR.ID,R.AA.AC,F.AA.AC,AA.AC.ERROR)
    Y.TOT.BL.TYPE = R.AA.AC<AA.PaymentSchedule.AccountDetails.AdBillType>
    Y.TOT.BL.STATUS = R.AA.AC<AA.PaymentSchedule.AccountDetails.AdBillStatus>
    Y.TOT.SET.STATUS = R.AA.AC<AA.PaymentSchedule.AccountDetails.AdSetStatus>
    Y.TOT.BILL.ID = R.AA.AC<AA.PaymentSchedule.AccountDetails.AdBillId>
    CONVERT SM TO VM IN Y.TOT.BL.TYPE
    CONVERT SM TO VM IN Y.TOT.BL.STATUS
    CONVERT SM TO VM IN Y.TOT.SET.STATUS
    CONVERT SM TO VM IN Y.TOT.BILL.ID
    Y.DCOUNT = DCOUNT(Y.TOT.BL.TYPE,VM)
    FOR I = 1 TO Y.DCOUNT
        Y.BL.TYPE = Y.TOT.BL.TYPE<1,I>
        Y.BL.STATUS = Y.TOT.BL.STATUS<1,I>
        Y.SET.STATUS = Y.TOT.SET.STATUS<1,I>
        Y.BILL.ID = Y.TOT.BILL.ID<1,I>
        IF Y.BL.TYPE EQ 'EXPECTED' AND Y.SET.STATUS EQ 'UNPAID' THEN
            Y.COUNT = Y.COUNT + 1
            Y.ACC.REC = AA.PaymentSchedule.BillDetails.Read(Y.BILL.ID, ERR.BILL)
            Y.BILL.AMT = Y.ACC.REC<AA.PaymentSchedule.BillDetails.BdOsTotalAmount>
            Y.DUE.INST = Y.DUE.INST + Y.BILL.AMT
        END
    NEXT I
    Y.LPC.DUE.AMT = REC.LPC<LPC.TOT.DUE.AMT>
    IF Y.TOT.FUND.AMT LT Y.DUE.INST THEN
        Y.FUNDING.AMT = Y.TOT.FUND.AMT
        Y.LPC.ADJUST.AMT = 0
    END ELSE
        IF Y.LPC.DUE.AMT THEN
            Y.FUNDING.AMT = Y.DUE.INST
            Y.LPC.ADJUST.AMT = Y.TOT.FUND.AMT - Y.DUE.INST
            IF Y.LPC.ADJUST.AMT GT Y.LPC.DUE.AMT THEN
                Y.LPC.ADJUST.AMT = Y.LPC.DUE.AMT
                Y.FUNDING.AMT = Y.DUE.INST + (Y.TOT.FUND.AMT - (Y.DUE.INST + Y.LPC.ADJUST.AMT))
            END
        END ELSE
            Y.FUNDING.AMT = Y.TOT.FUND.AMT
            Y.LPC.ADJUST.AMT = 0
        END
    END
    
    IF Y.APPLICATION EQ 'FUNDS.TRANSFER' THEN
        EB.SystemTables.setRNew(FT.Contract.FundsTransfer.CreditAmount, Y.FUNDING.AMT)
        Y.TOT.LOCAL.FIELD<1,Y.LPC.SETTLE.POS> = Y.LPC.ADJUST.AMT
        Y.TOT.LOCAL.FIELD<1,Y.TOT.TOT.DUE.AMT.POS> = Y.LPC.DUE.AMT
        EB.SystemTables.setRNew(FT.Contract.FundsTransfer.LocalRef, Y.TOT.LOCAL.FIELD)
    END

    IF Y.APPLICATION EQ 'TELLER' THEN
        EB.SystemTables.setRNew(TT.Contract.Teller.TeAmountLocalOne, Y.FUNDING.AMT)
        Y.TOT.LOCAL.FIELD<1,Y.LPC.SETTLE.POS> = Y.LPC.ADJUST.AMT
        Y.TOT.LOCAL.FIELD<1,Y.TOT.TOT.DUE.AMT.POS> = Y.LPC.DUE.AMT
        EB.SystemTables.setRNew(TT.Contract.Teller.TeLocalRef, Y.TOT.LOCAL.FIELD)
    END

RETURN

END
