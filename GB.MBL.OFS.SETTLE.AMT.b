* @ValidationCode : MjoxNDAzNzA1NDQ2OkNwMTI1MjoxNTkyNTA1ODk3ODU5OkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 19 Jun 2020 00:44:57
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.MBL.OFS.SETTLE.AMT
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
*Subroutine Description: This routine lpc settle by TT and FT
*Subroutine Type       : Auth
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
    $USING  EB.SystemTables
    $USING  EB.ErrorProcessing
    $USING FT.Contract
    $USING EB.DataAccess
    $USING EB.Interface
    $USING EB.TransactionControl
    $USING EB.LocalReferences
    $USING TT.Contract
    $USING ST.CompanyCreation
    $INSERT I_F.COMPANY
*---------------------------------------------------------------------------
    FN.COM = 'F.COMPANY'
    F.COM = ''
    Y.APP ='FUNDS.TRANSFER'
    Y.FIELD = 'LT.FT.LPC.CRG'
    Y.LPC.SETTLE.POS=''
    EB.DataAccess.Opf(FN.COM, F.COM)
    Y.APPLICATION = EB.SystemTables.getApplication()
    Y.V$FUNCTION = EB.SystemTables.getVFunction()
    IF Y.V$FUNCTION EQ 'A' THEN
        IF Y.APPLICATION EQ 'FUNDS.TRANSFER' THEN
            Y.CREDIT.ACCT.ID =EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditAcctNo)
            Y.ORD.BNK = 'MBL'
            Y.DEBIT.ACCT.ID=EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitAcctNo)
    
            EB.LocalReferences.GetLocRef(Y.APP, Y.FIELD, Y.LPC.SETTLE.POS)
            Y.TOT.LOCAL.FIELD = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.LocalRef)
            Y.LPC.ADJUST.AMT = Y.TOT.LOCAL.FIELD<1,Y.LPC.SETTLE.POS>
            Y.COMPANY = EB.SystemTables.getIdCompany()
    
            IF Y.LPC.ADJUST.AMT GT 0 THEN
                Y.MESSAGE="FUNDS.TRANSFER,MBL.AA.MSS.FUND.OFS/I/PROCESS//0,//":Y.COMPANY:",,TRANSACTION.TYPE=ACLP,DEBIT.ACCT.NO=":Y.DEBIT.ACCT.ID:",DEBIT.CURRENCY=":EB.SystemTables.getLccy():",DEBIT.AMOUNT=":Y.LPC.ADJUST.AMT:",DEBIT.VALUE.DATE=":EB.SystemTables.getToday():",CREDIT.VALUE.DATE=":EB.SystemTables.getToday():",CREDIT.ACCT.NO=":Y.CREDIT.ACCT.ID:",ORDERING.BANK=":Y.ORD.BNK:",DEBIT.THEIR.REF=":"Lpc Adjust Amt":",CREDIT.THEIR.REF=":"Lpc Adjust Amt"
                CALL ofs.addLocalRequest(Y.MESSAGE,'APPEND',LOCAL.ERROR)
                IF LOCAL.ERROR NE '' THEN
                    EB.SystemTables.setE(LOCAL.ERROR)
                    EB.ErrorProcessing.StoreEndError()
                END
            END
        END
        IF Y.APPLICATION EQ 'TELLER' THEN
            Y.APP = 'TELLER'
            Y.CREDIT.ACCT.ID =EB.SystemTables.getRNew(TT.Contract.Teller.TeAccountTwo)
    
            EB.LocalReferences.GetLocRef(Y.APP, Y.FIELD, Y.LPC.SETTLE.POS)
            Y.TOT.LOCAL.FIELD = EB.SystemTables.getRNew(TT.Contract.Teller.TeLocalRef)
            Y.LPC.ADJUST.AMT = Y.TOT.LOCAL.FIELD<1,Y.LPC.SETTLE.POS>
            Y.COMPANY = EB.SystemTables.getIdCompany()
    
            IF Y.LPC.ADJUST.AMT GT 0 THEN
                Y.MNEMONIC = FN.COM[2,3]
*                IF Y.MNEMONIC EQ 'BNK' THEN
                Y.MESSAGE="TELLER,MBL.AA.MSS.FUND.OFS/I/PROCESS//0,//":Y.COMPANY:",,TRANSACTION.CODE=155,AMOUNT.LOCAL.1=":Y.LPC.ADJUST.AMT:",ACCOUNT.2:1:1=":Y.CREDIT.ACCT.ID:",NARRATIVE.2=":"Lpc Adjust Amt"
                CALL ofs.addLocalRequest(Y.MESSAGE,'APPEND',LOCAL.ERROR)
                IF LOCAL.ERROR NE '' THEN
                    EB.SystemTables.setE(LOCAL.ERROR)
                    EB.ErrorProcessing.StoreEndError()
                END
*                END
*                IF Y.MNEMONIC EQ 'ISL' THEN
*                    Y.MESSAGE="TELLER,MBL.AA.MSS.FUND.OFS/I/PROCESS//0,//":Y.COMPANY:",,TRANSACTION.CODE=156,AMOUNT.LOCAL.1=":Y.LPC.ADJUST.AMT:",ACCOUNT.2:1:1=":Y.CREDIT.ACCT.ID:",NARRATIVE.2=":"Lpc Adjust Amt"
*                    CALL ofs.addLocalRequest(Y.MESSAGE,'APPEND',LOCAL.ERROR)
*                    IF LOCAL.ERROR NE '' THEN
*                        EB.SystemTables.setE(LOCAL.ERROR)
*                        EB.ErrorProcessing.StoreEndError()
*                    END
*                END
            END
        END
    END
       
RETURN
END
