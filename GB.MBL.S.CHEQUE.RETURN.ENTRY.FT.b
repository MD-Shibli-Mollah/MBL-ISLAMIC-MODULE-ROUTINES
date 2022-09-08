SUBROUTINE GB.MBL.S.CHEQUE.RETURN.ENTRY.FT
*-----------------------------------------------------------------------------
* Subroutine Description:
* This subroutine is used to make a contra entry when a cheque is return
* Routine Attach To: Auth routine
* Routine Attach Version: CHEQUE.COLLECTION,MBL.OWDCLR.RETURNED.BACPS
*-----------------------------------------------------------------------------
* Modification History :
*24/03/2020 -                             Retrofit   -MD.SAROWAR MORTOZA
*                                                 FDS Bangladesh Limited
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $USING AC.EntryCreation
    $USING FT.Contract
    $USING ST.ChqSubmit
    $USING EB.Utility
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING EB.Updates
    $USING EB.ErrorProcessing
    $USING AC.API
    $USING EB.TransactionControl
*-----------------------------------------------------------------------------
    Y.APP = "CHEQUE.COLLECTION":FM:"FUNDS.TRANSFER"
    Y.FIELD = "LT.CLG.STATUS":FM:"LT.FT.PR.CHQ.NO"
    Y.LOC.POS = ""
    EB.Updates.MultiGetLocRef(Y.APP, Y.FIELD, Y.LOC.POS)
    Y.CHQ.STATUS.POS = Y.LOC.POS<1,1>
    Y.FT.POS = Y.LOC.POS<2,1>
    
    Y.CHQ.CURR.STATUS = EB.SystemTables.getRNew(ST.ChqSubmit.ChequeCollection.ChqColLocalRef)<1,Y.CHQ.STATUS.POS>

    IF Y.CHQ.CURR.STATUS EQ 'RETURNED' THEN
        GOSUB INITIALISE ; *
        GOSUB RESOLVE.COMMON.LEG.ACCOUNTING ; *
        GOSUB RESOLVE.DEBIT.LEG.ACCOUNTING ; *
        GOSUB RESOLVE.CREDIT.LEG.ACCOUNTING ; *
        GOSUB PERFORM.ACCOUNTING ; *
    END
RETURN

*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc> </desc>
    ! Initialize Accounting Arrays...
    Y.TT.ID = ''
    REC.TT = ''

    Y.JUL.DATE = ''
*Y.JUL.DATE = RIGHT(R.DATES(EB.DAT.JULIAN.DATE),5)
    Y.JUL.DATE = RIGHT(R.DATES(EB.Utility.Dates.DatJulianDate),5)
    
    Y.EB.ACC.COMM.ARR = ''
    Y.EB.CR.ARR = ''
    Y.EB.DR.ARR = ''
    Y.EB.ACC.ARR = ''
    Y.CHQ.COLL.AMT = ''
    Y.TR.REF = ''

    Y.FT.ID=EB.SystemTables.getRNew(ST.ChqSubmit.ChequeCollection.ChqColTxnId)
    Y.CHQ.COLL.AMT = EB.SystemTables.getRNew(ST.ChqSubmit.ChequeCollection.ChqColAmount)
    Y.DR.ACCOUNT = EB.SystemTables.getRNew(ST.ChqSubmit.ChequeCollection.ChqColCreditAccNo)


    FV.FT = ''
    FV.FT.HIS = ''
    FN.FT = 'F.FUNDS.TRANSFER'
    FN.FT.HIS = 'F.FUNDS.TRANSFER$HIS'

    EB.DataAccess.Opf(FN.FT,FV.FT)
    EB.DataAccess.FRead(FN.FT,Y.FT.ID,REC.FT,FV.FT,ERR.FT)
 
    IF ERR.FT THEN
        REC.FT = ''
        Y.FT.ID = Y.FT.ID:";1"
        EB.DataAccess.Opf(FN.FT.HIS,FV.FT.HIS)
        EB.DataAccess.FRead(FN.FT.HIS,Y.FT.ID,REC.FT,FV.FT.HIS,ERR1.FT)
    END
    
    !----------------------
    Y.CR.ACCOUNT =REC.FT<FT.Contract.FundsTransfer.DebitAcctNo>
    Y.TR.REF = REC.FT<FT.Contract.FundsTransfer.LocalRef,Y.FT.POS>
    BEGIN CASE
        CASE EB.SystemTables.getRNew(ST.ChqSubmit.ChequeCollection.ChqColTxnCode) EQ '93'
            Y.PAID.DR.CODE = '134'
            Y.PAID.CR.CODE = '134'
        CASE EB.SystemTables.getRNew(ST.ChqSubmit.ChequeCollection.ChqColTxnCode) EQ '95'
            Y.PAID.DR.CODE = '135'
            Y.PAID.CR.CODE = '135'

        CASE EB.SystemTables.getRNew(ST.ChqSubmit.ChequeCollection.ChqColTxnCode) EQ '92'
            Y.PAID.DR.CODE = '136'
            Y.PAID.CR.CODE = '136'
    END CASE
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= RESOLVE.COMMON.LEG.ACCOUNTING>
RESOLVE.COMMON.LEG.ACCOUNTING:
*** <desc> </desc>
    Y.EB.ACC.COMM.ARR<AC.EntryCreation.StmtEntry.SteCompanyCode> = EB.SystemTables.getIdCompany()
    Y.EB.ACC.COMM.ARR<AC.EntryCreation.StmtEntry.SteTransReference> = Y.TR.REF
    Y.EB.ACC.COMM.ARR<AC.EntryCreation.StmtEntry.SteValueDate> = EB.SystemTables.getToday()
    Y.EB.ACC.COMM.ARR<AC.EntryCreation.StmtEntry.SteBookingDate> = EB.SystemTables.getToday()
    Y.EB.ACC.COMM.ARR<AC.EntryCreation.StmtEntry.SteSystemId> = 'AC'
    Y.EB.ACC.COMM.ARR<AC.EntryCreation.StmtEntry.SteCurrencyMarket> = '1'
    Y.EB.ACC.COMM.ARR<AC.EntryCreation.StmtEntry.SteCurrency> = 'BDT'
    Y.EB.ACC.COMM.ARR<AC.EntryCreation.StmtEntry.SteOurReference> = 'AC-CHEQUE RETURN'
    Y.EB.ACC.COMM.ARR<AC.EntryCreation.StmtEntry.SteAccountOfficer> = 1
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= RESOLVE.DEBIT.LEG.ACCOUNTING>
RESOLVE.DEBIT.LEG.ACCOUNTING:
*** <desc> </desc>
    Y.EB.DR.ARR = Y.EB.ACC.COMM.ARR
    Y.EB.DR.ARR<AC.EntryCreation.StmtEntry.SteAmountLcy> = (Y.CHQ.COLL.AMT * -1)
    Y.EB.DR.ARR<AC.EntryCreation.StmtEntry.SteTransactionCode> = Y.PAID.DR.CODE
    Y.EB.DR.ARR<AC.EntryCreation.StmtEntry.SteAccountNumber> = Y.DR.ACCOUNT
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= RESOLVE.CREDIT.LEG.ACCOUNTING>
RESOLVE.CREDIT.LEG.ACCOUNTING:
*** <desc> </desc>
    Y.EB.CR.ARR = Y.EB.ACC.COMM.ARR
    Y.EB.CR.ARR<AC.EntryCreation.StmtEntry.SteAmountLcy> = Y.CHQ.COLL.AMT
    Y.EB.CR.ARR<AC.EntryCreation.StmtEntry.SteAccountNumber> = Y.CR.ACCOUNT
    Y.EB.CR.ARR<AC.EntryCreation.StmtEntry.SteTransactionCode> = Y.PAID.CR.CODE
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PERFORM.ACCOUNTING>
PERFORM.ACCOUNTING:
*** <desc> </desc>
    Y.EB.ACC.ARR = ''
    Y.EB.ACC.ARR<-1> = LOWER(Y.EB.CR.ARR)
    Y.EB.ACC.ARR<-1> = LOWER(Y.EB.DR.ARR)
    Y.EB.CR.ARR = ''
    Y.EB.DR.ARR = ''
    EB.ERR = ''
    ACC.TYPE = "SAO":FM:FM:"UPDATE.ACTIVITY"
*CALL EB.ACCOUNTING("ACC",ACC.TYPE,Y.EB.ACC.ARR,EB.ERR)
    AC.API.EbAccounting("ACC",ACC.TYPE,Y.EB.ACC.ARR,EB.ERR)
*CALL JOURNAL.UPDATE('')
    EB.TransactionControl.JournalUpdate('')
    SENSITIVITY=''
RETURN
*** </region>

END





