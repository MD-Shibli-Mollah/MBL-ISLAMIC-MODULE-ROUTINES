SUBROUTINE GB.MBL.I.CHQ.PRINT
*-----------------------------------------------------------------------------
*Subroutine Description:
* This routine is use for Cheque Number, Cheque no not zero or blank validation
*Subroutine Type:
*Attached To    : version(CHEQUE.ISSUE,MBL.CDA.PRINT,CHEQUE.ISSUE,MBL.CA.PRINT,CHEQUE.ISSUE,MBL.CDB.PRINT,CHEQUE.ISSUE,MBL.SBA.PRINT,CHEQUE.ISSUE,MBL.SA.PRINT)
*Attached As    : INPUT ROUTINE
*-----------------------------------------------------------------------------
* Modification History :
* R10 LEGACY ROUTINE NAME:V.MBL.CHQ.ISSUE
* 23/02/2020 -                             Retrofit   - MD. SAROWAR MORTOZA
*                                                 FDS Bangladesh Limited
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $USING ST.ChqIssue
    $USING ST.ChqSubmit
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING EB.OverrideProcessing
    $USING EB.Foundation
    $USING EB.ErrorProcessing
*-----------------------------------------------------------------------------
    GOSUB INITIALISE ; *INITIALISATION
    GOSUB OPENFILE ; *FILE OPEN
    GOSUB PROCESS ; *PROCESS BUSINESS LOGIC
RETURN
*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc>INITIALISATION </desc>
    F.CHEQUE.REGISTER = ''
    FN.CHEQUE.REGISTER = 'F.CHEQUE.REGISTER'

    Y.TXN.ID = EB.SystemTables.getIdNew()
    Y.ACCOUNT.ID = ''
    Y.CUSTOMER.ID = ''

    Y.CHQ.NO.CHK = 5

    Y.NULL = ''

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= OPENFILE>
OPENFILE:
*** <desc>FILE OPEN </desc>
    EB.DataAccess.Opf(FN.CHEQUE.REGISTER,F.CHEQUE.REGISTER)
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc>PROCESS BUSINESS LOGIC </desc>
* To check the number of previously unused cheques...
* And to generate an override if more than 5 cheques are unused..
***--------------

    Y.CHQ.ISS.ID = EB.SystemTables.getIdNew()
    Y.CHQ.REG.ID = FIELD(Y.CHQ.ISS.ID,'.',1,2)

    R.CHEQUE.REGISTER = ''
    Y.CHEQUE.REGISTER.ERR = ''
    EB.DataAccess.FRead(FN.CHEQUE.REGISTER,Y.CHQ.REG.ID,R.CHEQUE.REGISTER,F.CHEQUE.REGISTER,Y.CHEQUE.REGISTER.ERR)
    Y.CHQ.NO.HELD = R.CHEQUE.REGISTER<ST.ChqSubmit.ChequeRegister.ChequeRegNoHeld>
    
    IF Y.CHQ.NO.HELD GT Y.CHQ.NO.CHK THEN
        EB.SystemTables.setText("More than 5 Cheque Leaves not Presented")
        EB.OverrideProcessing.StoreOverride(CURR.NO)
    END

*---------------
**To input user branch code in company code
*---------------
    Y.CHQ.COM.CODE.POS=""
    Y.CHQ.NO.START.POS=""
    Y.APP.NAME ="CHEQUE.ISSUE"
    LOCAL.FIELDS = ""
    LOCAL.FIELDS = "LT.CHQ.COM.CODE":VM:"LT.CHQ.NO.START"
    FLD.POS = ""
    EB.Foundation.MapLocalFields(Y.APP.NAME, LOCAL.FIELDS,FLD.POS)
    Y.CHQ.COM.CODE.POS=FLD.POS<1,1>
    Y.CHQ.NO.START.POS=FLD.POS<1,2>

*    Y.USER.CO.CODE = EB.SystemTables.getRUser()<5>
*
*    IF Y.USER.CO.CODE NE 'ALL' THEN
*        Y.TEMP = EB.SystemTables.getRNew(ST.ChqIssue.ChequeIssue.ChequeIsLocalRef)
*        Y.TEMP<1,Y.CHQ.COM.CODE.POS> = Y.USER.CO.CODE
*        EB.SystemTables.setRNew(ST.ChqIssue.ChequeIssue.ChequeIsLocalRef, Y.TEMP)
*    END
    
    Y.TEMP = EB.SystemTables.getRNew(ST.ChqIssue.ChequeIssue.ChequeIsLocalRef)
    Y.TEMP<1,Y.CHQ.COM.CODE.POS> = EB.SystemTables.getIdCompany()
    EB.SystemTables.setRNew(ST.ChqIssue.ChequeIssue.ChequeIsLocalRef, Y.TEMP)
    
    
    Y.CHQ.ISS.START.NO=EB.SystemTables.getRNew(ST.ChqIssue.ChequeIssue.ChequeIsLocalRef)<1,Y.CHQ.NO.START.POS>
    
    IF Y.CHQ.ISS.START.NO EQ '' THEN
        EB.SystemTables.setAf(ST.ChqIssue.ChequeIssue.ChequeIsLocalRef)
        EB.SystemTables.setAv(Y.CHQ.NO.START.POS)
        EB.SystemTables.setEtext('Cheque Start Number cannot be 0 (Zero) or Blank')
        EB.ErrorProcessing.StoreEndError()
    END
    
    
    Y.CHQ.REG.CNT=DCOUNT(R.CHEQUE.REGISTER<ST.ChqSubmit.ChequeRegister.ChequeRegChequeNos>,@VM)
    I=1
    LOOP
    WHILE I LE Y.CHQ.REG.CNT
        Y.CHQ.NO=R.CHEQUE.REGISTER<ST.ChqSubmit.ChequeRegister.ChequeRegChequeNos,I>
        Y.CHQ.REG.START.NO=''
        Y.CHQ.REG.START.NO=FIELD(Y.CHQ.NO,'-',1)
        Y.CHQ.REG.END.NO=''
        Y.CHQ.REG.END.NO=FIELD(Y.CHQ.NO,'-',2)
        IF Y.CHQ.ISS.START.NO GE Y.CHQ.REG.START.NO AND Y.CHQ.ISS.START.NO LE Y.CHQ.REG.END.NO THEN
            EB.SystemTables.setAf(ST.ChqIssue.ChequeIssue.ChequeIsLocalRef)
            EB.SystemTables.setAv(Y.CHQ.NO.START.POS)
            EB.SystemTables.setEtext('Cheque Start ID already Issued')
            EB.ErrorProcessing.StoreEndError()
            RETURN
        END
        I+=1
    REPEAT
RETURN
*** </region>

END



