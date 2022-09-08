* @ValidationCode : MjoxNDE0MzA1NjE2OkNwMTI1MjoxNTkyNzI4OTUwOTI0OlphaGlkIEZEUzotMTotMTowOjA6ZmFsc2U6Ti9BOkRFVl8yMDE3MTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 21 Jun 2020 14:42:30
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : Zahid FDS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0

SUBROUTINE GB.MBL.I.CHEQUE.ISS.CHG
*-----------------------------------------------------------------------------
*Developed By: Md. Zahid Hasan
*Project Name: MBL Islamic
*Details: This routine default the value of Charge amount and Vat amount during
*   cheque issue input stage. It takes per leaf charge amount from CHEQUE.CHARGE
*   and then multiplies it with no of leaf issued.
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

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
    GOSUB CHQLEN ; *CHEQUE LENGTH VALIDATION
    GOSUB CHQCHG ; *PROCESS BUSINESS LOGIC
RETURN
*-----------------------------------------------------------------------------

**********
INITIALISE:
**********
    FN.CHE.CHAR = 'F.CHEQUE.CHARGE'
    F.CHE.CHAR= ''
    
    FN.CHE.ISSUE= 'F.CHEQUE.ISSUE'
    F.CHE.ISSUE=''
RETURN

*********
OPENFILE:
*********
    EB.DataAccess.Opf(FN.CHE.CHAR,F.CHE.CHAR)
    EB.DataAccess.Opf(FN.CHE.ISSUE,F.CHE.ISSUE)
RETURN

********
CHQLEN:
********
    ChqStartNo = EB.SystemTables.getRNew(ST.ChqIssue.ChequeIssue.ChequeIsChqNoStart)
    ChqNoLen = LEN(ChqStartNo)
    IF ChqNoLen NE 7 THEN
        ErrMsgChq = 'Cheque start no length must be 7 character'
        EB.SystemTables.setE(ErrMsgChq)
    END

RETURN

********
CHQCHG:
********
    Y.CHEQUE.NUMBER = EB.SystemTables.getIdNew()
    Y.CHEQUE.TYPE=FIELD(Y.CHEQUE.NUMBER,'.',1)
    
    Y.CHQ.CHRG.POS=""
    
    Y.APP.NAME ="CHEQUE.CHARGE"
    LOCAL.FIELDS = ""
    LOCAL.FIELDS = "LT.CHG.PER.LEAF"
    FLD.POS = ""
    
    EB.Updates.MultiGetLocRef(Y.APP.NAME, LOCAL.FIELDS,FLD.POS)
    Y.CHQ.CHRG.POS=FLD.POS<1,1>
    
    Y.NUMBER.ISSUED= EB.SystemTables.getRNew(ST.ChqIssue.ChequeIssue.ChequeIsNumberIssued)
    
    IF EB.SystemTables.getRNew(ST.ChqIssue.ChequeIssue.ChequeIsWaiveCharges) EQ 'NO' THEN
        EB.DataAccess.FRead(FN.CHE.CHAR,Y.CHEQUE.TYPE,R.CHEQUE,F.CHE.CHAR,Y.ERR)
        PER.LEAF.CHG = R.CHEQUE<ST.ChqFees.ChequeCharge.ChequeChgLocalRef,Y.CHQ.CHRG.POS>
        TOTAL.CHG = Y.NUMBER.ISSUED*PER.LEAF.CHG
        EB.SystemTables.setRNew(ST.ChqIssue.ChequeIssue.ChequeIsChgAmount, TOTAL.CHG)
    END
RETURN

END
