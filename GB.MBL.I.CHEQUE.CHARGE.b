SUBROUTINE GB.MBL.I.CHEQUE.CHARGE
*-----------------------------------------------------------------------------
*Subroutine Description:
* This routine use for leaf wise charge calculation
*Subroutine Type:
*Attached To    : version(CHEQUE.ISSUE,MBL.CDA.PRINT,CHEQUE.ISSUE,MBL.CA.PRINT,CHEQUE.ISSUE,MBL.CDB.PRINT,CHEQUE.ISSUE,MBL.SBA.PRINT,CHEQUE.ISSUE,MBL.SA.PRINT)
*Attached As    : Input ROUTINE
*-----------------------------------------------------------------------------
* Modification History :
* 17/02/2020 -                      Retrofit   - MD.SAROWAR MORTOZA
*                                                 FDS Bangladesh Limited
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $USING ST.ChqFees
    $USING ST.ChqIssue
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING EB.Updates
*-----------------------------------------------------------------------------
    GOSUB INITIALISE ; *INITIALISATION
    GOSUB OPENFILE ; *FILE OPEN
    GOSUB PROCESS ; *PROCESS BUSINESS LOGIC
RETURN
*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc>INITIALISATION </desc>
    FN.CHE.CHAR = 'F.CHEQUE.CHARGE'
    F.CHE.CHAR= ''
    FN.CHE.ISSUE= 'F.CHEQUE.ISSUE'
    F.CHE.ISSUE=''
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= OPENFILE>
OPENFILE:
*** <desc>FILE OPEN </desc>
    EB.DataAccess.Opf(FN.CHE.CHAR,F.CHE.CHAR)
    EB.DataAccess.Opf(FN.CHE.ISSUE,F.CHE.ISSUE)
RETURN
*** </region>

*** <region name= PROCESS>
PROCESS:
*** <desc>PROCESS BUSINESS LOGIC </desc>
    Y.CHEQUE.NUMBER = EB.SystemTables.getIdNew()
    Y.CHEQUE.TYPE=FIELD(Y.CHEQUE.NUMBER,'.',1)
    
    Y.CHQ.CHRG.POS=""
    Y.CHQ.LEAF.NO.POS=""
    Y.APP.NAME ="CHEQUE.CHARGE":FM:"CHEQUE.ISSUE"
    LOCAL.FIELDS = ""
    LOCAL.FIELDS = "LT.CHG.PER.LEAF":FM:"LT.CHQ.LEAF.NO"
    FLD.POS = ""
    
    EB.Updates.MultiGetLocRef(Y.APP.NAME, LOCAL.FIELDS,FLD.POS)
    Y.CHQ.CHRG.POS=FLD.POS<1,1>
    Y.CHQ.LEAF.NO.POS=FLD.POS<2,1>
    Y.NUMBER.ISSUED= EB.SystemTables.getRNew(ST.ChqIssue.ChequeIssue.ChequeIsLocalRef)<1,Y.CHQ.LEAF.NO.POS>
    
    IF EB.SystemTables.getRNew(ST.ChqIssue.ChequeIssue.ChequeIsWaiveCharges) EQ 'NO' THEN
        EB.DataAccess.FRead(FN.CHE.CHAR,Y.CHEQUE.TYPE,R.CHEQUE,F.CHE.CHAR,Y.ERR)
        Y.AMOUNT=R.CHEQUE<ST.ChqFees.ChequeCharge.ChequeChgLocalRef,Y.CHQ.CHRG.POS>
        EB.SystemTables.setRNew(ST.ChqIssue.ChequeIssue.ChequeIsChgAmount, Y.AMOUNT*Y.NUMBER.ISSUED)
    END
RETURN
*** </region>
END
