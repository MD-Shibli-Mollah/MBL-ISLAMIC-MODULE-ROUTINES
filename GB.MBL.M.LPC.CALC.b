* @ValidationCode : MjotMTQ0MzgxNTE2NDpDcDEyNTI6MTU4NjI1NTQzMjcyMzpERUxMOi0xOi0xOjA6MDpmYWxzZTpOL0E6REVWXzIwMTcxMC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 07 Apr 2020 16:30:32
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.MBL.M.LPC.CALC(Y.AA.ID)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
*Subroutine Description: This routine calculate LPC due amount
*Subroutine Type       : Service
*Attached To           : 
*Attached As           : 
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
    $INSERT I_F.GB.MBL.M.LPC.CALC.COMMON
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_AA.APP.COMMON
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.BILL.DETAILS
    $INSERT I_F.BD.MBL.LPC.CHARGE.REC
    
    $USING AA.Account
    $USING AA.Framework
    $USING AA.PaymentSchedule
    $USING EB.DataAccess
    $USING EB.LocalReferences
    $USING AA.TermAmount
    $USING EB.SystemTables
    
*-----------------------------------------------------------------------------
    GOSUB PROCESS
RETURN
PROCESS:
    Y.TODAY = EB.SystemTables.getToday()
    EB.DataAccess.FRead(FN.AA,Y.AA.ID,R.AA,F.AA,AA.ER)
*    IF R.AA<AA.Framework.Arrangement.ArrArrStatus> NE 'CURRENT' THEN RETURN
    Y.COMPANY = R.AA<AA.Framework.Arrangement.ArrCoCode>
    PROP.CLASS = 'TERM.AMOUNT'
    AA.Framework.GetArrangementConditions(Y.AA.ID,PROP.CLASS,PROPERTY,'',RETURN.IDS,RETURN.VALUES,ERR.MSG)
    R.REC = RAISE(RETURN.VALUES)
    Y.INSTALL.AMT = R.REC<AA.TermAmount.TermAmount.AmtAmount>

    EB.DataAccess.FRead(FN.AA.AC,Y.AA.ID,R.AA.AC,F.AA.AC,AA.AC.ERROR)
    Y.TOT.BL.TYPE = R.AA.AC<AA.PaymentSchedule.AccountDetails.AdBillType>
*Y.TOT.BL.STATUS = R.AA.AC<AA.PaymentSchedule.AccountDetails.AdBillStatus>
    Y.TOT.SET.STATUS = R.AA.AC<AA.PaymentSchedule.AccountDetails.AdSetStatus>
    CONVERT SM TO VM IN Y.TOT.BL.TYPE
*CONVERT SM TO VM IN Y.TOT.BL.STATUS
    CONVERT SM TO VM IN Y.TOT.SET.STATUS
    Y.DCOUNT = DCOUNT(Y.TOT.BL.TYPE,VM)
    FOR I = 1 TO Y.DCOUNT
        Y.BL.TYPE = Y.TOT.BL.TYPE<1,I>
* Y.BL.STATUS = Y.TOT.BL.STATUS<1,I>
        Y.SET.STATUS = Y.TOT.SET.STATUS<1,I>
        IF Y.BL.TYPE EQ 'EXPECTED' AND Y.SET.STATUS EQ 'UNPAID' THEN
            Y.COUNT = Y.COUNT + 1
        END
    NEXT I
    IF Y.COUNT GT 0 THEN
        Y.CHARGE = (5*Y.COUNT*Y.INSTALL.AMT)/100
        Y.LPC.CRG.ID = Y.AA.ID
        EB.DataAccess.FRead(FN.LPC.CRG, Y.LPC.CRG.ID, REC.LPC, F.LPC.CRG, REC.ERROR)
        IF REC.LPC EQ '' THEN
            Y.FIELD.POS = DCOUNT(REC.LPC<LPC.DUE.DATE>,VM) + 1
            REC.LPC<LPC.DUE.DATE,Y.FIELD.POS> = Y.TODAY
            REC.LPC<LPC.AMT.THIS.DATE,Y.FIELD.POS> = Y.CHARGE
            REC.LPC<LPC.TOT.CHRG.AMT> = Y.CHARGE
            REC.LPC<LPC.TOT.DUE.AMT> = Y.CHARGE
            REC.LPC<LPC.COM.CODE> = Y.COMPANY
            WRITE REC.LPC TO F.LPC.CRG,Y.LPC.CRG.ID
        END ELSE
            Y.FIELD.POS = DCOUNT(REC.LPC<LPC.DUE.DATE>,VM) + 1
            REC.LPC<LPC.DUE.DATE,Y.FIELD.POS> = Y.TODAY
            REC.LPC<LPC.AMT.THIS.DATE,Y.FIELD.POS> = Y.CHARGE
            Y.DUE.AMT = REC.LPC<LPC.TOT.DUE.AMT>
            Y.PRE.CRG.AMT = REC.LPC<LPC.TOT.CHRG.AMT>
            REC.LPC<LPC.TOT.DUE.AMT> = Y.DUE.AMT + Y.CHARGE
            REC.LPC<LPC.TOT.CHRG.AMT> = Y.PRE.CRG.AMT + Y.CHARGE
            WRITE REC.LPC TO F.LPC.CRG,Y.LPC.CRG.ID
        END
    END
RETURN
END
