SUBROUTINE GB.MBL.ONL.DEBIT.WITHOUTCHQ
*-----------------------------------------------------------------------------
* Subroutine Description:
* THIS ROUTINE FOR VALIDATION ONLINE DEBIT WITHOUT CHEQUE
* Subroutine Type:
* Attached To    : EB.GC.CONSTRAINTS
* Attached As    :
*-----------------------------------------------------------------------------
* Modification History :
* 11/03/2020 -                            Retrofit   - Sarowar Mortoza
*                                                     FDS Pvt Ltd
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $USING TT.Contract
    $USING FT.Contract
    $USING AC.AccountOpening
    $USING AC.AccountClosure
    $USING MD.Contract
    $USING LC.Contract
    $USING AC.StandingOrders
    $USING EB.DataAccess
    $USING EB.LocalReferences
    $USING EB.SystemTables
    $USING EB.ErrorProcessing
    $INSERT I_F.MBL.EXCEPTION.LIST

    GOSUB OPEN.FILES
    GOSUB PROCESS
RETURN

**********
OPEN.FILES:
**********
    FN.TT= 'F.TELLER'
    F.TT= ''

    FN.FT= 'F.FUNDS.TRANSFER'
    F.FT= ''

    FN.AC= 'F.ACCOUNT'
    F.AC= ''

    FN.AC.CLSR = 'F.ACCOUNT.CLOSURE'
    F.AC.CLSR = ''

    FN.MD = 'F.MD.DEAL'
    F.MD =''

    FN.LC = 'F.LETTER.OF.CREDIT'
    F.LC = ''

    FN.DR = 'F.DRAWINGS'
    F.DR = ''

    FN.STO = 'F.STANDING.ORDER'
    F.STO = ''

    FN.ACVER= 'F.MBL.EXCEPTION.LIST'
    F.ACVER= ''

    EB.DataAccess.Opf(FN.TT,F.TT)
    EB.DataAccess.Opf(FN.FT,F.FT)
    EB.DataAccess.Opf(FN.AC,F.AC)
    EB.DataAccess.Opf(FN.AC.CLSR,F.AC.CLSR)
    EB.DataAccess.Opf(FN.MD,F.MD)
    EB.DataAccess.Opf(FN.LC,F.LC)
    EB.DataAccess.Opf(FN.DR,F.DR)
    EB.DataAccess.Opf(FN.STO,F.STO)
    EB.DataAccess.Opf(FN.ACVER,F.ACVER)

    Y.APPLICATION = EB.SystemTables.getApplication()
    Y.PGM= EB.SystemTables.getPgmVersion()
    Y.COMPANY = EB.SystemTables.getIdCompany()
    Y.RECORD= 'ONLINE.DEBIT.WITHOUTCHQ'
RETURN

*********
PROCESS:
*********

************************************TELLER*************************************************************

    IF Y.APPLICATION EQ 'TELLER' THEN

        Y.VERSION= Y.APPLICATION:Y.PGM

        EB.DataAccess.FRead(FN.ACVER,Y.RECORD,ACVER.REC,F.ACVER,ACVER.ERR)
       
        Y.VER.LIST= ACVER.REC<EB.EXCP.VERSION>

        CNT1= DCOUNT(Y.VER.LIST,@VM)
        FOR I=1 TO CNT1

            Y.VERSION.LIST= Y.VER.LIST<1,I>
            IF Y.VERSION EQ Y.VERSION.LIST THEN
                RETURN
            END
        NEXT I

        Y.DR.CR.MARKER= EB.SystemTables.getRNew(TT.Contract.Teller.TeDrCrMarker)
        Y.CHQ.NO= EB.SystemTables.getRNew(TT.Contract.Teller.TeChequeNumber)
        IF Y.DR.CR.MARKER EQ 'DEBIT' THEN
            Y.DEBIT.AC=EB.SystemTables.getRNew(TT.Contract.Teller.TeAccountOne)
        END ELSE
            Y.DEBIT.AC=EB.SystemTables.getRNew(TT.Contract.Teller.TeAccountTwo)
        END

        IF Y.DEBIT.AC[1,2] EQ 'PL' THEN
            RETURN
        END
        EB.DataAccess.FRead(FN.AC,Y.DEBIT.AC,AC.REC,F.AC,AC.ERR)
        Y.CO.CODE= AC.REC<AC.AccountOpening.Account.CoCode>

        IF EB.SystemTables.getIdCompany() NE Y.CO.CODE AND Y.CHQ.NO EQ '' THEN

            EB.DataAccess.FRead(FN.ACVER,Y.RECORD,ACVER.REC,F.ACVER,ACVER.ERR)
            Y.AC.LIST= ACVER.REC<EB.EXCP.TT.ACCOUNT.NO>

            CNT3= DCOUNT(Y.AC.LIST,@VM)
            FOR I=1 TO CNT3
                Y.ACCOUNT.LIST= Y.AC.LIST<1,I>

                IF Y.DEBIT.AC EQ Y.ACCOUNT.LIST THEN
                    RETURN
                END

            NEXT I
           
            EB.SystemTables.setEtext('CHEQUE NO. IS MANDATORY FOR ONLINE AC')
            EB.ErrorProcessing.StoreEndError()

        END
    END


************************************FUNDS.TRANSFER*************************************************************

    IF Y.APPLICATION EQ 'FUNDS.TRANSFER' THEN
   
        Y.FT.TRANSACTION.TYPE = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.TransactionType)

        IF (Y.FT.TRANSACTION.TYPE EQ 'ACAT') OR (Y.FT.TRANSACTION.TYPE EQ 'ACPT') THEN
            RETURN
        END

        Y.VERSION= Y.APPLICATION:Y.PGM

        EB.DataAccess.FRead(FN.ACVER,Y.RECORD,ACVER.REC,F.ACVER,ACVER.ERR)
        Y.VER.LIST= ACVER.REC<EB.EXCP.VERSION>

        CNT1= DCOUNT(Y.VER.LIST,@VM)
        FOR I=1 TO CNT1

            Y.VERSION.LIST= Y.VER.LIST<1,I>
            IF Y.VERSION EQ Y.VERSION.LIST THEN
                RETURN
            END
        NEXT I

        Y.DEBIT.AC= EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitAcctNo)
        Y.CHQ.NO= EB.SystemTables.getRNew(FT.Contract.FundsTransfer.ChequeNumber)

        IF Y.DEBIT.AC[1,2] EQ 'PL' THEN
            RETURN
        END

        EB.DataAccess.FRead(FN.AC,Y.DEBIT.AC,AC.REC,F.AC,AC.ERR)
        Y.CO.CODE= AC.REC<AC.AccountOpening.Account.CoCode>
        Y.CATEGORY= AC.REC<AC.AccountOpening.Account.Category>

        Y.CAT.LIST= ACVER.REC<EB.EXCP.CATEGORY>

        CNT2= DCOUNT(Y.CAT.LIST,@VM)
        FOR I=1 TO CNT2
            Y.CATEGORY.LIST= Y.CAT.LIST<1,I>

            IF Y.CATEGORY EQ Y.CATEGORY.LIST THEN
                RETURN
            END
        NEXT I

        IF EB.SystemTables.getIdCompany() NE Y.CO.CODE AND Y.CHQ.NO EQ '' THEN

            EB.DataAccess.FRead(FN.ACVER,Y.RECORD,ACVER.REC,F.ACVER,ACVER.ERR)
            Y.AC.LIST= ACVER.REC<EB.EXCP.FT.ACCOUNT.NO>

            CNT3= DCOUNT(Y.AC.LIST,@VM)
            FOR I=1 TO CNT3
                Y.ACCOUNT.LIST= Y.AC.LIST<1,I>

                IF Y.DEBIT.AC EQ Y.ACCOUNT.LIST THEN
                    RETURN
                END
            NEXT I
         
*            Y.OP.CO=EB.SystemTables.getIdCompany()
*            Y.LOG.FILE='ONLINWITHOUTCHQ.txt'
*            Y.FILE.DIR ='MBL.DATA'
*            Y.FT.TEXT=  Y.DEBIT.AC:",":Y.CHQ.NO:",":Y.CO.CODE:",":Y.OP.CO:","Y.VERSION
*            OPENSEQ Y.FILE.DIR,Y.LOG.FILE TO F.FILE.DIR ELSE NULL
*            WRITESEQ Y.FT.TEXT APPEND TO F.FILE.DIR ELSE NULL
*            CLOSESEQ F.FILE.DIR
*
            
            EB.SystemTables.setEtext('CHEQUE NO. IS MANDATORY FOR ONLINE AC')
            EB.ErrorProcessing.StoreEndError()
        END
    END


****************************ACCOUNT.CLOSURE****************************************************
   
    IF Y.APPLICATION EQ 'ACCOUNT.CLOSURE' THEN

        Y.AC.ACL.SETTLEMENT.ACCT = EB.SystemTables.getRNew(AC.AccountClosure.AccountClosure.AclSettlementAcct)
        Y.AC.ACL = EB.SystemTables.getIdNew()
        EB.DataAccess.FRead(FN.AC,Y.AC.ACL,AC.ACL.REC,F.AC,AC.ACL.ERR)
    
        Y.WRK.BAL = AC.ACL.REC<AC.AccountOpening.Account.WorkingBalance>
        Y.BAL = AC.ACL.REC<AC.AccountOpening.Account.OnlineActualBal>

        EB.DataAccess.FRead(FN.AC,Y.AC.ACL.SETTLEMENT.ACCT,AC.REC,F.AC,AC.ERR)
        Y.AC.ACL.SETTLEMENT.ACCT.BR = AC.REC<AC.AccountOpening.Account.CoCode>
        Y.SET.WR.BAL = AC.REC<AC.AccountOpening.Account.WorkingBalance>

        EB.DataAccess.FRead(FN.AC,Y.AC.ACL,AC.ACL.REC,F.AC,AC.ERR)

        Y.BAL = AC.ACL.REC<AC.AccountOpening.Account.OnlineActualBal>

        IF NOT(NUM(Y.AC.ACL.SETTLEMENT.ACCT)) THEN

            EB.SystemTables.setEtext('GL/PL ACCOUNT NOT ALLOWED')
            EB.ErrorProcessing.StoreEndError()

        END

        IF EB.SystemTables.getIdCompany() NE Y.AC.ACL.SETTLEMENT.ACCT.BR THEN
            IF Y.BAL LE 0 THEN

                EB.SystemTables.setEtext('OTHER BR AC IS NOT ALLOWED')
                EB.ErrorProcessing.StoreEndError()

            END
        END

    END

***********************************STO************************************************

    IF Y.APPLICATION EQ 'STANDING.ORDER' THEN

        IF NOT(NUM(EB.SystemTables.getIdNew())) THEN

            EB.SystemTables.setEtext('GL/PL ACCOUNT NOT ALLOWED')
            EB.ErrorProcessing.StoreEndError()

        END

    END


********************************MD.DEAL****************************************************

    IF Y.APPLICATION EQ 'MD.DEAL' THEN

        Y.MD.DEA.CHARGE.ACCOUNT = EB.SystemTables.getRNew(MD.Contract.Deal.DeaChargeAccount)
        Y.MD.DEA.PROV.DR.ACCOUNT = EB.SystemTables.getRNew(MD.Contract.Deal.DeaProvDrAccount)
        Y.MD.DEA.PROV.REL.ACCOUNT = EB.SystemTables.getRNew(MD.Contract.Deal.DeaProvRelAccount)
        Y.MD.DEA.PROV.CR.ACCOUNT = EB.SystemTables.getRNew(MD.Contract.Deal.DeaProvCrAccount)

        EB.DataAccess.FRead(FN.AC,Y.MD.DEA.CHARGE.ACCOUNT,AC.REC,F.AC,AC.ERR)
        Y.MD.DEA.CHARGE.ACCOUNT.BR = AC.REC<AC.AccountOpening.Account.CoCode>

        EB.DataAccess.FRead(FN.AC,Y.MD.DEA.PROV.DR.ACCOUNT,AC.REC,F.AC,AC.ERR)
        Y.MD.DEA.PROV.DR.ACCOUNT.BR = AC.REC<AC.AccountOpening.Account.CoCode>

        EB.DataAccess.FRead(FN.AC,Y.MD.DEA.PROV.REL.ACCOUNT,AC.REC,F.AC,AC.ERR)
        Y.MD.DEA.PROV.REL.ACCOUNT.BR = AC.REC<AC.AccountOpening.Account.CoCode>

        EB.DataAccess.FRead(FN.AC,Y.MD.DEA.PROV.CR.ACCOUNT,AC.REC,F.AC,AC.ERR)
        Y.MD.DEA.PROV.CR.ACCOUNT.BR = AC.REC<AC.AccountOpening.Account.CoCode>


        IF NOT(NUM(Y.MD.DEA.CHARGE.ACCOUNT)) OR NOT(NUM(Y.MD.DEA.PROV.DR.ACCOUNT)) OR NOT(NUM(Y.MD.DEA.PROV.REL.ACCOUNT)) THEN

            EB.SystemTables.setEtext('GL/PL ACCOUNT NOT ALLOWED')
            EB.ErrorProcessing.StoreEndError()

        END


        IF (EB.SystemTables.getIdCompany() EQ Y.MD.DEA.CHARGE.ACCOUNT.BR) OR (Y.MD.DEA.CHARGE.ACCOUNT EQ '') THEN
            IF(EB.SystemTables.getIdCompany() EQ Y.MD.DEA.PROV.DR.ACCOUNT.BR) OR(Y.MD.DEA.PROV.DR.ACCOUNT EQ '') THEN
                IF(EB.SystemTables.getIdCompany() EQ Y.MD.DEA.PROV.REL.ACCOUNT.BR) OR (Y.MD.DEA.PROV.REL.ACCOUNT EQ '') THEN
                    IF(EB.SystemTables.getIdCompany() EQ Y.MD.DEA.PROV.CR.ACCOUNT.BR) OR(Y.MD.DEA.PROV.CR.ACCOUNT EQ '')  THEN
                        RETURN
                    END
                END
            END
        END

        EB.SystemTables.setEtext('OTHER BRANCH ACCOUNT NOT ALLOWED')
        EB.ErrorProcessing.StoreEndError()

    END



****************************************LETTER.OF.CREDIT*******************************************************

*    IF Y.APPLICATION EQ 'LETTER.OF.CREDIT' THEN
*
*        RETURN
*
*        ! DEBUG
*        Y.TF.LC.APPLICANT.ACC = EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcApplicantAcc)
*        Y.TF.LC.CHARGES.ACCOUNT = EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcChargesAccount)
*        Y.TF.LC.CHARGE.ACCT = EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcChargeAcct)
*        Y.TF.LC.PROVIS.ACC = EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcProvisAcc)
*
*        EB.DataAccess.FRead(FN.AC,Y.TF.LC.APPLICANT.ACC,LC.AC.REC,F.AC,LC.ERR)
*        Y.TF.LC.APPLICANT.ACC.BR = LC.AC.REC<AC.AccountOpening.Account.CoCode>
*
*        EB.DataAccess.FRead(FN.AC,Y.TF.LC.CHARGES.ACCOUNT,LC.AC.REC,F.AC,LC.ERR)
*        Y.TF.LC.CHARGES.ACCOUNT.BR = LC.AC.REC<AC.AccountOpening.Account.CoCode>
*
*        EB.DataAccess.FRead(FN.AC,Y.TF.LC.CHARGE.ACCT,LC.AC.REC,F.AC,LC.ERR)
*        Y.TF.LC.CHARGE.ACCT.BR = LC.AC.REC<AC.AccountOpening.Account.CoCode>
*
*        EB.DataAccess.FRead(FN.AC,Y.TF.LC.PROVIS.ACC,LC.AC.REC,F.AC,LC.ERR)
*        Y.TF.LC.PROVIS.ACC.BR = LC.AC.REC<AC.AccountOpening.Account.CoCode>
*
*
*        !IF NOT(NUM(Y.TF.LC.APPLICANT.ACC)) OR NOT(NUM(Y.TF.LC.CHARGES.ACCOUNT)) OR NOT(NUM(Y.TF.LC.CHARGE.ACCT)) OR NOT(NUM(Y.TF.LC.PROVIS.ACC)) THEN
*
*        !EB.SystemTables.setEtext = 'GL/PL ACCOUNT NOT ALLOWED'
*        ! EB.ErrorProcessing.StoreEndError()
*
*        !END
*
*
*        IF (EB.SystemTables.getIdCompany() EQ Y.TF.LC.APPLICANT.ACC.BR) OR(Y.TF.LC.APPLICANT.ACC EQ '') THEN
*            IF(EB.SystemTables.getIdCompany() EQ Y.TF.LC.CHARGES.ACCOUNT.BR) OR (Y.TF.LC.CHARGES.ACCOUNT EQ '') THEN
*                IF(EB.SystemTables.getIdCompany() EQ Y.TF.LC.CHARGE.ACCT.BR) OR (Y.TF.LC.CHARGE.ACCT EQ '') THEN
*                    IF(EB.SystemTables.getIdCompany() EQ Y.TF.LC.PROVIS.ACC.BR) OR (Y.TF.LC.PROVIS.ACC EQ '') THEN
*
*                        RETURN
*                    END
*                END
*            END
*        END
*
*        EB.SystemTables.setEtext('OTHER BRANCH ACCOUNT NOT ALLOWED')
*        EB.ErrorProcessing.StoreEndError()
*
*    END


*******************************************DRAWINGS*****************************************************************

*    IF Y.APPLICATION EQ 'DRAWINGS' THEN
*        RETURN
*
*        Y.TF.DR.CHARGE.ACCOUNT = EB.SystemTables.getRNew(LC.Contract.Drawings.TfDrChargeAccount)
*        Y.TF.DR.DRAWDOWN.ACCOUNT = EB.SystemTables.getRNew(LC.Contract.Drawings.TfDrDrawdownAccount)
*
*        EB.DataAccess.FRead(FN.AC,Y.TF.DR.CHARGE.ACCOUNT,DR.AC.REC,F.AC,DR.ERR)
*        Y.TF.DR.CHARGE.ACCOUNT.BR = DR.AC.REC<AC.AccountOpening.Account.CoCode>
*
*        EB.DataAccess.FRead(FN.AC,Y.TF.DR.DRAWDOWN.ACCOUNT,DR.AC.REC,F.AC,DR.ERR)
*        Y.TF.DR.DRAWDOWN.ACCOUNT.BR = DR.AC.REC<AC.AccountOpening.Account.CoCode>
*        Y.TF.DR.DRAWDOWN.ACCOUNT.CAT = DR.AC.REC<AC.AccountOpening.Account.Category>
*
*
*
*        IF NOT(NUM(Y.TF.DR.CHARGE.ACCOUNT)) OR NOT(NUM(Y.TF.DR.DRAWDOWN.ACCOUNT)) THEN
*
*            EB.SystemTables.setEtext('GL/PL ACCOUNT NOT ALLOWED')
*            EB.ErrorProcessing.StoreEndError()
*
*        END
*
*
*        IF (EB.SystemTables.getIdCompany() EQ Y.TF.DR.CHARGE.ACCOUNT.BR) OR (Y.TF.DR.CHARGE.ACCOUNT.BR EQ '')  THEN
*
*            Y.FLAG = 'Y'
*
*        END
*
*        ELSE
*            EB.SystemTables.setEtext('OTHER BRANCH ACCOUNT NOT ALLOWED')
*            EB.ErrorProcessing.StoreEndError()
*
*        END
*
*
*        IF (EB.SystemTables.getIdCompany() EQ Y.TF.DR.DRAWDOWN.ACCOUNT.BR) OR (Y.TF.DR.DRAWDOWN.ACCOUNT.CAT EQ 5000) OR (Y.TF.DR.DRAWDOWN.ACCOUNT.CAT EQ 5001) OR (Y.TF.DR.DRAWDOWN.ACCOUNT.BR EQ '')  THEN
*            RETURN
*        END
*        ELSE
*            EB.SystemTables.setEtext('OTHER BRANCH ACCOUNT NOT ALLOWED')
*            EB.ErrorProcessing.StoreEndError()
*
*        END
*
*    END


***********************************************************************************************
RETURN
END
